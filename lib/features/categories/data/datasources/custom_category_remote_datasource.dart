import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/custom_category_model.dart';

abstract class CustomCategoryRemoteDatasource {
  Future<void> save(CustomCategoryModel model);

  Future<void> delete(String id);
}

class FirestoreCustomCategoryDatasource
    implements CustomCategoryRemoteDatasource {
  FirestoreCustomCategoryDatasource({
    FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  @override
  Future<void> save(CustomCategoryModel model) {
    return _categoriesCollection.doc(model.id).set(_toJson(model));
  }

  @override
  Future<void> delete(String id) {
    return _categoriesCollection.doc(id).delete();
  }

  CollectionReference<Map<String, dynamic>> get _categoriesCollection {
    final String? userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) {
      throw StateError('No authenticated user for category sync');
    }

    return _firestore.collection('users').doc(userId).collection('categories');
  }

  Map<String, dynamic> _toJson(CustomCategoryModel model) {
    return <String, dynamic>{
      'id': model.id,
      'label': model.label,
      'colorValue': model.colorValue,
      'iconCodePoint': model.iconCodePoint,
      'fontFamily': model.fontFamily,
    };
  }
}
