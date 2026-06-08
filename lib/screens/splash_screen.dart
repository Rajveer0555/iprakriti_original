import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // BUG #5 FIX: Wrap AssetImage in an Image widget with errorBuilder
          // so a missing or corrupt splash_bg.png never causes a black screen.
          // The gradient below acts as the guaranteed visible fallback.
          Container(
            decoration: const BoxDecoration(
              // Fallback gradient shown when the image fails to load.
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFE8F5E9), Color(0xFFF9FBF9)],
              ),
            ),
          ),
          // Background image — rendered on top of gradient; errors are silently
          // swallowed so the gradient shows through instead of a black screen.
          Image.asset(
            'assets/splash_bg.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Asset missing or corrupt — gradient fallback already visible.
              return const SizedBox.shrink();
            },
          ),
          // Content overlay
          FadeTransition(
            opacity: _fadeInAnimation,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'IPrakriti',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 56,
                          color: Colors.black,
                          letterSpacing: 1.0,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'AI-Based Ayurvedic Analysis',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
