import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  UserService(this._client, [ImagePicker? picker])
      : _picker = picker ?? ImagePicker();

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
      if (!_isMissingUsersTable(error)) {
        rethrow;
      }
    }
  }

  bool _isMissingUsersTable(PostgrestException error) {
    return error.code == 'PGRST205' &&
        (error.message.contains("table 'public.users'") ||
            error.message.contains("table 'users'"));
  }
}
