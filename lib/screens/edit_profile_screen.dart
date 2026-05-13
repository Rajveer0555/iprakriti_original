import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme.dart';
import '../models/user_profile_model.dart';
import '../providers/auth_provider.dart';
import '../providers/user_profile_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  String _selectedGender = 'Male';
  String? _avatarUrl;
  Uint8List? _croppedAvatarBytes;
  bool _didFillFields = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentUserProfileProvider);
    final authUser = ref.watch(authControllerProvider).session?.user;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFA),
      body: SafeArea(
        child: profileAsync.when(
          data: (profile) {
            _fillFields(profile, authUser);
            return _buildForm();
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error:
              (error, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    error.toString(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(26, 30, 26, 22),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 52),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => Navigator.of(context).pop(),
                        child: const SizedBox(
                          width: 28,
                          height: 32,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 21,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Edit Profile',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 46),
                  Center(
                    child: _EditableAvatar(
                      imageBytes: _croppedAvatarBytes,
                      imageUrl: _avatarUrl,
                      fallbackLabel: _nameController.text,
                      onTap: _pickAndCropPhoto,
                    ),
                  ),
                  const SizedBox(height: 50),
                  _ProfileTextField(
                    controller: _nameController,
                    hintText: 'Full name',
                    validator:
                        (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Enter your full name'
                                : null,
                  ),
                  const SizedBox(height: 12),
                  _ProfileTextField(
                    controller: _emailController,
                    hintText: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                  ),
                  const SizedBox(height: 12),
                  _ProfileTextField(
                    controller: _ageController,
                    hintText: 'Age',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: _validateAge,
                  ),
                  const SizedBox(height: 12),
                  _GenderField(
                    value: _selectedGender,
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setState(() => _selectedGender = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _ProfileTextField(
                          controller: _heightController,
                          hintText: 'Height',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,1}'),
                            ),
                          ],
                          validator:
                              (value) =>
                                  _validateMeasurement(value, label: 'height'),
                        ),
                      ),
                      const SizedBox(width: 30),
                      Expanded(
                        child: _ProfileTextField(
                          controller: _weightController,
                          hintText: 'Weight',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,1}'),
                            ),
                          ],
                          validator:
                              (value) =>
                                  _validateMeasurement(value, label: 'weight'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 118),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16641F),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFF8BA98E),
                        elevation: 4,
                        shadowColor: const Color(0x3316641F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child:
                          _isSaving
                              ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  color: Colors.white,
                                ),
                              )
                              : const Text(
                                'Save Changes',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _fillFields(UserProfileData profile, dynamic authUser) {
    if (_didFillFields) {
      return;
    }

    final authMetadata = authUser?.userMetadata as Map<String, dynamic>? ?? {};
    final authName =
        authMetadata['full_name'] as String? ??
        authMetadata['name'] as String? ??
        authUser?.email?.split('@').first;
    final authAvatar =
        authMetadata['avatar_url'] as String? ??
        authMetadata['picture'] as String?;

    _nameController.text = profile.name ?? authName ?? '';
    _emailController.text = profile.email ?? authUser?.email ?? '';
    _ageController.text = profile.age?.toString() ?? '';
    _selectedGender = profile.gender ?? 'Male';
    _heightController.text = _formatDecimal(profile.heightCm);
    _weightController.text = _formatDecimal(profile.weightKg);
    _avatarUrl = profile.avatarUrl ?? authAvatar;
    _didFillFields = true;
  }

  Future<void> _pickAndCropPhoto() async {
    try {
      final image = await ref.read(userServiceProvider).pickProfileImage();
      if (image == null || !mounted) {
        return;
      }

      final bytes = await image.readAsBytes();
      if (!mounted) {
        return;
      }

      final cropped = await Navigator.of(context).push<Uint8List>(
        MaterialPageRoute(
          builder: (_) => ProfileImageCropScreen(imageBytes: bytes),
        ),
      );

      if (cropped == null || !mounted) {
        return;
      }

      setState(() {
        _croppedAvatarBytes = cropped;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final userId = ref.read(authControllerProvider).session?.user.id;
    if (userId == null) {
      _showMessage('Please sign in again before saving.');
      return;
    }

    setState(() => _isSaving = true);
    try {
      var avatarUrl = _avatarUrl;
      final croppedBytes = _croppedAvatarBytes;
      if (croppedBytes != null) {
        avatarUrl = await ref
            .read(userServiceProvider)
            .uploadProfileImage(
              userId: userId,
              bytes: croppedBytes,
              fileExtension: 'png',
            );
      }

      await ref
          .read(userServiceProvider)
          .saveProfile(
            userId: userId,
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            age: int.parse(_ageController.text.trim()),
            gender: _selectedGender,
            heightCm: double.parse(_heightController.text.trim()),
            weightKg: double.parse(_weightController.text.trim()),
            avatarUrl: avatarUrl,
          );

      ref.invalidate(currentUserProfileProvider);
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
    } catch (error) {
      _showMessage(error.toString());
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  String? _validateEmail(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Enter your email';
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text)) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? _validateAge(String? value) {
    final age = int.tryParse(value?.trim() ?? '');
    if (age == null) {
      return 'Enter your age';
    }
    if (age < 1 || age > 120) {
      return 'Enter a valid age';
    }
    return null;
  }

  String? _validateMeasurement(String? value, {required String label}) {
    final measurement = double.tryParse(value?.trim() ?? '');
    if (measurement == null || measurement <= 0) {
      return 'Enter $label';
    }
    return null;
  }

  String _formatDecimal(double? value) {
    if (value == null) {
      return '';
    }
    if (value == value.roundToDouble()) {
      return value.round().toString();
    }
    return value.toStringAsFixed(1);
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _EditableAvatar extends StatelessWidget {
  const _EditableAvatar({
    required this.imageBytes,
    required this.imageUrl,
    required this.fallbackLabel,
    required this.onTap,
  });

  final Uint8List? imageBytes;
  final String? imageUrl;
  final String fallbackLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final initials =
        fallbackLabel.trim().isEmpty
            ? 'U'
            : fallbackLabel
                .trim()
                .split(RegExp(r'\s+'))
                .take(2)
                .map((part) => part.isEmpty ? '' : part[0].toUpperCase())
                .join();

    ImageProvider? imageProvider;
    if (imageBytes != null) {
      imageProvider = MemoryImage(imageBytes!);
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      imageProvider = NetworkImage(imageUrl!);
    }

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 120,
        height: 120,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: 59,
              backgroundColor: const Color(0xFFD4D8D6),
              backgroundImage: imageProvider,
              child:
                  imageProvider == null
                      ? Text(
                        initials,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      )
                      : null,
            ),
            Positioned(
              right: 16,
              bottom: 14,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileTextField extends StatelessWidget {
  const _ProfileTextField({
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
  });

  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: _fieldShadowDecoration,
      child: SizedBox(
        height: 56,
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color(0xFF1E1E1E),
          ),
          decoration: _fieldDecoration(hintText),
        ),
      ),
    );
  }
}

class _GenderField extends StatelessWidget {
  const _GenderField({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: _fieldShadowDecoration,
      child: SizedBox(
        height: 56,
        child: DropdownButtonFormField<String>(
          value: value,
          items:
              const ['Male', 'Female', 'Other']
                  .map(
                    (gender) =>
                        DropdownMenuItem(value: gender, child: Text(gender)),
                  )
                  .toList(),
          onChanged: onChanged,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.black,
          ),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color(0xFF1E1E1E),
          ),
          decoration: _fieldDecoration('Gender'),
        ),
      ),
    );
  }
}

final BoxDecoration _fieldShadowDecoration = BoxDecoration(
  borderRadius: BorderRadius.circular(18),
  boxShadow: const [
    BoxShadow(color: Color(0x14000000), blurRadius: 4, offset: Offset(0, 1)),
  ],
);

InputDecoration _fieldDecoration(String hintText) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: const TextStyle(
      color: Color(0xFFC4C4C4),
      fontSize: 16,
      fontWeight: FontWeight.w400,
    ),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 17),
    errorStyle: const TextStyle(height: 0.01, fontSize: 0),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: Color(0xFFE1E3DF)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: Color(0xFFE1E3DF)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: Color(0xFFD4D8D3)),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: AppColors.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: AppColors.error),
    ),
  );
}

