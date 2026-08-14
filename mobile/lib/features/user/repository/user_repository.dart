import 'dart:developer' as developer;
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../model/user_model.dart';
import '../model/product_model.dart';
import '../model/knowledge_document_model.dart';
import '../model/faq_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  UserRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// Generates a new unique document ID for Firestore collections.
  String firestoreCollectionId() {
    return _firestore.collection('temp').doc().id;
  }

  /// Fetches a user by their Firestore UID.
  Future<UserModel?> getUserById(String uid) async {
    try {
      final docSnapshot =
          await _firestore.collection('users').doc(uid).get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        return UserModel.fromMap(
          docSnapshot.data() as Map<String, dynamic>,
        );
      }

      return null;
    } on FirebaseException catch (e, stackTrace) {
      developer.log(
        'FirebaseException in getUserById',
        error: e,
        stackTrace: stackTrace,
      );

      throw Exception(
        e.message ??
            'A database error occurred while fetching user data.',
      );
    } catch (e, stackTrace) {
      developer.log(
        'Unknown Exception in getUserById',
        error: e,
        stackTrace: stackTrace,
      );

      throw Exception(
        'An unexpected error occurred while fetching user data.',
      );
    }
  }

  /// Fetches the currently authenticated user.
  Future<UserModel?> getCurrentUser() async {
    try {
      final User? currentUser = _auth.currentUser;

      if (currentUser == null) {
        return null;
      }

      return await getUserById(currentUser.uid);
    } catch (e, stackTrace) {
      developer.log(
        'Exception in getCurrentUser',
        error: e,
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  /// Saves Vexa's AI personality and moves onboarding to Screen 3.
  Future<void> updateAiPersonality({
    required String userId,
    required String aiPersonality,
    String? customAiPersonality,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'aiPersonality': aiPersonality,

        // Screen 2 completed.
        // The next screen is onboarding step 3.
        'onboardingStep': 3,
        'onboardingComplete': false,

        'updatedAt': FieldValue.serverTimestamp(),
      };

      final trimmedCustom = customAiPersonality?.trim();

      if (aiPersonality == 'custom' &&
          trimmedCustom != null &&
          trimmedCustom.isNotEmpty) {
        data['customAiPersonality'] = trimmedCustom;
      } else {
        data['customAiPersonality'] = FieldValue.delete();
      }

await _firestore
          .collection('users')
          .doc(userId)
          .set(
            data,
            SetOptions(merge: true),
          );
  } on FirebaseException catch (e, stackTrace) {
    developer.log(
      'FirebaseException in updateAiPersonality',
      error: e,
      stackTrace: stackTrace,
    );

    throw Exception(
      e.message ??
          'A database error occurred while saving AI personality.',
    );
  } catch (e, stackTrace) {
    developer.log(
      'Unknown Exception in updateAiPersonality',
      error: e,
      stackTrace: stackTrace,
    );

    throw Exception(
      'An unexpected error occurred while saving AI personality.',
    );
  }
}

/// Saves business info and moves onboarding to Screen 4.
  Future<void> updateBusinessInfo({
    required String userId,
    required String businessName,
    required String businessType,
    required String businessOpeningTime,
    required String businessClosingTime,
    required String businessTimeZone,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'businessName': businessName,
        'businessType': businessType,
        'businessOpeningTime': businessOpeningTime,
        'businessClosingTime': businessClosingTime,
        'businessTimeZone': businessTimeZone,

        // Screen 3 completed.
        // The next screen is onboarding step 4.
        'onboardingStep': 4,
        'onboardingComplete': false,

        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('users')
          .doc(userId)
          .set(
            data,
            SetOptions(merge: true),
          );
    } on FirebaseException catch (e, stackTrace) {
      developer.log(
        'FirebaseException in updateBusinessInfo',
        error: e,
        stackTrace: stackTrace,
      );

      throw Exception(
        e.message ??
            'A database error occurred while saving business info.',
      );
    } catch (e, stackTrace) {
      developer.log(
        'Unknown Exception in updateBusinessInfo',
        error: e,
        stackTrace: stackTrace,
      );

      throw Exception(
        'An unexpected error occurred while saving business info.',
      );
    }
  }

  /// Saves language preference and moves onboarding to Screen 5.
  Future<void> updateLanguagePreference({
    required String userId,
    required String languagePreference,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'languagePreference': languagePreference,

        // Screen 4 completed.
        // The next screen is onboarding step 5.
        'onboardingStep': 5,
        'onboardingComplete': false,

        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('users')
          .doc(userId)
          .set(
            data,
            SetOptions(merge: true),
          );
    } on FirebaseException catch (e, stackTrace) {
      developer.log(
        'FirebaseException in updateLanguagePreference',
        error: e,
        stackTrace: stackTrace,
      );

      throw Exception(
        e.message ??
            'A database error occurred while saving language preference.',
      );
    } catch (e, stackTrace) {
      developer.log(
        'Unknown Exception in updateLanguagePreference',
        error: e,
        stackTrace: stackTrace,
      );

      throw Exception(
        'An unexpected error occurred while saving language preference.',
      );
    }
  }

  /// Saves voice preference and moves onboarding to Screen 6.
  Future<void> updateVoicePreference({
    required String userId,
    required String voicePreference,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'voicePreference': voicePreference,

        // Screen 5 completed.
        // The next screen is onboarding step 6.
        'onboardingStep': 6,
        'onboardingComplete': false,

        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('users')
          .doc(userId)
          .set(
            data,
            SetOptions(merge: true),
          );
    } on FirebaseException catch (e, stackTrace) {
      developer.log(
        'FirebaseException in updateVoicePreference',
        error: e,
        stackTrace: stackTrace,
      );

      throw Exception(
        e.message ??
            'A database error occurred while saving voice preference.',
      );
    } catch (e, stackTrace) {
      developer.log(
        'Unknown Exception in updateVoicePreference',
        error: e,
        stackTrace: stackTrace,
      );

      throw Exception(
        'An unexpected error occurred while saving voice preference.',
      );
    }
  }

  /// Saves greeting template and moves onboarding to Screen 7.
  Future<void> updateGreetingTemplate({
    required String userId,
    required String greetingTemplate,
    String? customGreeting,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'greetingTemplate': greetingTemplate,

        // Screen 6 completed.
        // The next screen is onboarding step 7.
        'onboardingStep': 7,
        'onboardingComplete': false,

        'updatedAt': FieldValue.serverTimestamp(),
      };

      final trimmedCustom = customGreeting?.trim();

      if (greetingTemplate == 'custom' &&
          trimmedCustom != null &&
          trimmedCustom.isNotEmpty) {
        data['customGreeting'] = trimmedCustom;
      } else {
        data['customGreeting'] = FieldValue.delete();
      }

      await _firestore
          .collection('users')
          .doc(userId)
          .set(
            data,
            SetOptions(merge: true),
          );
    } on FirebaseException catch (e, stackTrace) {
      developer.log(
        'FirebaseException in updateGreetingTemplate',
        error: e,
        stackTrace: stackTrace,
      );

      throw Exception(
        e.message ??
            'An unexpected error occurred while saving greeting template.',
      );
    } catch (e, stackTrace) {
      developer.log(
        'Unknown Exception in updateGreetingTemplate',
        error: e,
        stackTrace: stackTrace,
      );

      throw Exception(
        'An unexpected error occurred while saving greeting template.',
      );
    }
  }

  /// Saves a product to Firestore subcollection.
  Future<void> addProduct({
    required String userId,
    required ProductModel product,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('products')
          .doc(product.id)
          .set(product.toMap());
    } on FirebaseException catch (e, stackTrace) {
      developer.log(
        'FirebaseException in addProduct',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception(
        e.message ?? 'A database error occurred while saving product.',
      );
    } catch (e, stackTrace) {
      developer.log(
        'Unknown Exception in addProduct',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception(
        'An unexpected error occurred while saving product.',
      );
    }
  }

  /// Updates a product in Firestore subcollection.
  Future<void> updateProduct({
    required String userId,
    required ProductModel product,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('products')
          .doc(product.id)
          .set(product.toMap());
    } on FirebaseException catch (e, stackTrace) {
      developer.log(
        'FirebaseException in updateProduct',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception(
        e.message ?? 'A database error occurred while updating product.',
      );
    } catch (e, stackTrace) {
      developer.log(
        'Unknown Exception in updateProduct',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception(
        'An unexpected error occurred while updating product.',
      );
    }
  }

  /// Deletes a product from Firestore subcollection.
  Future<void> deleteProduct({
    required String userId,
    required String productId,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('products')
          .doc(productId)
          .delete();
    } on FirebaseException catch (e, stackTrace) {
      developer.log(
        'FirebaseException in deleteProduct',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception(
        e.message ?? 'A database error occurred while deleting product.',
      );
    } catch (e, stackTrace) {
      developer.log(
        'Unknown Exception in deleteProduct',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception(
        'An unexpected error occurred while deleting product.',
      );
    }
  }

  /// Fetches all products for a user.
  Future<List<ProductModel>> getProducts(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('products')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.id, doc.data()))
          .toList();
    } on FirebaseException catch (e, stackTrace) {
      developer.log(
        'FirebaseException in getProducts',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception(
        e.message ?? 'A database error occurred while fetching products.',
      );
    } catch (e, stackTrace) {
      developer.log(
        'Unknown Exception in getProducts',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception(
        'An unexpected error occurred while fetching products.',
      );
    }
  }

  /// Uploads a document file to Firebase Storage and saves metadata to Firestore.
  Future<KnowledgeDocumentModel> uploadDocument({
    required String userId,
    required String fileName,
    required DocumentType documentType,
    required String mimeType,
    required int fileSize,
    required String localFilePath,
  }) async {
    try {
      final documentId = _firestore
          .collection('users')
          .doc(userId)
          .collection('knowledgeDocuments')
          .doc()
          .id;

      final storagePath = 'users/$userId/knowledgeDocuments/$documentId/${fileName.replaceAll(' ', '_')}';
      final storageRef = FirebaseStorage.instance.ref().child(storagePath);

      final uploadTask = storageRef.putFile(File(localFilePath));
      final snapshot = await uploadTask;

      final downloadUrl = await snapshot.ref.getDownloadURL();

      final now = DateTime.now();
      final document = KnowledgeDocumentModel(
        id: documentId,
        fileName: fileName,
        documentType: documentType,
        storagePath: storagePath,
        downloadUrl: downloadUrl,
        fileSize: fileSize,
        mimeType: mimeType,
        uploadStatus: UploadStatus.completed,
        createdAt: now,
        updatedAt: now,
      );

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('knowledgeDocuments')
          .doc(documentId)
          .set(document.toMap());

      return document;
    } on FirebaseException catch (e, stackTrace) {
      developer.log(
        'FirebaseException in uploadDocument',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception(
        e.message ?? 'A database error occurred while uploading document.',
      );
    } catch (e, stackTrace) {
      developer.log(
        'Unknown Exception in uploadDocument',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception(
        'An unexpected error occurred while uploading document.',
      );
    }
  }

  /// Deletes a document from Firebase Storage and Firestore.
  Future<void> deleteDocument({
    required String userId,
    required String documentId,
    required String storagePath,
  }) async {
    try {
      await FirebaseStorage.instance.ref().child(storagePath).delete();

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('knowledgeDocuments')
          .doc(documentId)
          .delete();
    } on FirebaseException catch (e, stackTrace) {
      developer.log(
        'FirebaseException in deleteDocument',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception(
        e.message ?? 'A database error occurred while deleting document.',
      );
    } catch (e, stackTrace) {
      developer.log(
        'Unknown Exception in deleteDocument',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception(
        'An unexpected error occurred while deleting document.',
      );
    }
  }

  /// Fetches all documents for a user.
  Future<List<KnowledgeDocumentModel>> getDocuments(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('knowledgeDocuments')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => KnowledgeDocumentModel.fromMap(doc.id, doc.data()))
          .toList();
    } on FirebaseException catch (e, stackTrace) {
      developer.log(
        'FirebaseException in getDocuments',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception(
        e.message ?? 'A database error occurred while fetching documents.',
      );
    } catch (e, stackTrace) {
      developer.log(
        'Unknown Exception in getDocuments',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception(
        'An unexpected error occurred while fetching documents.',
      );
    }
  }

  /// Adds an FAQ to Firestore subcollection.
  Future<void> addFaq({
    required String userId,
    required FaqModel faq,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('faqs')
          .doc(faq.id)
          .set(faq.toMap());
    } on FirebaseException catch (e, stackTrace) {
      developer.log(
        'FirebaseException in addFaq',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception(
        e.message ?? 'A database error occurred while saving FAQ.',
      );
    } catch (e, stackTrace) {
      developer.log(
        'Unknown Exception in addFaq',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception(
        'An unexpected error occurred while saving FAQ.',
      );
    }
  }

  /// Updates an FAQ in Firestore subcollection.
  Future<void> updateFaq({
    required String userId,
    required FaqModel faq,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('faqs')
          .doc(faq.id)
          .set(faq.toMap());
    } on FirebaseException catch (e, stackTrace) {
      developer.log(
        'FirebaseException in updateFaq',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception(
        e.message ?? 'A database error occurred while updating FAQ.',
      );
    } catch (e, stackTrace) {
      developer.log(
        'Unknown Exception in updateFaq',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception(
        'An unexpected error occurred while updating FAQ.',
      );
    }
  }

  /// Deletes an FAQ from Firestore subcollection.
  Future<void> deleteFaq({
    required String userId,
    required String faqId,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('faqs')
          .doc(faqId)
          .delete();
    } on FirebaseException catch (e, stackTrace) {
      developer.log(
        'FirebaseException in deleteFaq',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception(
        e.message ?? 'A database error occurred while deleting FAQ.',
      );
    } catch (e, stackTrace) {
      developer.log(
        'Unknown Exception in deleteFaq',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception(
        'An unexpected error occurred while deleting FAQ.',
      );
    }
  }

  /// Fetches all FAQs for a user.
  Future<List<FaqModel>> getFaqs(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('faqs')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => FaqModel.fromMap(doc.id, doc.data()))
          .toList();
    } on FirebaseException catch (e, stackTrace) {
      developer.log(
        'FirebaseException in getFaqs',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception(
        e.message ?? 'A database error occurred while fetching FAQs.',
      );
    } catch (e, stackTrace) {
      developer.log(
        'Unknown Exception in getFaqs',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception(
        'An unexpected error occurred while fetching FAQs.',
      );
    }
  }

  /// Updates user's knowledge base counts and onboarding step.
  Future<void> updateKnowledgeBaseCounts({
    required String userId,
    required int productsCount,
    required int documentsCount,
    required int faqsCount,
    required int onboardingStep,
    required bool onboardingComplete,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .set({
        'productsCount': productsCount,
        'documentsCount': documentsCount,
        'faqsCount': faqsCount,
        'onboardingStep': onboardingStep,
        'onboardingComplete': onboardingComplete,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } on FirebaseException catch (e, stackTrace) {
      developer.log(
        'FirebaseException in updateKnowledgeBaseCounts',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception(
        e.message ?? 'A database error occurred while updating knowledge base counts.',
      );
    } catch (e, stackTrace) {
      developer.log(
        'Unknown Exception in updateKnowledgeBaseCounts',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception(
        'An unexpected error occurred while updating knowledge base counts.',
      );
    }
  }
}