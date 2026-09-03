import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

import '../model/call_model.dart';
import '../repository/call_repository.dart';

class CallProvider extends ChangeNotifier {
  final CallRepository _repository;

  List<CallModel> _recentCalls = <CallModel>[];
  List<CallModel> _customerCallHistory = <CallModel>[];
  bool _isLoadingRecentCalls = false;
  bool _isLoadingTodayCalls = false;
  bool _isLoadingCustomerHistory = false;
  String? _recentCallsError;
  String? _todayCallsError;
  String? _customerHistoryError;
  int _todayCallsCount = 0;

  CallProvider({CallRepository? repository})
      : _repository = repository ?? CallRepository();

  List<CallModel> get recentCalls => List.unmodifiable(_recentCalls);
  List<CallModel> get customerCallHistory => List.unmodifiable(_customerCallHistory);

  bool get isLoading => _isLoadingRecentCalls || _isLoadingTodayCalls || _isLoadingCustomerHistory;

  bool get isLoadingRecentCalls => _isLoadingRecentCalls;

  bool get isLoadingTodayCalls => _isLoadingTodayCalls;

  bool get isLoadingCustomerHistory => _isLoadingCustomerHistory;

  String? get error => _recentCallsError ?? _todayCallsError ?? _customerHistoryError;

  String? get recentCallsError => _recentCallsError;

  String? get todayCallsError => _todayCallsError;

  String? get customerHistoryError => _customerHistoryError;

  int get todayCallsCount => _todayCallsCount;

  Future<void> loadRecentCalls({int limit = 10}) async {
    if (_isLoadingRecentCalls) return;

    _isLoadingRecentCalls = true;
    _recentCallsError = null;
    notifyListeners();

    try {
      _recentCalls = await _repository.fetchRecentCalls(limit: limit);
    } catch (e, stackTrace) {
      developer.log(
        'Error loading recent calls',
        error: e,
        stackTrace: stackTrace,
      );

      _recentCallsError = _cleanErrorMessage(e);
    } finally {
      _isLoadingRecentCalls = false;
      notifyListeners();
    }
  }

  Future<void> loadTodaysCalls() async {
    if (_isLoadingTodayCalls) return;

    _isLoadingTodayCalls = true;
    _todayCallsError = null;
    notifyListeners();

    try {
      _todayCallsCount = await _repository.getTodaysCallsCount();
    } catch (e, stackTrace) {
      developer.log(
        'Error loading today\'s call count',
        error: e,
        stackTrace: stackTrace,
      );

      _todayCallsError = _cleanErrorMessage(e);
    } finally {
      _isLoadingTodayCalls = false;
      notifyListeners();
    }
  }

  Future<void> loadCustomerCallHistory({
    required String customerId,
    required String phoneNumber,
    int limit = 50,
  }) async {
    if (_isLoadingCustomerHistory) return;

    _isLoadingCustomerHistory = true;
    _customerHistoryError = null;
    notifyListeners();

    try {
      _customerCallHistory = await _repository.fetchCallsForCustomer(
        customerId: customerId,
        phoneNumber: phoneNumber,
        limit: limit,
      );
    } catch (e, stackTrace) {
      developer.log(
        'Error loading customer call history',
        error: e,
        stackTrace: stackTrace,
      );

      _customerHistoryError = _cleanErrorMessage(e);
    } finally {
      _isLoadingCustomerHistory = false;
      notifyListeners();
    }
  }

  void clearCustomerCallHistory() {
    _customerCallHistory = <CallModel>[];
    _customerHistoryError = null;
    notifyListeners();
  }

  Future<void> refresh({int recentLimit = 10}) async {
    await Future.wait<void>([
      loadRecentCalls(limit: recentLimit),
      loadTodaysCalls(),
    ]);
  }

  void clearError() {
    if (_recentCallsError == null && _todayCallsError == null && _customerHistoryError == null) {
      return;
    }

    _recentCallsError = null;
    _todayCallsError = null;
    _customerHistoryError = null;
    notifyListeners();
  }

  void clearCalls() {
    _recentCalls = <CallModel>[];
    _customerCallHistory = <CallModel>[];
    _todayCallsCount = 0;
    _recentCallsError = null;
    _todayCallsError = null;
    _customerHistoryError = null;
    _isLoadingRecentCalls = false;
    _isLoadingTodayCalls = false;
    _isLoadingCustomerHistory = false;
    notifyListeners();
  }

  String _cleanErrorMessage(dynamic error) {
    final errorString = error.toString();

    if (errorString.startsWith('Exception: ')) {
      return errorString.replaceFirst('Exception: ', '');
    }

    return errorString;
  }
}