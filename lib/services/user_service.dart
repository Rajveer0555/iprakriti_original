import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_profile_model.dart';

class UserService {
  UserService(this._client, [ImagePicker? picker])
      : _picker = picker ?? ImagePicker();

  static const _missingUsersTableMessage =
      'Supabase table "public.users" is missing. Create the users table '
      'and its profile columns before saving personalization data.';
  static const _usersRlsMessage =
      'Supabase row-level security is blocking access to "public.users". '
      'Add SELECT, INSERT, and UPDATE policies for the signed-in user.';

  final SupabaseClient _client;
  final ImagePicker _picker;

  Future<void> upsertUser({
    required String id,
    required String email,
    required String name,
  }) async {
    try {
      await _client.from('users').upsert(
        {
          'id': id,
          'email': email,
          'name': name,
          'updated_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'id',
      );
    } on PostgrestException catch (error) {
      if (_isUsersTableRlsDenied(error)) {
        throw Exception(_usersRlsMessage);
      }
      if (!_isMissingUsersTable(error)) {
        rethrow;
      }
    }
  }

  Future<String?> pickAndUploadProfileImage(String userId) async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 82,
    );

    if (image == null) {
      return null;
    }

    final bytes = await image.readAsBytes();
    final extensionParts = image.name.split('.');
    final extension = extensionParts.length > 1 ? extensionParts.last : 'jpg';

    final url = await uploadProfileImage(
      userId: userId,
      bytes: bytes,
      fileExtension: extension,
    );

    await saveProfileImageUrl(userId: userId, imageUrl: url);
    return url;
  }

  Future<String> uploadProfileImage({
    required String userId,
    required Uint8List bytes,
    required String fileExtension,
  }) async {
    final path =
        '$userId/profile_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';

    await _client.storage.from('profile-images').uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );

    return _client.storage.from('profile-images').getPublicUrl(path);
  }

  Future<void> saveProfileImageUrl({
    required String userId,
    required String imageUrl,
  }) async {
    try {
      await _client.from('users').upsert(
        {
          'id': userId,
          'avatar_url': imageUrl,
          'updated_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'id',
      );
    } on PostgrestException catch (error) {
      if (_isUsersTableRlsDenied(error)) {
        throw Exception(_usersRlsMessage);
      }
      if (!_isMissingUsersTable(error)) {
        rethrow;
      }
    }
  }

  Future<UserProfileData> fetchUserProfile(String userId) async {
    try {
      final response = await _client
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();
      return UserProfileData.fromMap(response);
    } on PostgrestException catch (error) {
      if (_isMissingUsersTable(error)) {
        return const UserProfileData();
      }
      if (_isUsersTableRlsDenied(error)) {
        throw Exception(_usersRlsMessage);
      }
      rethrow;
    }
  }

  Future<void> savePersonalizationData({
    required String userId,
    required int age,
    required String gender,
    required double heightCm,
    required double weightKg,
  }) async {
    try {
      await _client.from('users').upsert(
        {
          'id': userId,
          'age': age,
          'gender': gender,
          'height_cm': heightCm,
          'weight_kg': weightKg,
          'updated_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'id',
      );
    } on PostgrestException catch (error) {
      if (_isMissingUsersTable(error)) {
        throw Exception(_missingUsersTableMessage);
      }
      if (_isUsersTableRlsDenied(error)) {
        throw Exception(_usersRlsMessage);
      }
      rethrow;
    }
  }

  bool _isMissingUsersTable(PostgrestException error) {
    return error.code == 'PGRST205' &&
        (error.message.contains("table 'public.users'") ||
            error.message.contains("table 'users'") ||
            error.message.contains("table 'public.user'") ||
            error.message.contains("table 'user'"));
  }

  bool _isUsersTableRlsDenied(PostgrestException error) {
    return error.code == '42501' &&
        error.message.contains('row-level security policy') &&
        error.message.contains('"users"');
  }
}
