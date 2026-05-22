import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

const _googleWebClientId = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');

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
    if (kIsWeb) {
      await _signInWithGoogleOAuth();
      return;
    }

    final googleSignIn = GoogleSignIn(
      scopes: const ['email', 'profile'],
      serverClientId:
          _googleWebClientId.isEmpty ? null : _googleWebClientId,
    );

    try {
      final account = await googleSignIn.signIn();
      if (account == null) {
        return;
      }

      final authentication = await account.authentication;
      final idToken = authentication.idToken;
      final accessToken = authentication.accessToken;

      if (idToken != null && accessToken != null) {
        await _client.auth.signInWithIdToken(
          provider: supabase.OAuthProvider.google,
          idToken: idToken,
          accessToken: accessToken,
        );
        return;
      }
    } catch (_) {
      await googleSignIn.signOut().catchError((_) {});
    }

    await _signInWithGoogleOAuth();
  }

  Future<void> _signInWithGoogleOAuth() {
    return _client.auth.signInWithOAuth(
      supabase.OAuthProvider.google,
      redirectTo: kIsWeb ? null : 'iprakriti://login-callback/',
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
