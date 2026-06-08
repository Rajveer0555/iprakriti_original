import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/theme.dart';
import 'models/user_profile_model.dart';
import 'providers/auth_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/informative_screen.dart';
import 'screens/login_screen.dart';
import 'screens/onboarding/onboarding_screen.dart' as onboarding;
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';

const _supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: 'https://smqiowljeufxablwyads.supabase.co',
);
const _supabaseAnonKey = String.fromEnvironment(
  'SUPABASE_ANON_KEY',
  defaultValue:
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNtcWlvd2xqZXVmeGFibHd5YWRzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY3MjAzNzgsImV4cCI6MjA5MjI5NjM3OH0.hHCHkDuHFLcXt0iwDgLEwGDGC8G2PbczNQUJvNiJ25M',
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  String? initializationError;

  if (_supabaseUrl.isNotEmpty && _supabaseAnonKey.isNotEmpty) {
    try {
      await Supabase.initialize(url: _supabaseUrl, anonKey: _supabaseAnonKey);
    } catch (error) {
      initializationError = error.toString();
    }
  }

  // BUG #1 FIX: Only call initialize() here (safe — no permission dialog).
  // syncWithStoredPreferences() (which triggers the Android permission dialog)
  // is deferred to SplashScreenWrapper.initState via addPostFrameCallback,
  // so Flutter's Activity window is fully ready before the dialog is shown.
  await NotificationService.instance.initialize();

  runApp(
    ProviderScope(
      child: IPrakritiApp(initializationError: initializationError),
    ),
  );
}

class IPrakritiApp extends StatelessWidget {
  const IPrakritiApp({super.key, this.initializationError});

  final String? initializationError;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IPrakriti',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home:
          _supabaseUrl.isEmpty || _supabaseAnonKey.isEmpty
              ? const _ConfigurationMissingScreen()
              : initializationError != null
              ? _SupabaseStartupErrorScreen(message: initializationError!)
              : const SplashScreenWrapper(),
      routes: {'/login': (context) => const LoginScreen()},
    );
  }
}

class SplashScreenWrapper extends StatefulWidget {
  const SplashScreenWrapper({super.key});

  @override
  State<SplashScreenWrapper> createState() => _SplashScreenWrapperState();
}

class _SplashScreenWrapperState extends State<SplashScreenWrapper> {
  @override
  void initState() {
    super.initState();

    // BUG #1 FIX: Sync notifications after the first frame so the Android
    // Activity is fully alive before any permission dialog is shown.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService.instance.syncWithStoredPreferences();
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const _AppEntryGate()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}

class _AppEntryGate extends StatefulWidget {
  const _AppEntryGate();

  @override
  State<_AppEntryGate> createState() => _AppEntryGateState();
}

// BUG #3 FIX: Converted to StatefulWidget so the Future is created once in
// initState and reused across rebuilds. Previously it was a StatelessWidget
// that called _isOnboardingComplete() directly inside build(), creating a new
// Future (and a new SharedPreferences read) on every rebuild.
class _AppEntryGateState extends State<_AppEntryGate> {
  late final Future<bool> _onboardingFuture;

  @override
  void initState() {
    super.initState();
    _onboardingFuture = _isOnboardingComplete();
  }

  Future<bool> _isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarding_completed') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _onboardingFuture, // stable reference — not recreated on rebuild
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _SplashScreen();
        }

        if (snapshot.data != true) {
          return const onboarding.OnboardingScreen();
        }

        return const AuthStateHandler();
      },
    );
  }
}

class AuthStateHandler extends ConsumerWidget {
  const AuthStateHandler({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    if (!authState.isInitialized) {
      return const _SplashScreen();
    }

    if (authState.session != null) {
      return const _PostAuthDestination();
    }

    return const LoginScreen();
  }
}

class _PostAuthDestination extends ConsumerStatefulWidget {
  const _PostAuthDestination();

  @override
  ConsumerState<_PostAuthDestination> createState() =>
      _PostAuthDestinationState();
}

// BUG #4 FIX: Converted to ConsumerStatefulWidget so fetchUserProfile() is
// called only once (in initState) and cached. Previously it was a
// ConsumerWidget whose build() called ref.read(...).fetchUserProfile(userId)
// directly, firing a new network request on every rebuild triggered by
// authControllerProvider changes.
class _PostAuthDestinationState extends ConsumerState<_PostAuthDestination> {
  Future<UserProfileData>? _profileFuture;
  String? _cachedUserId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userId = ref.read(authControllerProvider).session?.user.id;
    // Only re-fetch if the user ID actually changed (e.g. after sign-out/in).
    if (userId != null && userId != _cachedUserId) {
      _cachedUserId = userId;
      _profileFuture =
          ref.read(userServiceProvider).fetchUserProfile(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(authControllerProvider).session?.user.id;
    if (userId == null) {
      return const LoginScreen();
    }

    return FutureBuilder<UserProfileData>(
      future: _profileFuture, // stable reference — network call not repeated
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _SplashScreen();
        }

        if (snapshot.hasError) {
          return _PostAuthErrorScreen(message: snapshot.error.toString());
        }

        final profile = snapshot.data;
        if (profile == null || !profile.isComplete) {
          return const InformativeScreen();
        }

        return const DashboardScreen(initialIndex: 0);
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Shared loading placeholder shown during async waits
// ---------------------------------------------------------------------------
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.skyTint, AppColors.surface],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppSpacing.xl),
              Text(
                'IPrakriti',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Aligning modern wellness with Ayurvedic insight',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConfigurationMissingScreen extends StatelessWidget {
  const _ConfigurationMissingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/app_logo.png',
                  width: 88,
                  height: 88,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Supabase configuration missing',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Run with --dart-define=SUPABASE_URL=... and '
                  '--dart-define=SUPABASE_ANON_KEY=... to enable auth, '
                  'history, and result syncing.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SupabaseStartupErrorScreen extends StatelessWidget {
  const _SupabaseStartupErrorScreen({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/app_logo.png',
                  width: 88,
                  height: 88,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Unable to connect to Supabase',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Check your internet connection, verify the Supabase URL, '
                  'and try launching the app again.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PostAuthErrorScreen extends StatelessWidget {
  const _PostAuthErrorScreen({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/app_logo.png',
                  width: 88,
                  height: 88,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'We could not load your profile',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
