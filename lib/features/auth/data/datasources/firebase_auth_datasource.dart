import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/error/failures.dart';

abstract class FirebaseAuthDatasource {
  Future<Either<Failure, String>> signInWithEmail(String email, String password);

  Future<Either<Failure, String>> signInWithGoogle();

  Future<Either<Failure, String>> register(String email, String password);

  Future<Either<Failure, Unit>> signOut();

  Stream<String?> get authStateChanges;

  String? get currentUserId;

  String? get currentUserEmail;
}

class FirebaseAuthDatasourceImpl implements FirebaseAuthDatasource {
  FirebaseAuthDatasourceImpl({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  @override
  Stream<String?> get authStateChanges =>
      _firebaseAuth.authStateChanges().map((User? user) => user?.uid);

  @override
  String? get currentUserId => _firebaseAuth.currentUser?.uid;

  @override
  String? get currentUserEmail => _firebaseAuth.currentUser?.email;

  @override
  Future<Either<Failure, String>> signInWithEmail(
    String email,
    String password,
  ) async {
    try {
      final UserCredential credential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final String? userId = credential.user?.uid;
      if (userId == null) {
        return const Left<Failure, String>(
          ServerFailure('Не удалось выполнить вход'),
        );
      }
      return Right<Failure, String>(userId);
    } on FirebaseAuthException catch (exception) {
      return Left<Failure, String>(ServerFailure(_mapFirebaseAuthError(exception)));
    }
  }

  @override
  Future<Either<Failure, String>> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return const Left<Failure, String>(
          ServerFailure('Вход через Google отменен'),
        );
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      final String? userId = userCredential.user?.uid;
      if (userId == null) {
        return const Left<Failure, String>(
          ServerFailure('Не удалось выполнить вход через Google'),
        );
      }
      return Right<Failure, String>(userId);
    } on FirebaseAuthException catch (exception) {
      return Left<Failure, String>(ServerFailure(_mapFirebaseAuthError(exception)));
    } on PlatformException catch (exception) {
      return Left<Failure, String>(ServerFailure(_mapPlatformError(exception)));
    }
  }

  @override
  Future<Either<Failure, String>> register(
    String email,
    String password,
  ) async {
    try {
      final UserCredential credential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final String? userId = credential.user?.uid;
      if (userId == null) {
        return const Left<Failure, String>(
          ServerFailure('Не удалось создать аккаунт'),
        );
      }
      return Right<Failure, String>(userId);
    } on FirebaseAuthException catch (exception) {
      return Left<Failure, String>(ServerFailure(_mapFirebaseAuthError(exception)));
    }
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
      return const Right<Failure, Unit>(unit);
    } on FirebaseAuthException catch (exception) {
      return Left<Failure, Unit>(ServerFailure(_mapFirebaseAuthError(exception)));
    } on PlatformException catch (exception) {
      return Left<Failure, Unit>(ServerFailure(_mapPlatformError(exception)));
    }
  }

  String _mapFirebaseAuthError(FirebaseAuthException exception) {
    return switch (exception.code) {
      'user-not-found' => 'Пользователь не найден',
      'wrong-password' => 'Неверный пароль',
      'email-already-in-use' => 'Email уже используется',
      'weak-password' => 'Слишком простой пароль',
      'network-request-failed' => 'Нет подключения к интернету',
      'invalid-credential' => 'Неверный email или пароль',
      'invalid-email' => 'Некорректный email',
      _ => exception.message ?? 'Произошла ошибка авторизации',
    };
  }

  String _mapPlatformError(PlatformException exception) {
    return switch (exception.code) {
      'network_error' => 'Нет подключения к интернету',
      'sign_in_canceled' => 'Вход через Google отменен',
      _ => exception.message ?? 'Не удалось выполнить вход через Google',
    };
  }
}
