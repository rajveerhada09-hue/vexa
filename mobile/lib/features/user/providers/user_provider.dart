import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

import '../model/user_model.dart';
import '../repository/user_repository.dart';

class UserProvider extends ChangeNotifier {
  final UserRepository _userRepository;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserProvider({UserRepository? userRepository})
      : _userRepository = userRepository ?? UserRepository();

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Loads the currently authenticated user's Firestore data.
  Future<void> loadCurrentUser() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _userRepository.getCurrentUser();
    } catch (e, stackTrace) {
      developer.log(
        'Error loading current user',
        error: e,
        stackTrace: stackTrace,
      );

      _error = _formatErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Saves the personality selected on onboarding Screen 2.
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
      await _userRepository.updateAiPersonality(
        userId: _currentUser!.uid,
        aiPersonality: personality,
        customAiPersonality: trimmedCustomInstructions,
      );

      _currentUser = _currentUser!.copyWith(
        aiPersonality: personality,
        customAiPersonality:
            personality == 'custom' ? trimmedCustomInstructions : null,
        onboardingStep: 3,
        onboardingComplete: false,
      );

      return true;
    } catch (e, stackTrace) {
      developer.log(
        'Error saving AI personality',
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

  /// Saves business info on onboarding Screen 3.
  Future<bool> saveBusinessInfo({
    required String businessName,
    required String businessType,
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

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _userRepository.updateBusinessInfo(
        userId: _currentUser!.uid,
        businessName: businessName.trim(),
        businessType: businessType.trim(),
      );

      _currentUser = _currentUser!.copyWith(
        businessName: businessName.trim(),
        businessType: businessType.trim(),
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

  /// Clears current user data on logout.
  void clearUserData() {
    if (_currentUser == null && _error == null) return;

    _currentUser = null;
    _error = null;
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