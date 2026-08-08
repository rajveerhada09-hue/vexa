import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

import '../model/dashboard_model.dart';
import '../repository/dashboard_repository.dart';

class DashboardProvider extends ChangeNotifier {
  final DashboardRepository _repository;

  DashboardModel? _dashboard;
  bool _isLoading = false;
  String? _error;

  DashboardProvider({DashboardRepository? repository})
      : _repository = repository ?? DashboardRepository();

  DashboardModel? get dashboard => _dashboard;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadDashboard() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _dashboard = await _repository.getDashboard();
    } catch (e, stackTrace) {
      developer.log(
        'Error loading dashboard data',
        error: e,
        stackTrace: stackTrace,
      );
      _error = _cleanErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearDashboard() {
    if (_dashboard == null && _error == null) return;
    
    _dashboard = null;
    _error = null;
    notifyListeners();
  }

  String _cleanErrorMessage(dynamic error) {
    final errStr = error.toString();
    if (errStr.startsWith('Exception: ')) {
      return errStr.replaceFirst('Exception: ', '');
    }
    return errStr;
  }
}