class ProfileImageCropScreen extends StatefulWidget {
  const ProfileImageCropScreen({super.key, required this.imageBytes});

  final Uint8List imageBytes;

  @override
  State<ProfileImageCropScreen> createState() => _ProfileImageCropScreenState();
}

class _ProfileImageCropScreenState extends State<ProfileImageCropScreen> {
  late final Future<ui.Image> _imageFuture;
  Offset _offset = Offset.zero;
  Offset _startOffset = Offset.zero;
  Offset _lastFocalPoint = Offset.zero;
  double _scale = 1;
  double _startScale = 1;
  bool _isCropping = false;

  @override
  void initState() {
    super.initState();
    _imageFuture = _decodeImage(widget.imageBytes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFA),
      body: SafeArea(
        child: FutureBuilder<ui.Image>(
          future: _imageFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final image = snapshot.data!;
            return LayoutBuilder(
              builder: (context, constraints) {
                final cropSize = math.min(constraints.maxWidth - 54, 304.0);
                return Padding(
                  padding: const EdgeInsets.fromLTRB(26, 30, 26, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close_rounded),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Crop Photo',
                            style: Theme.of(
                              context,
                            ).textTheme.titleLarge?.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Center(
                        child: GestureDetector(
                          onScaleStart: (details) {
                            _startScale = _scale;
                            _startOffset = _offset;
                            _lastFocalPoint = details.focalPoint;
                          },
                          onScaleUpdate: (details) {
                            setState(() {
                              _scale = (_startScale * details.scale).clamp(
                                1.0,
                                4.0,
                              );
                              _offset =
                                  _startOffset +
                                  (details.focalPoint - _lastFocalPoint);
                            });
                          },
                          child: ClipOval(
                            child: SizedBox(
                              width: cropSize,
                              height: cropSize,
                              child: CustomPaint(
                                painter: _CropImagePainter(
                                  image: image,
                                  scale: _scale,
                                  offset: _offset,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Slider(
                        value: _scale,
                        min: 1,
                        max: 4,
                        activeColor: const Color(0xFF16641F),
                        inactiveColor: const Color(0xFFE1E3DF),
                        onChanged: (value) => setState(() => _scale = value),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed:
                              _isCropping
                                  ? null
                                  : () => _finishCrop(image, cropSize),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF16641F),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          child:
                              _isCropping
                                  ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.4,
                                      color: Colors.white,
                                    ),
                                  )
                                  : const Text(
                                    'Use Photo',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _finishCrop(ui.Image image, double cropSize) async {
    setState(() => _isCropping = true);
    final bytes = await _cropImage(
      image: image,
      cropSize: cropSize,
      scale: _scale,
      offset: _offset,
    );
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop(bytes);
  }

  Future<ui.Image> _decodeImage(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  Future<Uint8List> _cropImage({
    required ui.Image image,
    required double cropSize,
    required double scale,
    required Offset offset,
  }) async {
    const outputSize = 512.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final outputRect = Rect.fromLTWH(0, 0, outputSize, outputSize);
    final factor = outputSize / cropSize;

    canvas.drawColor(Colors.white, BlendMode.src);
    _paintCroppedImage(
      canvas: canvas,
      image: image,
      cropSize: outputSize,
      scale: scale,
      offset: offset * factor,
    );

    final picture = recorder.endRecording();
    final cropped = await picture.toImage(
      outputRect.width.toInt(),
      outputRect.height.toInt(),
    );
    final byteData = await cropped.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }
}

class _CropImagePainter extends CustomPainter {
  const _CropImagePainter({
    required this.image,
    required this.scale,
    required this.offset,
  });

  final ui.Image image;
  final double scale;
  final Offset offset;

  @override
  void paint(Canvas canvas, Size size) {
    _paintCroppedImage(
      canvas: canvas,
      image: image,
      cropSize: size.width,
      scale: scale,
      offset: offset,
    );
  }

  @override
  bool shouldRepaint(covariant _CropImagePainter oldDelegate) {
    return oldDelegate.image != image ||
        oldDelegate.scale != scale ||
        oldDelegate.offset != offset;
  }
}

void _paintCroppedImage({
  required Canvas canvas,
  required ui.Image image,
  required double cropSize,
  required double scale,
  required Offset offset,
}) {
  final imageSize = Size(image.width.toDouble(), image.height.toDouble());
  final coverScale = math.max(
    cropSize / imageSize.width,
    cropSize / imageSize.height,
  );
  final drawSize = imageSize * coverScale * scale;
  final center = Offset(cropSize / 2, cropSize / 2) + offset;
  final destination = Rect.fromCenter(
    center: center,
    width: drawSize.width,
    height: drawSize.height,
  );

  canvas.drawImageRect(
    image,
    Rect.fromLTWH(0, 0, imageSize.width, imageSize.height),
    destination,
    Paint()..filterQuality = FilterQuality.high,
  );
}
