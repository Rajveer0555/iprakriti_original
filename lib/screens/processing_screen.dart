import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/question_model.dart';
import 'result_screen.dart';

class ProcessingScreen extends StatefulWidget {
  const ProcessingScreen({
    required this.result,
    super.key,
  });

  final PrakritiAssessmentResult result;

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen>
    with SingleTickerProviderStateMixin {
  static const _messages = [
    'Scanning facial features...',
    'Evaluating lifestyle responses...',
    'Calculating dosha balance...',
  ];

  Timer? _stepTimer;
  int _currentStep = 0;
  late final AnimationController _orbitController;

  @override
  void initState() {
    super.initState();
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();
    _scheduleNextStep();
  }

  @override
  void dispose() {
    _stepTimer?.cancel();
    _orbitController.dispose();
    super.dispose();
  }

  void _scheduleNextStep() {
    _stepTimer?.cancel();
    _stepTimer = Timer(const Duration(milliseconds: 1350), () {
      if (!mounted) {
        return;
      }

      if (_currentStep < _messages.length - 1) {
        setState(() {
          _currentStep += 1;
        });
        _scheduleNextStep();
        return;
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => ResultScreen(result: widget.result),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFA),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _orbitController,
                  builder: (context, _) {
                    return _ProcessingOrbit(turns: _orbitController.value);
                  },
                ),
                const SizedBox(height: 34),
                Text(
                  'Analyzing your Prakruti....',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Combining facial insights and lifestyle\npatterns.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF616161),
                        height: 1.55,
                      ),
                ),
                const SizedBox(height: 88),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  child: Text(
                    _messages[_currentStep],
                    key: ValueKey<int>(_currentStep),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF303030),
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProcessingOrbit extends StatelessWidget {
  const _ProcessingOrbit({required this.turns});

  final double turns;

  @override
  Widget build(BuildContext context) {
    const size = 148.0;
    const logoSize = 84.0;
    final angle = turns * 2 * math.pi;

    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Container(
          width: 112,
          height: 112,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                const Color(0xFFEAF7ED),
                const Color(0xFFEAF7ED).withOpacity(0),
              ],
            ),
          ),
          child: Center(
            child: Transform.rotate(
              angle: angle,
              child: Container(
                width: logoSize,
                height: logoSize,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7ABF8A).withOpacity(0.18),
                      blurRadius: 22,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/processing_orbit_logo.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
