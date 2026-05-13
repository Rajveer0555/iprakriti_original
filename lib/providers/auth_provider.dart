import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../services/auth_service.dart';
import '../services/result_service.dart';
import '../services/user_service.dart';

final supabaseClientProvider = Provider<supabase.SupabaseClient>((ref) {
  return supabase.Supabase.instance.client;
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(supabaseClientProvider));
});

final userServiceProvider = Provider<UserService>((ref) {
  return UserService(ref.watch(supabaseClientProvider));
});

final resultServiceProvider = Provider<ResultService>((ref) {
  return ResultService(ref.watch(supabaseClientProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    authService: ref.watch(authServiceProvider),
    userService: ref.watch(userServiceProvider),
  );
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthViewState>((ref) {
  final controller = AuthController(ref.watch(authRepositoryProvider));
  ref.onDispose(controller.dispose);
  return controller;
});

class AuthRepository {
  AuthRepository({
    required AuthService authService,
    required UserService userService,
  })  : _authService = authService,
        _userService = userService;

  final AuthService _authService;
  final UserService _userService;

  supabase.Session? get currentSession => _authService.currentSession;

  Stream<supabase.AuthState> get authStateChanges =>
      _authService.authStateChanges;

  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) {
    return _authService.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signUpWithPassword({
    required String name,
    required String email,
    required String password,
  }) {
    return _authService.signUpWithPassword(
      name: name,
      email: email,
      password: password,
    );
  }

  Future<void> signInWithGoogle() => _authService.signInWithGoogle();

  Future<void> signOut() => _authService.signOut();

  Future<void> clearLocalSession() => _authService.clearLocalSession();

  Future<void> syncUserProfile(supabase.Session? session) async {
    final user = session?.user;
    if (user == null) {
      return;
    }

    final metadata = user.userMetadata ?? <String, dynamic>{};
    final fullName = metadata['full_name'] as String? ??
        metadata['name'] as String? ??
        user.email?.split('@').first ??
        'IPrakriti User';

    await _userService.upsertUser(
      id: user.id,
      email: user.email ?? '',
      name: fullName,
    );
  }
}

class AuthViewState {
  const AuthViewState({
    required this.isInitialized,
    required this.isLoading,
    this.session,
    this.errorMessage,
  });

  final bool isInitialized;
  final bool isLoading;
  final supabase.Session? session;
  final String? errorMessage;

  AuthViewState copyWith({
    bool? isInitialized,
    bool? isLoading,
    supabase.Session? session,
    String? errorMessage,
    bool clearError = false,
    bool clearSession = false,
  }) {
    return AuthViewState(
      isInitialized: isInitialized ?? this.isInitialized,
      isLoading: isLoading ?? this.isLoading,
      session: clearSession ? null : session ?? this.session,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  factory AuthViewState.initial() {
    return const AuthViewState(
      isInitialized: false,
      isLoading: false,
    );
  }
}

class AuthController extends StateNotifier<AuthViewState> {
  AuthController(this._repository) : super(AuthViewState.initial()) {
    _bootstrap();
  }

  final AuthRepository _repository;
  StreamSubscription<supabase.AuthState>? _subscription;

  Future<void> _bootstrap() async {
    final session = _repository.currentSession;
    try {
      if (session != null) {
        await _repository.syncUserProfile(session);
      }

      state = state.copyWith(
        isInitialized: true,
        session: session,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        isInitialized: true,
        session: session,
        errorMessage: error.toString(),
      );
    }

    _subscription = _repository.authStateChanges.listen(
      (event) {
        final session = event.session;

        state = state.copyWith(
          isInitialized: true,
          isLoading: false,
          session: session,
          clearSession: session == null,
          clearError: true,
        );

        if (session != null) {
          unawaited(_repository.syncUserProfile(session).catchError((_) {}));
        }
      },
      onError: (Object error) {
        if (_isInvalidRefreshTokenError(error)) {
          unawaited(_clearInvalidSession());
          return;
        }

        state = state.copyWith(
          isInitialized: true,
          isLoading: false,
          errorMessage: error.toString(),
        );
      },
    );
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.signInWithGoogle();
      state = state.copyWith(isLoading: false);
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.signInWithPassword(
        email: email,
        password: password,
      );
      state = state.copyWith(isLoading: false);
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> signUpWithPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.signUpWithPassword(
        name: name,
        email: email,
        password: password,
      );
      state = state.copyWith(isLoading: false);
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.signOut();
      state = state.copyWith(isLoading: false, clearSession: true);
    } catch (error) {
      if (_isInvalidRefreshTokenError(error)) {
        await _clearInvalidSession();
        return;
      }

      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  Future<void> _clearInvalidSession() async {
    await _repository.clearLocalSession();
    state = state.copyWith(
      isInitialized: true,
      isLoading: false,
      clearSession: true,
      clearError: true,
    );
  }

  bool _isInvalidRefreshTokenError(Object error) {
    if (error is supabase.AuthApiException) {
      return error.code == 'refresh_token_not_found' ||
          error.message.toLowerCase().contains('invalid refresh token');
    }

    final message = error.toString().toLowerCase();
    return message.contains('refresh_token_not_found') ||
        message.contains('invalid refresh token');
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
