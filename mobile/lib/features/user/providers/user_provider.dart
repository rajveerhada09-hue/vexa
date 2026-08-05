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

  /// Loads the current authenticated user's data from Firestore
  Future<void> loadCurrentUser() async {
    if (_isLoading) return; // Prevent concurrent/duplicate network calls

    _isLoading = true;
    _error = null;
    notifyListeners(); // First UI update: Trigger loading state and clear old errors

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
      notifyListeners(); // Second UI update: Trigger data rendering or error display simultaneously with loading ending
    }
  }

  /// Clears the current user data (Useful for logout scenarios)
  void clearUserData() {
    // Only notify if there's actual state to clear to prevent unnecessary rebuilds
    if (_currentUser == null && _error == null) return;
    
    _currentUser = null;
    _error = null;
    notifyListeners();
  }

  /// Helper to clean up exception prefixes for UI display
  String _formatErrorMessage(dynamic error) {
    final errorString = error.toString();
    if (errorString.startsWith('Exception: ')) {
      return errorString.replaceFirst('Exception: ', '');
    }
    return errorString;
  }
}