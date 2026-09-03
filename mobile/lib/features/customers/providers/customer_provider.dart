import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import '../model/customer_model.dart';
import '../repository/customer_repository.dart';

class CustomerProvider extends ChangeNotifier {
  final CustomerRepository _repository;

  List<CustomerModel> _customers = <CustomerModel>[];
  CustomerModel? _selectedCustomer;
  bool _isLoadingCustomers = false;
  bool _isSaving = false;
  String? _customersError;
  String? _saveError;

  CustomerProvider({CustomerRepository? repository})
      : _repository = repository ?? CustomerRepository();

  List<CustomerModel> get customers => List.unmodifiable(_customers);
  CustomerModel? get selectedCustomer => _selectedCustomer;

  bool get isLoading => _isLoadingCustomers || _isSaving;
  bool get isLoadingCustomers => _isLoadingCustomers;
  bool get isSaving => _isSaving;

  String? get error => _customersError ?? _saveError;
  String? get customersError => _customersError;
  String? get saveError => _saveError;

  Future<void> loadCustomers({int limit = 20}) async {
    if (_isLoadingCustomers) return;

    _isLoadingCustomers = true;
    _customersError = null;
    notifyListeners();

    try {
      _customers = await _repository.fetchCustomers(limit: limit);
    } catch (e, stackTrace) {
      developer.log(
        'Error loading customers',
        error: e,
        stackTrace: stackTrace,
      );

      _customersError = _cleanErrorMessage(e);
    } finally {
      _isLoadingCustomers = false;
      notifyListeners();
    }
  }

  Future<void> loadRecentCustomers({int limit = 5}) async {
    if (_isLoadingCustomers) return;

    _isLoadingCustomers = true;
    _customersError = null;
    notifyListeners();

    try {
      _customers = await _repository.fetchRecentCustomers(limit: limit);
    } catch (e, stackTrace) {
      developer.log(
        'Error loading recent customers',
        error: e,
        stackTrace: stackTrace,
      );

      _customersError = _cleanErrorMessage(e);
    } finally {
      _isLoadingCustomers = false;
      notifyListeners();
    }
  }

  Future<void> selectCustomer(String id) async {
    if (_selectedCustomer?.id == id) return;

    try {
      final customer = await _repository.fetchCustomerById(id);
      if (customer != null) {
        _selectedCustomer = customer;
        notifyListeners();
      }
    } catch (e, stackTrace) {
      developer.log(
        'Error selecting customer',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> loadCustomerForDetail(String id) async {
    if (_selectedCustomer?.id == id) return;

    _isLoadingCustomers = true;
    notifyListeners();

    try {
      final customer = await _repository.fetchCustomerById(id);
      if (customer != null) {
        _selectedCustomer = customer;
      }
    } catch (e, stackTrace) {
      developer.log(
        'Error loading customer for detail',
        error: e,
        stackTrace: stackTrace,
      );
    } finally {
      _isLoadingCustomers = false;
      notifyListeners();
    }
  }

  void clearSelectedCustomer() {
    _selectedCustomer = null;
    notifyListeners();
  }

  Future<bool> createCustomer({
    required String name,
    required String phoneNumber,
    String? email,
    String? company,
    String? notes,
  }) async {
    if (_isSaving) return false;

    _isSaving = true;
    _saveError = null;
    notifyListeners();

    try {
      final userId = _repository.currentUserId;
      if (userId == null || userId.isEmpty) {
        throw Exception('User not authenticated');
      }

      final customerId = await _repository.createCustomer(
        userId: userId,
        name: name,
        phoneNumber: phoneNumber,
        email: email,
        company: company,
        notes: notes,
      );

      final customer = CustomerModel(
        id: customerId,
        userId: userId,
        name: name,
        phoneNumber: phoneNumber,
        email: email,
        company: company,
        notes: notes,
        totalCalls: 0,
        lastCallAt: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _customers.insert(0, customer);
      _selectedCustomer = customer;
      return true;
    } catch (e, stackTrace) {
      developer.log(
        'Error creating customer',
        error: e,
        stackTrace: stackTrace,
      );

      _saveError = _cleanErrorMessage(e);
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> updateCustomer(CustomerModel customer) async {
    if (_isSaving) return false;

    _isSaving = true;
    _saveError = null;
    notifyListeners();

    try {
      await _repository.updateCustomer(customer);

      final index = _customers.indexWhere((c) => c.id == customer.id);
      if (index != -1) {
        _customers[index] = customer;
      }

      if (_selectedCustomer?.id == customer.id) {
        _selectedCustomer = customer;
      }

      return true;
    } catch (e, stackTrace) {
      developer.log(
        'Error updating customer',
        error: e,
        stackTrace: stackTrace,
      );

      _saveError = _cleanErrorMessage(e);
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> deleteCustomer(String id) async {
    if (_isSaving) return false;

    _isSaving = true;
    _saveError = null;
    notifyListeners();

    try {
      await _repository.deleteCustomer(id);
      _customers.removeWhere((c) => c.id == id);

      if (_selectedCustomer?.id == id) {
        _selectedCustomer = null;
      }

      return true;
    } catch (e, stackTrace) {
      developer.log(
        'Error deleting customer',
        error: e,
        stackTrace: stackTrace,
      );

      _saveError = _cleanErrorMessage(e);
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await loadCustomers();
  }

  void clearError() {
    if (_customersError == null && _saveError == null) return;

    _customersError = null;
    _saveError = null;
    notifyListeners();
  }

  void clearCustomers() {
    _customers = <CustomerModel>[];
    _selectedCustomer = null;
    _customersError = null;
    _saveError = null;
    _isLoadingCustomers = false;
    _isSaving = false;
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