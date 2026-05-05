import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/transaction_model.dart';

abstract class TransactionRemoteDatasource {
  Future<void> save(TransactionModel model);

  Future<void> update(TransactionModel model);

  Future<void> delete(String id);

  Future<void> uploadAll(List<TransactionModel> transactions);

  Future<List<TransactionModel>> fetchAllFromFirestore();
}

class FirestoreTransactionDatasource implements TransactionRemoteDatasource {
  FirestoreTransactionDatasource({
    FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  @override
  Future<void> save(TransactionModel model) {
    return _transactionsCollection.doc(model.id).set(_toJson(model));
  }

  @override
  Future<void> update(TransactionModel model) {
    return _transactionsCollection.doc(model.id).update(_toJson(model));
  }

  @override
  Future<void> delete(String id) {
    return _transactionsCollection.doc(id).delete();
  }

  @override
  Future<void> uploadAll(List<TransactionModel> transactions) async {
    if (transactions.isEmpty) {
      return;
    }

    final WriteBatch batch = _firestore.batch();
    for (final TransactionModel transaction in transactions) {
      batch.set(_transactionsCollection.doc(transaction.id), _toJson(transaction));
    }
    await batch.commit();
  }

  @override
  Future<List<TransactionModel>> fetchAllFromFirestore() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await _transactionsCollection.get();

    return snapshot.docs.map(_fromDocument).toList();
  }

  CollectionReference<Map<String, dynamic>> get _transactionsCollection {
    final String? userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) {
      throw StateError('No authenticated user for Firestore sync');
    }

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions');
  }

  Map<String, dynamic> _toJson(TransactionModel model) {
    return <String, dynamic>{
      'id': model.id,
      'amount': model.amount,
      'categoryKey': model.categoryKey,
      'type': model.type.name,
      'date': Timestamp.fromDate(model.date),
      'note': model.note,
    };
  }

  TransactionModel _fromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final Map<String, dynamic> data = document.data();

    return TransactionModel(
      id: data['id'] as String? ?? document.id,
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      categoryKey: data['categoryKey'] as String?,
      type: data['type'] as String? ?? 'expense',
      date: _dateFromFirestoreValue(data['date']),
      note: data['note'] as String?,
    );
  }

  DateTime _dateFromFirestoreValue(Object? value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }
}
