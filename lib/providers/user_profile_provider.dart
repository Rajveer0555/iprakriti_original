import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_profile_model.dart';
import 'auth_provider.dart';

final profileAvatarOverrideProvider = StateProvider<String?>((ref) => null);

final currentUserProfileProvider = FutureProvider.autoDispose<UserProfileData>((
  ref,
) async {
  final userId = ref.watch(authControllerProvider).session?.user.id;
  if (userId == null) {
    return const UserProfileData();
  }

  return ref.watch(userServiceProvider).fetchUserProfile(userId);
});
