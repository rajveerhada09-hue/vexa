import 'dart:developer' as developer;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';

import '../model/user_model.dart';
import '../model/product_model.dart';
import '../model/knowledge_document_model.dart'
    show KnowledgeDocumentModel, DocumentType;
import '../model/faq_model.dart';
import '../repository/user_repository.dart';

enum UserProviderErrorType {
  none,
  permissionDenied,
  notFound,
  other,
}

class UserProvider extends ChangeNotifier {
  final UserRepository _userRepository;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;
  UserProviderErrorType _errorType = UserProviderErrorType.none;

  UserProvider({UserRepository? userRepository})
      : _userRepository = userRepository ?? UserRepository();

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  UserProviderErrorType get errorType => _errorType;

  /// Loads the currently authenticated user's Firestore data.
  /// If [user] is provided, uses that user instead of reading from FirebaseAuth.currentUser.
  /// This avoids a race condition where authStateChanges has emitted a user
  /// but FirebaseAuth.instance.currentUser hasn't propagated yet.
  Future<void> loadCurrentUser({User? user}) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    _errorType = UserProviderErrorType.none;
    notifyListeners();

    try {
      _currentUser = await _userRepository.getCurrentUser(user: user);
    } catch (e, stackTrace) {
      developer.log(
        'Error loading current user',
        error: e,
        stackTrace: stackTrace,
      );

      final errorString = e.toString();
      _error = _formatErrorMessage(e);

      if (errorString.contains('PERMISSION_DENIED') ||
          errorString.contains('permission-denied') ||
          errorString.contains('Missing or insufficient permissions')) {
        _errorType = UserProviderErrorType.permissionDenied;
      } else if (errorString.contains('NOT_FOUND') ||
          errorString.contains('not-found') ||
          errorString.contains('document does not exist')) {
        _errorType = UserProviderErrorType.notFound;
      } else {
        _errorType = UserProviderErrorType.other;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Saves the personality selected on onboarding Screen 2.
  /// Updates local state immediately, then syncs to Firestore in background.
  /// Returns true if local update succeeds; Firestore errors are logged but don't block navigation.
  Future<bool> saveAiPersonality({
    required String personality,
    String? customInstructions,
  }) async {
    if (_currentUser == null) {
      _error = 'No authenticated user found.';
      notifyListeners();
      return false;
    }

    final trimmedCustomInstructions = customInstructions?.trim();

    if (personality == 'custom' &&
        (trimmedCustomInstructions == null ||
            trimmedCustomInstructions.isEmpty)) {
      _error = 'Please describe how Vexa should behave.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = _currentUser!.copyWith(
        aiPersonality: personality,
        customAiPersonality:
            personality == 'custom' ? trimmedCustomInstructions : null,
        onboardingStep: 3,
        onboardingComplete: false,
      );
      notifyListeners();

      _syncAiPersonalityToFirestore(
        userId: _currentUser!.uid,
        aiPersonality: personality,
        customAiPersonality: trimmedCustomInstructions,
      );

      return true;
    } catch (e, stackTrace) {
      developer.log(
        'Error updating local AI personality state',
        error: e,
        stackTrace: stackTrace,
      );

      _error = _formatErrorMessage(e);
      return false;
    } finally {
      _isLoading = false;
    }
  }

  void _syncAiPersonalityToFirestore({
    required String userId,
    required String aiPersonality,
    String? customAiPersonality,
  }) {
    _userRepository
        .updateAiPersonality(
          userId: userId,
          aiPersonality: aiPersonality,
          customAiPersonality: customAiPersonality,
        )
        .catchError((error, stackTrace) {
      developer.log(
        'Firestore sync failed for AI personality (will retry when online)',
        error: error,
        stackTrace: stackTrace,
      );
    });
  }

  /// Saves business info on onboarding Screen 3.
  Future<bool> saveBusinessInfo({
    required String businessName,
    required String businessType,
    required String businessOpeningTime,
    required String businessClosingTime,
    required String businessTimeZone,
  }) async {
    if (_currentUser == null) {
      _error = 'No authenticated user found.';
      notifyListeners();
      return false;
    }

    if (businessName.trim().isEmpty) {
      _error = 'Business name is required.';
      notifyListeners();
      return false;
    }

    if (businessType.trim().isEmpty) {
      _error = 'Business type is required.';
      notifyListeners();
      return false;
    }

    if (businessOpeningTime.trim().isEmpty) {
      _error = 'Opening time is required.';
      notifyListeners();
      return false;
    }

    if (businessClosingTime.trim().isEmpty) {
      _error = 'Closing time is required.';
      notifyListeners();
      return false;
    }

    if (businessTimeZone.trim().isEmpty) {
      _error = 'Time zone is required.';
      notifyListeners();
      return false;
    }

    if (!_isClosingAfterOpening(businessOpeningTime, businessClosingTime)) {
      _error = 'Closing time must be after opening time.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _userRepository.updateBusinessInfo(
        userId: _currentUser!.uid,
        businessName: businessName.trim(),
        businessType: businessType.trim(),
        businessOpeningTime: businessOpeningTime,
        businessClosingTime: businessClosingTime,
        businessTimeZone: businessTimeZone,
      );

      _currentUser = _currentUser!.copyWith(
        businessName: businessName.trim(),
        businessType: businessType.trim(),
        businessOpeningTime: businessOpeningTime,
        businessClosingTime: businessClosingTime,
        businessTimeZone: businessTimeZone,
        onboardingStep: 4,
        onboardingComplete: false,
      );

      return true;
    } catch (e, stackTrace) {
      developer.log(
        'Error saving business info',
        error: e,
        stackTrace: stackTrace,
      );

      _error = _formatErrorMessage(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool _isClosingAfterOpening(String opening, String closing) {
    final o = opening.split(':').map(int.parse).toList();
    final c = closing.split(':').map(int.parse).toList();
    final openMin = o[0] * 60 + o[1];
    final closeMin = c[0] * 60 + c[1];
    return closeMin > openMin;
  }

  /// Saves language preference on onboarding Screen 4.
  Future<bool> saveLanguagePreference({
    required String languagePreference,
  }) async {
    if (_currentUser == null) {
      _error = 'No authenticated user found.';
      notifyListeners();
      return false;
    }

    const allowedValues = ['auto', 'hi', 'en', 'fr', 'es', 'de'];
    if (!allowedValues.contains(languagePreference)) {
      _error = 'Invalid language selection.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _userRepository.updateLanguagePreference(
        userId: _currentUser!.uid,
        languagePreference: languagePreference,
      );

      _currentUser = _currentUser!.copyWith(
        languagePreference: languagePreference,
        onboardingStep: 5,
        onboardingComplete: false,
      );

      return true;
    } catch (e, stackTrace) {
      developer.log(
        'Error saving language preference',
        error: e,
        stackTrace: stackTrace,
      );

      _error = _formatErrorMessage(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Saves voice preference on onboarding Screen 5.
  Future<bool> saveVoicePreference({
    required String voicePreference,
  }) async {
    if (_currentUser == null) {
      _error = 'No authenticated user found.';
      notifyListeners();
      return false;
    }

    const allowedValues = ['male', 'female'];
    if (!allowedValues.contains(voicePreference)) {
      _error = 'Invalid voice selection.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _userRepository.updateVoicePreference(
        userId: _currentUser!.uid,
        voicePreference: voicePreference,
      );

      _currentUser = _currentUser!.copyWith(
        voicePreference: voicePreference,
        onboardingStep: 6,
        onboardingComplete: false,
      );

      return true;
    } catch (e, stackTrace) {
      developer.log(
        'Error saving voice preference',
        error: e,
        stackTrace: stackTrace,
      );

      _error = _formatErrorMessage(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Saves greeting template on onboarding Screen 6.
  Future<bool> saveGreetingTemplate({
    required String greetingTemplate,
    String? customGreeting,
  }) async {
    if (_currentUser == null) {
      _error = 'No authenticated user found.';
      notifyListeners();
      return false;
    }

    const allowedTemplates = ['professional', 'friendly', 'brief', 'custom'];
    if (!allowedTemplates.contains(greetingTemplate)) {
      _error = 'Invalid greeting template selection.';
      notifyListeners();
      return false;
    }

    if (greetingTemplate == 'custom' &&
        (customGreeting == null || customGreeting.trim().isEmpty)) {
      _error = 'Please enter a custom greeting.';
      notifyListeners();
      return false;
    }

    if (customGreeting != null && customGreeting.trim().length > 300) {
      _error = 'Custom greeting must be 300 characters or less.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _userRepository.updateGreetingTemplate(
        userId: _currentUser!.uid,
        greetingTemplate: greetingTemplate,
        customGreeting: greetingTemplate == 'custom' ? customGreeting?.trim() : null,
      );

      _currentUser = _currentUser!.copyWith(
        greetingTemplate: greetingTemplate,
        customGreeting: greetingTemplate == 'custom' ? customGreeting?.trim() : null,
        onboardingStep: 7,
        onboardingComplete: false,
      );

      return true;
    } catch (e, stackTrace) {
      developer.log(
        'Error saving greeting template',
        error: e,
        stackTrace: stackTrace,
      );

      _error = _formatErrorMessage(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Adds a product to the knowledge base.
  Future<bool> addProduct({
    required String name,
    required double price,
    String currency = 'INR',
    String? description,
    String? unit,
  }) async {
    if (_currentUser == null) {
      _error = 'No authenticated user found.';
      notifyListeners();
      return false;
    }

    if (name.trim().isEmpty) {
      _error = 'Product name is required.';
      notifyListeners();
      return false;
    }

    if (price <= 0) {
      _error = 'Price must be greater than zero.';
      notifyListeners();
      return false;
    }

    try {
      final now = DateTime.now();
      final productId = _userRepository.firestoreCollectionId();
      final product = ProductModel(
        id: productId,
        name: name.trim(),
        price: price,
        currency: currency,
        description: description?.trim(),
        unit: unit?.trim(),
        createdAt: now,
        updatedAt: now,
      );

      await _userRepository.addProduct(
        userId: _currentUser!.uid,
        product: product,
      );

      _currentUser = _currentUser!.copyWith(
        productsCount: _currentUser!.productsCount + 1,
      );
      notifyListeners();

      _syncKnowledgeBaseCounts();
      return true;
    } catch (e, stackTrace) {
      developer.log(
        'Error adding product',
        error: e,
        stackTrace: stackTrace,
      );
      _error = _formatErrorMessage(e);
      return false;
    }
  }

  /// Updates an existing product.
  Future<bool> updateProduct({
    required String productId,
    required String name,
    required double price,
    String currency = 'INR',
    String? description,
    String? unit,
  }) async {
    if (_currentUser == null) {
      _error = 'No authenticated user found.';
      notifyListeners();
      return false;
    }

    if (name.trim().isEmpty) {
      _error = 'Product name is required.';
      notifyListeners();
      return false;
    }

    if (price <= 0) {
      _error = 'Price must be greater than zero.';
      notifyListeners();
      return false;
    }

    try {
      final updatedProduct = ProductModel(
        id: productId,
        name: name.trim(),
        price: price,
        currency: currency,
        description: description?.trim(),
        unit: unit?.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _userRepository.updateProduct(
        userId: _currentUser!.uid,
        product: updatedProduct,
      );

      return true;
    } catch (e, stackTrace) {
      developer.log(
        'Error updating product',
        error: e,
        stackTrace: stackTrace,
      );
      _error = _formatErrorMessage(e);
      return false;
    }
  }

  /// Deletes a product from the knowledge base.
  Future<bool> deleteProduct(String productId) async {
    if (_currentUser == null) {
      _error = 'No authenticated user found.';
      notifyListeners();
      return false;
    }

    try {
      await _userRepository.deleteProduct(
        userId: _currentUser!.uid,
        productId: productId,
      );

      _currentUser = _currentUser!.copyWith(
        productsCount: _currentUser!.productsCount - 1,
      );
      notifyListeners();

      _syncKnowledgeBaseCounts();
      return true;
    } catch (e, stackTrace) {
      developer.log(
        'Error deleting product',
        error: e,
        stackTrace: stackTrace,
      );
      _error = _formatErrorMessage(e);
      return false;
    }
  }

  /// Loads products for the current user.
  Future<List<ProductModel>> loadProducts() async {
    if (_currentUser == null) return [];
    try {
      return await _userRepository.getProducts(_currentUser!.uid);
    } catch (e, stackTrace) {
      developer.log(
        'Error loading products',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  /// Uploads a document file to Firebase Storage and saves metadata.
  Future<KnowledgeDocumentModel?> uploadDocument({
    required DocumentType documentType,
    required PlatformFile file,
  }) async {
    if (_currentUser == null) {
      _error = 'No authenticated user found.';
      notifyListeners();
      return null;
    }

    if (file.path == null) {
      _error = 'Invalid file path.';
      notifyListeners();
      return null;
    }

    try {
      String mimeType = 'application/octet-stream';
      final extension = file.name.split('.').last.toLowerCase();
      switch (extension) {
        case 'pdf':
          mimeType = 'application/pdf';
          break;
        case 'doc':
          mimeType = 'application/msword';
          break;
        case 'docx':
          mimeType = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
          break;
        case 'xls':
          mimeType = 'application/vnd.ms-excel';
          break;
        case 'xlsx':
          mimeType = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
          break;
        case 'csv':
          mimeType = 'text/csv';
          break;
        case 'txt':
          mimeType = 'text/plain';
          break;
        case 'jpg':
        case 'jpeg':
          mimeType = 'image/jpeg';
          break;
        case 'png':
          mimeType = 'image/png';
          break;
      }

      final document = await _userRepository.uploadDocument(
        userId: _currentUser!.uid,
        fileName: file.name,
        documentType: documentType,
        mimeType: mimeType,
        fileSize: file.size,
        localFilePath: file.path!,
      );

      _currentUser = _currentUser!.copyWith(
        documentsCount: _currentUser!.documentsCount + 1,
      );
      notifyListeners();

      _syncKnowledgeBaseCounts();
      return document;
    } catch (e, stackTrace) {
      developer.log(
        'Error uploading document',
        error: e,
        stackTrace: stackTrace,
      );
      _error = _formatErrorMessage(e);
      return null;
    }
  }

  /// Deletes a document from Firebase Storage and Firestore.
  Future<bool> deleteDocument({
    required String documentId,
    required String storagePath,
  }) async {
    if (_currentUser == null) {
      _error = 'No authenticated user found.';
      notifyListeners();
      return false;
    }

    try {
      await _userRepository.deleteDocument(
        userId: _currentUser!.uid,
        documentId: documentId,
        storagePath: storagePath,
      );

      _currentUser = _currentUser!.copyWith(
        documentsCount: _currentUser!.documentsCount - 1,
      );
      notifyListeners();

      _syncKnowledgeBaseCounts();
      return true;
    } catch (e, stackTrace) {
      developer.log(
        'Error deleting document',
        error: e,
        stackTrace: stackTrace,
      );
      _error = _formatErrorMessage(e);
      return false;
    }
  }

  /// Loads documents for the current user.
  Future<List<KnowledgeDocumentModel>> loadDocuments() async {
    if (_currentUser == null) return [];
    try {
      return await _userRepository.getDocuments(_currentUser!.uid);
    } catch (e, stackTrace) {
      developer.log(
        'Error loading documents',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  /// Adds an FAQ to the knowledge base.
  Future<bool> addFaq({
    required String question,
    required String answer,
  }) async {
    if (_currentUser == null) {
      _error = 'No authenticated user found.';
      notifyListeners();
      return false;
    }

    if (question.trim().isEmpty) {
      _error = 'Question is required.';
      notifyListeners();
      return false;
    }

    if (answer.trim().isEmpty) {
      _error = 'Answer is required.';
      notifyListeners();
      return false;
    }

    try {
      final now = DateTime.now();
      final faqId = _userRepository.firestoreCollectionId();
      final faq = FaqModel(
        id: faqId,
        question: question.trim(),
        answer: answer.trim(),
        createdAt: now,
        updatedAt: now,
      );

      await _userRepository.addFaq(
        userId: _currentUser!.uid,
        faq: faq,
      );

      _currentUser = _currentUser!.copyWith(
        faqsCount: _currentUser!.faqsCount + 1,
      );
      notifyListeners();

      _syncKnowledgeBaseCounts();
      return true;
    } catch (e, stackTrace) {
      developer.log(
        'Error adding FAQ',
        error: e,
        stackTrace: stackTrace,
      );
      _error = _formatErrorMessage(e);
      return false;
    }
  }

  /// Updates an existing FAQ.
  Future<bool> updateFaq({
    required String faqId,
    required String question,
    required String answer,
  }) async {
    if (_currentUser == null) {
      _error = 'No authenticated user found.';
      notifyListeners();
      return false;
    }

    if (question.trim().isEmpty) {
      _error = 'Question is required.';
      notifyListeners();
      return false;
    }

    if (answer.trim().isEmpty) {
      _error = 'Answer is required.';
      notifyListeners();
      return false;
    }

    try {
      final updatedFaq = FaqModel(
        id: faqId,
        question: question.trim(),
        answer: answer.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _userRepository.updateFaq(
        userId: _currentUser!.uid,
        faq: updatedFaq,
      );

      return true;
    } catch (e, stackTrace) {
      developer.log(
        'Error updating FAQ',
        error: e,
        stackTrace: stackTrace,
      );
      _error = _formatErrorMessage(e);
      return false;
    }
  }

  /// Deletes an FAQ from the knowledge base.
  Future<bool> deleteFaq(String faqId) async {
    if (_currentUser == null) {
      _error = 'No authenticated user found.';
      notifyListeners();
      return false;
    }

    try {
      await _userRepository.deleteFaq(
        userId: _currentUser!.uid,
        faqId: faqId,
      );

      _currentUser = _currentUser!.copyWith(
        faqsCount: _currentUser!.faqsCount - 1,
      );
      notifyListeners();

      _syncKnowledgeBaseCounts();
      return true;
    } catch (e, stackTrace) {
      developer.log(
        'Error deleting FAQ',
        error: e,
        stackTrace: stackTrace,
      );
      _error = _formatErrorMessage(e);
      return false;
    }
  }

  /// Loads FAQs for the current user.
  Future<List<FaqModel>> loadFaqs() async {
    if (_currentUser == null) return [];
    try {
      return await _userRepository.getFaqs(_currentUser!.uid);
    } catch (e, stackTrace) {
      developer.log(
        'Error loading FAQs',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  /// Saves knowledge base and completes onboarding (Screen 7).
  /// Called when user presses Continue on KnowledgeBaseScreen.
  Future<bool> saveKnowledgeBase() async {
    if (_currentUser == null) {
      _error = 'No authenticated user found.';
      notifyListeners();
      return false;
    }

    final hasKnowledge = _currentUser!.productsCount > 0 ||
        _currentUser!.documentsCount > 0 ||
        _currentUser!.faqsCount > 0;

    if (!hasKnowledge) {
      _error = 'Please add at least one product, document, or FAQ.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _userRepository.updateKnowledgeBaseCounts(
        userId: _currentUser!.uid,
        productsCount: _currentUser!.productsCount,
        documentsCount: _currentUser!.documentsCount,
        faqsCount: _currentUser!.faqsCount,
        onboardingStep: 8,
        onboardingComplete: true,
      );

      _currentUser = _currentUser!.copyWith(
        onboardingStep: 8,
        onboardingComplete: true,
      );

      return true;
    } catch (e, stackTrace) {
      developer.log(
        'Error saving knowledge base',
        error: e,
        stackTrace: stackTrace,
      );
      _error = _formatErrorMessage(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _syncKnowledgeBaseCounts() {
    if (_currentUser == null) return;
    _userRepository
        .updateKnowledgeBaseCounts(
          userId: _currentUser!.uid,
          productsCount: _currentUser!.productsCount,
          documentsCount: _currentUser!.documentsCount,
          faqsCount: _currentUser!.faqsCount,
          onboardingStep: _currentUser!.onboardingStep,
          onboardingComplete: _currentUser!.onboardingComplete,
        )
        .catchError((error, stackTrace) {
      developer.log(
        'Firestore sync failed for knowledge base counts (will retry when online)',
        error: error,
        stackTrace: stackTrace,
      );
    });
  }

  /// Clears current user data on logout.
  void clearUserData() {
    if (_currentUser == null && _error == null && _errorType == UserProviderErrorType.none) return;

    _currentUser = null;
    _error = null;
    _errorType = UserProviderErrorType.none;
    notifyListeners();
  }

  String _formatErrorMessage(dynamic error) {
    final errorString = error.toString();

    if (errorString.startsWith('Exception: ')) {
      return errorString.replaceFirst('Exception: ', '');
    }

    return errorString;
  }
}