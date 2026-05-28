import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/app_snackbar.dart';
import '../providers/auth_provider.dart';
import 'dashboard_screen.dart';
import 'informative_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSignUp = false;
  _AuthButtonAction? _activeAction;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthViewState>(authControllerProvider, (previous, next) {
      final hadSession = previous?.session != null;
      final hasSession = next.session != null;

      if (!hadSession && hasSession) {
        _handleSignedInUser(next.session?.user.id);
        return;
      }

      final errorMessage = next.errorMessage;
      if (errorMessage != null) {
        showAppSnackBar(
          context,
          message: errorMessage,
          tone: AppSnackBarTone.error,
        );
        ref.read(authControllerProvider.notifier).clearError();
      }
    });

    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;
    if (!isLoading && _activeAction != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _activeAction = null;
          });
        }
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFEFF8FF),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/login_screen.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.vertical,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 150),
                      Text(
                        _isSignUp ? 'Create Account' : 'Welcome Back',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isSignUp
                            ? 'Start discovering your Prakruti today'
                            : 'Sign in to continue your wellness journey',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF3E3E3E),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 30),
                      if (_isSignUp) ...[
                        _AuthField(
                          controller: _nameController,
                          hintText: 'Name',
                          validator: (value) {
                            if ((value ?? '').trim().isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                      ],
                      _AuthField(
                        controller: _emailController,
                        hintText: _isSignUp ? 'Email-id' : 'Enter your email',
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          final email = (value ?? '').trim();
                          if (email.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!email.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      _AuthField(
                        controller: _passwordController,
                        hintText:
                            _isSignUp ? 'Password' : 'Enter your password',
                        obscureText: _obscurePassword,
                        validator: (value) {
                          if ((value ?? '').isEmpty) {
                            return 'Please enter your password';
                          }
                          if (_isSignUp && (value ?? '').length < 6) {
                            return 'Password should be at least 6 characters';
                          }
                          return null;
                        },
                        suffix: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: const Color(0xFFDEDEDE),
                            size: 20,
                          ),
                        ),
                      ),
                      if (_isSignUp) ...[
                        const SizedBox(height: 24),
                        _AuthField(
                          controller: _confirmPasswordController,
                          hintText: 'Confirm password',
                          obscureText: _obscureConfirmPassword,
                          validator: (value) {
                            if ((value ?? '').isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                          suffix: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: const Color(0xFFDEDEDE),
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                      if (!_isSignUp) ...[
                        const SizedBox(height: 12),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Forget password ?',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFFB5B5B5),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _submitPrimaryAction,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(0, 46),
                            backgroundColor: const Color(0xFF16641F),
                            disabledBackgroundColor: const Color(0xFF16641F),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isLoading &&
                                  _activeAction == _AuthButtonAction.primary
                              ? const SizedBox(
                                  width: 34,
                                  height: 34,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  _isSignUp ? 'Create Account' : 'Login',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                      if (!_isSignUp) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: const [
                            Expanded(
                              child: Divider(
                                color: Color(0xFFE1E1E1),
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 14),
                              child: Text(
                                'or',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Color(0xFFE1E1E1),
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : _submitGoogleAction,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(0, 46),
                              backgroundColor: const Color(0xFF16641F),
                              disabledBackgroundColor: const Color(0xFF16641F),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: isLoading &&
                                    _activeAction == _AuthButtonAction.google
                                ? const SizedBox(
                                    width: 34,
                                    height: 34,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      color: Colors.white,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Text(
                                        'Continue with',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Image(
                                        image: AssetImage('assets/google.png'),
                                        width: 22,
                                        height: 22,
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      GestureDetector(
                        onTap: isLoading ? null : _toggleMode,
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFFB7B7B7),
                              fontWeight: FontWeight.w500,
                            ),
                            children: [
                              TextSpan(
                                text: _isSignUp
                                    ? 'Already have an account? '
                                    : 'Don\'t have an account? ',
                              ),
                              TextSpan(
                                text: _isSignUp ? 'sign in' : 'sign up',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 124),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitPrimaryAction() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _activeAction = _AuthButtonAction.primary;
    });

    final notifier = ref.read(authControllerProvider.notifier);

    if (_isSignUp) {
      final success = await notifier.signUpWithPassword(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted || !success) {
        return;
      }
      showAppSnackBar(
        context,
        message:
            'Account created. If email verification is enabled, please check your inbox before signing in.',
        tone: AppSnackBarTone.success,
      );
    } else {
      await notifier.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    }
  }

  Future<void> _submitGoogleAction() async {
    setState(() {
      _activeAction = _AuthButtonAction.google;
    });

    await ref.read(authControllerProvider.notifier).signInWithGoogle();
  }

  Future<void> _handleSignedInUser(String? userId) async {
    if (userId == null) {
      return;
    }

    Widget destination = const InformativeScreen();
    if (!_isSignUp) {
      try {
        final profile = await ref.read(userServiceProvider).fetchUserProfile(userId);
        if (profile.isComplete) {
          destination = const DashboardScreen(initialIndex: 0);
        }
      } catch (_) {}
    }

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => destination),
      (route) => false,
    );
  }

  void _toggleMode() {
    setState(() {
      _isSignUp = !_isSignUp;
      _obscurePassword = true;
      _obscureConfirmPassword = true;
      if (_isSignUp) {
        _nameController.clear();
        _emailController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();
      } else {
        _emailController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();
      }
    });
  }
}

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.controller,
    this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.suffix,
    this.validator,
  });

  final TextEditingController controller;
  final String? hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffix;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: const TextStyle(
        fontSize: 16,
        color: Colors.black,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          fontSize: 15,
          color: Color(0xFFBABABA),
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: Colors.white,
        suffixIcon: suffix,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 17,
        ),
        errorStyle: const TextStyle(height: 0.85),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFE6E6E6),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF179D45),
            width: 1.2,
          ),
        ),
      ),
    );
  }
}

enum _AuthButtonAction {
  primary,
  google,
}
