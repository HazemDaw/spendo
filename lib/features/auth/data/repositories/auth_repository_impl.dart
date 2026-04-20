import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({required FirebaseAuthDatasource datasource})
      : _datasource = datasource;

  final FirebaseAuthDatasource _datasource;

  @override
  Stream<String?> get authStateChanges => _datasource.authStateChanges;

  @override
  String? get currentUserEmail => _datasource.currentUserEmail;

  @override
  String? get currentUserId => _datasource.currentUserId;

  @override
  Future<Either<Failure, String>> signInWithEmail(
    String email,
    String password,
  ) {
    return _datasource.signInWithEmail(email, password);
  }

  @override
  Future<Either<Failure, String>> signInWithGoogle() {
    return _datasource.signInWithGoogle();
  }

  @override
  Future<Either<Failure, String>> register(String email, String password) {
    return _datasource.register(email, password);
  }

  @override
  Future<Either<Failure, Unit>> signOut() {
    return _datasource.signOut();
  }
}
