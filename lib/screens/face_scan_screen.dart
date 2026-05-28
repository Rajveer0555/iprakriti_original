import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../providers/face_feature_provider.dart';
import '../providers/question_provider.dart';
import 'face_feature_screen.dart';
import 'widgets/assessment_step_badge.dart';

class FaceScanScreen extends ConsumerStatefulWidget {
  const FaceScanScreen({super.key});

  @override
  ConsumerState<FaceScanScreen> createState() => _FaceScanScreenState();
}

class _FaceScanScreenState extends ConsumerState<FaceScanScreen>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  FaceDetector? _faceDetector;
  bool _isInitializing = true;
  bool _isCapturing = false;
  bool _isPermissionDenied = false;
  bool _isFaceDetected = false;
  bool _showNoFaceGuidance = false;
  String? _cameraError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeScanner();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _faceDetector?.close();
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      await controller.dispose();
      _cameraController = null;
      return;
    }

    if (state == AppLifecycleState.resumed) {
      await _initializeScanner();
    }
  }

  Future<void> _initializeScanner() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _isInitializing = true;
      _cameraError = null;
      _isPermissionDenied = false;
      _showNoFaceGuidance = false;
    });

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw StateError('No camera was found on this device.');
      }

      final selectedCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      final previousController = _cameraController;
      await previousController?.dispose();

      final controller = CameraController(
        selectedCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await controller.initialize();

      _faceDetector ??= FaceDetector(
        options: FaceDetectorOptions(
          enableContours: true,
          enableLandmarks: false,
          enableTracking: true,
          performanceMode: FaceDetectorMode.fast,
        ),
      );

      _cameraController = controller;

      if (!mounted) {
        return;
      }

      setState(() {
        _isInitializing = false;
        _cameraError = null;
      });
    } on CameraException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isInitializing = false;
        _cameraError = error.description ?? error.code;
        _isPermissionDenied = error.code == 'CameraAccessDenied';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isInitializing = false;
        _cameraError = error.toString();
      });
    }
  }

  void _continueToQuestions() {
    ref.read(faceFeatureProvider.notifier).reset();
    ref.read(questionnaireProvider.notifier).reset();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const FaceFeatureScreen(),
      ),
    );
  }

  void _handleCaptureTap() {
    if (_isInitializing || _isCapturing || _cameraController == null) {
      return;
    }
    _captureAndDetectFace();
  }

  Future<void> _captureAndDetectFace() async {
    final controller = _cameraController;
    final detector = _faceDetector;
    if (controller == null || detector == null) {
      return;
    }

    setState(() {
      _isCapturing = true;
      _showNoFaceGuidance = false;
      _cameraError = null;
    });

    try {
      final image = await controller.takePicture();
      final inputImage = InputImage.fromFilePath(image.path);
      final faces = await detector.processImage(inputImage);

      if (!mounted) {
        return;
      }

      if (faces.isEmpty) {
        setState(() {
          _isCapturing = false;
          _isFaceDetected = false;
          _showNoFaceGuidance = true;
        });
        return;
      }

      setState(() {
        _isCapturing = false;
        _isFaceDetected = true;
      });
      await Future<void>.delayed(const Duration(milliseconds: 350));
      if (!mounted) {
        return;
      }
      _continueToQuestions();
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isCapturing = false;
        _isFaceDetected = false;
        _cameraError = 'We could not scan your face. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_cameraController != null && _cameraController!.value.isInitialized)
            _buildCameraPreview()
          else
            Container(color: const Color(0xFF131313)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Expanded(
                        child: Text(
                          'Face Scan',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const AssessmentStepBadge(step: 2, totalSteps: 4),
                    ],
                  ),
                  const Spacer(),
                  AnimatedScale(
                    scale: _isFaceDetected ? 1.02 : 1,
                    duration: const Duration(milliseconds: 180),
                    child: _FaceScanFrame(isDetected: _isFaceDetected),
                  ),
                  const SizedBox(height: 34),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: _isCapturing
                        ? const Text(
                            'Scanning your face...',
                            key: ValueKey('scan_processing'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          )
                        : _isFaceDetected
                        ? const Text(
                            'Face detected. Hold still...',
                            key: ValueKey('scan_detected'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          )
                        : _showNoFaceGuidance
                        ? const Text(
                            'No face detected. Move to better lighting and center your face.',
                            key: ValueKey('scan_guidance'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFFFFD8A8),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        : const Text(
                            'Align your face inside the frame',
                            key: ValueKey('scan_default'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xE6FFFFFF),
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  ),
                  const SizedBox(height: 24),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 180),
                    opacity: _showNoFaceGuidance ? 0 : 1,
                    child: IgnorePointer(
                      ignoring: _showNoFaceGuidance,
                      child: Column(
                        children: [
                          Text(
                            _isPermissionDenied
                                ? 'Camera permission is required to scan your face'
                                : 'Position your face inside the frame',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _cameraError != null
                                ? _friendlyCameraError(_cameraError!)
                                : 'Ensure good lighting and remove glasses.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xD6FFFFFF),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _handleCaptureTap,
                    child: Opacity(
                      opacity:
                          (_isInitializing ||
                                  _cameraController == null ||
                                  _isCapturing)
                              ? 0.55
                              : 1,
                      child: Container(
                        width: 78,
                        height: 78,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xCCFFFFFF),
                            width: 2,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFE4E4E4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Your image is processed securely and not stored',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xE6FFFFFF),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isInitializing)
            const ColoredBox(
              color: Color(0x55000000),
              child: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
          if (_isCapturing)
            const ColoredBox(
              color: Color(0x33000000),
              child: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    final controller = _cameraController!;
    final previewSize = controller.value.previewSize;

    if (previewSize == null) {
      return CameraPreview(controller);
    }

    final previewWidth = previewSize.height;
    final previewHeight = previewSize.width;

    return LayoutBuilder(
      builder: (context, constraints) {
        return ClipRect(
          child: SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: previewWidth,
                height: previewHeight,
                child: CameraPreview(controller),
              ),
            ),
          ),
        );
      },
    );
  }

  String _friendlyCameraError(String error) {
    final message = error.toLowerCase();
    if (message.contains('cameraaccessdenied')) {
      return 'Allow camera access to use the face scanner.';
    }
    if (message.contains('no camera was found')) {
      return 'This device does not have a usable camera.';
    }
    return 'We could not start the camera right now. Please try again.';
  }
}

class _FaceScanFrame extends StatefulWidget {
  const _FaceScanFrame({required this.isDetected});

  final bool isDetected;

  @override
  State<_FaceScanFrame> createState() => _FaceScanFrameState();
}

class _FaceScanFrameState extends State<_FaceScanFrame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
  }

  @override
  void didUpdateWidget(covariant _FaceScanFrame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isDetected) {
      _glowController.repeat(reverse: true);
    } else {
      _glowController
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final t = widget.isDetected ? _glowController.value : 0.0;
        final color = Color.lerp(
          const Color(0xFF78B56D),
          const Color(0xFFA7F091),
          t,
        )!;
        final glowOpacity = widget.isDetected ? 0.45 + (t * 0.35) : 0.0;

        return SizedBox(
          width: 240,
          height: 320,
          child: Stack(
            alignment: Alignment.center,
            children: [
              ..._buildCornerPieces(color, glowOpacity),
              Positioned(top: 68, child: _circle(86, color, glowOpacity)),
              Positioned(top: 90, child: _circle(76, color, glowOpacity)),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildCornerPieces(Color color, double glowOpacity) {
    const stroke = 5.0;
    const arm = 66.0;

    return [
      Positioned(
        top: 0,
        left: 0,
        child: _corner(
          color: color,
          top: true,
          left: true,
          arm: arm,
          stroke: stroke,
          glowOpacity: glowOpacity,
        ),
      ),
      Positioned(
        top: 0,
        right: 0,
        child: _corner(
          color: color,
          top: true,
          left: false,
          arm: arm,
          stroke: stroke,
          glowOpacity: glowOpacity,
        ),
      ),
      Positioned(
        bottom: 0,
        left: 0,
        child: _corner(
          color: color,
          top: false,
          left: true,
          arm: arm,
          stroke: stroke,
          glowOpacity: glowOpacity,
        ),
      ),
      Positioned(
        bottom: 0,
        right: 0,
        child: _corner(
          color: color,
          top: false,
          left: false,
          arm: arm,
          stroke: stroke,
          glowOpacity: glowOpacity,
        ),
      ),
    ];
  }

  Widget _circle(double size, Color color, double glowOpacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.82), width: 3),
        boxShadow:
            glowOpacity == 0
                ? null
                : [
                  BoxShadow(
                    color: color.withValues(alpha: glowOpacity),
                    blurRadius: 16,
                    spreadRadius: 1,
                  ),
                ],
      ),
    );
  }

  Widget _corner({
    required Color color,
    required bool top,
    required bool left,
    required double arm,
    required double stroke,
    required double glowOpacity,
  }) {
    final shadow =
        glowOpacity == 0
            ? <BoxShadow>[]
            : [
              BoxShadow(
                color: color.withValues(alpha: glowOpacity),
                blurRadius: 18,
                spreadRadius: 1,
              ),
            ];

    return SizedBox(
      width: arm,
      height: arm,
      child: Stack(
        children: [
          Positioned(
            top: top ? 0 : null,
            bottom: top ? null : 0,
            left: left ? 0 : null,
            right: left ? null : 0,
            child: Container(
              width: arm,
              height: stroke,
              decoration: BoxDecoration(color: color, boxShadow: shadow),
            ),
          ),
          Positioned(
            top: top ? 0 : null,
            bottom: top ? null : 0,
            left: left ? 0 : null,
            right: left ? null : 0,
            child: Container(
              width: stroke,
              height: arm,
              decoration: BoxDecoration(color: color, boxShadow: shadow),
            ),
          ),
        ],
      ),
    );
  }
}
