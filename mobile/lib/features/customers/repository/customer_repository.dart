import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/customer_model.dart';

class CustomerRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CustomerRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> _customersCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('customers');
  }

  String? get currentUserId => _auth.currentUser?.uid;

  String _generateCustomerId() {
    return _firestore.collection('temp').doc().id;
  }

  Future<List<CustomerModel>> fetchCustomers({int limit = 20}) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        developer.log('fetchCustomers called when user is not authenticated');
        return [];
      }

      final snapshot = await _customersCollection(userId)
          .orderBy('updatedAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => CustomerModel.fromMap(doc.id, doc.data()))
          .toList();
    } on FirebaseException catch (e, stackTrace) {
      developer.log(
        'FirebaseException in fetchCustomers',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception(
        e.message ?? 'A database error occurred while fetching customers.',
      );
    } catch (e, stackTrace) {
      developer.log(
        'Unexpected Exception in fetchCustomers',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('An unexpected error occurred while fetching customers.');
    }
  }

  Future<List<CustomerModel>> fetchRecentCustomers({int limit = 5}) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        developer.log('fetchRecentCustomers called when user is not authenticated');
        return [];
      }

      final snapshot = await _customersCollection(userId)
          .orderBy('updatedAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => CustomerModel.fromMap(doc.id, doc.data()))
          .toList();
    } on FirebaseException catch (e, stackTrace) {
      developer.log(
        'FirebaseException in fetchRecentCustomers',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception(
        e.message ?? 'A database error occurred while fetching recent customers.',
      );
    } catch (e, stackTrace) {
      developer.log(
        'Unexpected Exception in fetchRecentCustomers',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('An unexpected error occurred while fetching recent customers.');
    }
  }

  Future<CustomerModel?> fetchCustomerById(String id) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        developer.log('fetchCustomerById called when user is not authenticated');
        return null;
      }

      final doc = await _customersCollection(userId).doc(id).get();

      if (!doc.exists || doc.data() == null) {
        return null;
      }

      return CustomerModel.fromMap(doc.id, doc.data()!);
    } on FirebaseException catch (e, stackTrace) {
      developer.log(
        'FirebaseException in fetchCustomerById',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception(
        e.message ?? 'A database error occurred while fetching customer.',
      );
    } catch (e, stackTrace) {
      developer.log(
        'Unexpected Exception in fetchCustomerById',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('An unexpected error occurred while fetching customer.');
    }
  }

  Future<String> createCustomer({
    required String userId,
    required String name,
    required String phoneNumber,
    String? email,
    String? company,
    String? notes,
  }) async {
    try {
      if (userId.isEmpty) {
        developer.log('createCustomer called when user is not authenticated');
        throw Exception('User not authenticated');
      }

      final customerId = _generateCustomerId();
      final now = DateTime.now();

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
        createdAt: now,
        updatedAt: now,
      );

      await _customersCollection(userId).doc(customerId).set(customer.toMap());

      return customerId;
    } on FirebaseException catch (e, stackTrace) {
      developer.log(
        'FirebaseException in createCustomer',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception(
        e.message ?? 'A database error occurred while creating customer.',
      );
    } catch (e, stackTrace) {
      developer.log(
        'Unexpected Exception in createCustomer',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('An unexpected error occurred while creating customer.');
    }
  }

  Future<void> updateCustomer(CustomerModel customer) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        developer.log('updateCustomer called when user is not authenticated');
        throw Exception('User not authenticated');
      }

      if (customer.userId != userId) {
        throw Exception('Cannot update customer for another user');
      }

      await _customersCollection(userId).doc(customer.id).update(customer.toMap());
    } on FirebaseException catch (e, stackTrace) {
      developer.log(
        'FirebaseException in updateCustomer',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception(
        e.message ?? 'A database error occurred while updating customer.',
      );
    } catch (e, stackTrace) {
      developer.log(
        'Unexpected Exception in updateCustomer',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('An unexpected error occurred while updating customer.');
    }
  }

  Future<void> deleteCustomer(String id) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        developer.log('deleteCustomer called when user is not authenticated');
        throw Exception('User not authenticated');
      }

      await _customersCollection(userId).doc(id).delete();
    } on FirebaseException catch (e, stackTrace) {
      developer.log(
        'FirebaseException in deleteCustomer',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception(
        e.message ?? 'A database error occurred while deleting customer.',
      );
    } catch (e, stackTrace) {
      developer.log(
        'Unexpected Exception in deleteCustomer',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('An unexpected error occurred while deleting customer.');
    }
  }
}