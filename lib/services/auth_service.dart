import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class AuthService {
  AuthService(this._client);

  final supabase.SupabaseClient _client;

  supabase.Session? get currentSession => _client.auth.currentSession;

  Stream<supabase.AuthState> get authStateChanges =>
      _client.auth.onAuthStateChange;

  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) async {
    await _runWithRetry(
      () => _client.auth.signInWithPassword(
        email: email,
        password: password,
      ),
    );
  }

  Future<void> signUpWithPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    await _runWithRetry(
      () => _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': name,
        },
      ),
    );
  }

  Future<void> signInWithGoogle() async {
    await _signInWithGoogleOAuth();
  }

  Future<void> _signInWithGoogleOAuth() {
    return _client.auth.signInWithOAuth(
      supabase.OAuthProvider.google,
      redirectTo: kIsWeb ? null : 'iprakriti://login-callback/',
      authScreenLaunchMode:
          kIsWeb
              ? supabase.LaunchMode.platformDefault
              : supabase.LaunchMode.inAppBrowserView,
    );
  }

  Future<void> signOut() {
    return _client.auth.signOut();
  }

  Future<void> clearLocalSession() {
    return _client.auth.signOut(scope: supabase.SignOutScope.local);
  }

  Future<T> _runWithRetry<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (error) {
      if (!_isRetryableError(error)) {
        rethrow;
      }

      await Future<void>.delayed(const Duration(milliseconds: 900));
      return action();
    }
  }

  bool _isRetryableError(Object error) {
    if (error is SocketException || error is TimeoutException) {
      return true;
    }

    final message = error.toString().toLowerCase();
    return message.contains('authretryablefetchexception') ||
        message.contains('connection timed out') ||
        message.contains('socketexception') ||
        message.contains('timed out') ||
        message.contains('network');
  }
}
