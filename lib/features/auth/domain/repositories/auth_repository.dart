import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';

abstract class AuthRepository {
  Future<Either<Failure, String>> signInWithEmail(String email, String password);

  Future<Either<Failure, String>> signInWithGoogle();

  Future<Either<Failure, String>> register(String email, String password);

  Future<Either<Failure, Unit>> signOut();

  Stream<String?> get authStateChanges;

  String? get currentUserId;

  String? get currentUserEmail;
}
