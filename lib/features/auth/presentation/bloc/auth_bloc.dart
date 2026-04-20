import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../transactions/data/datasources/transaction_local_datasource.dart';
import '../../../transactions/data/datasources/transaction_remote_datasource.dart';
import '../../../transactions/data/models/transaction_model.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required AuthRepository authRepository,
    required TransactionLocalDatasource localDatasource,
    required TransactionRemoteDatasource remoteDatasource,
    required SharedPreferences sharedPreferences,
  })  : _authRepository = authRepository,
        _localDatasource = localDatasource,
        _remoteDatasource = remoteDatasource,
        _sharedPreferences = sharedPreferences,
        super(const AuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<SignInWithEmailEvent>(_onSignInWithEmail);
    on<SignInWithGoogleEvent>(_onSignInWithGoogle);
    on<RegisterWithEmailEvent>(_onRegisterWithEmail);
    on<SignOutEvent>(_onSignOut);
  }

  final AuthRepository _authRepository;
  final TransactionLocalDatasource _localDatasource;
  final TransactionRemoteDatasource _remoteDatasource;
  final SharedPreferences _sharedPreferences;

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    final String? userId = _authRepository.currentUserId;
    if (userId == null) {
      emit(const AuthUnauthenticated());
      return;
    }

    emit(
      AuthAuthenticated(
        userId: userId,
        email: _authRepository.currentUserEmail ?? '',
      ),
    );
  }

  Future<void> _onSignInWithEmail(
    SignInWithEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _authRepository.signInWithEmail(
      event.email,
      event.password,
    );
    emit(
      await result.fold<Future<AuthState>>(
        (failure) async => AuthError(failure.message),
        _buildAuthenticatedState,
      ),
    );
  }

  Future<void> _onSignInWithGoogle(
    SignInWithGoogleEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _authRepository.signInWithGoogle();
    emit(
      await result.fold<Future<AuthState>>(
        (failure) async => AuthError(failure.message),
        _buildAuthenticatedState,
      ),
    );
  }

  Future<void> _onRegisterWithEmail(
    RegisterWithEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _authRepository.register(event.email, event.password);
    emit(
      await result.fold<Future<AuthState>>(
        (failure) async => AuthError(failure.message),
        _buildAuthenticatedState,
      ),
    );
  }

  Future<void> _onSignOut(
    SignOutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _authRepository.signOut();
    emit(
      result.fold<AuthState>(
        (failure) => AuthError(failure.message),
        (_) => const AuthUnauthenticated(),
      ),
    );
  }

  Future<AuthState> _buildAuthenticatedState(String userId) async {
    await _runInitialSyncIfNeeded(userId);
    return AuthAuthenticated(
      userId: userId,
      email: _authRepository.currentUserEmail ?? '',
    );
  }

  Future<void> _runInitialSyncIfNeeded(String userId) async {
    final String key = 'initial_sync_done_$userId';
    if (_sharedPreferences.getBool(key) ?? false) {
      return;
    }

    try {
      final List<TransactionModel> transactions = await _localDatasource.getAll();
      await _remoteDatasource.uploadAll(transactions);
      await _sharedPreferences.setBool(key, true);
    } catch (error) {
      debugPrint('Initial Firestore sync failed: $error');
    }
  }
}
