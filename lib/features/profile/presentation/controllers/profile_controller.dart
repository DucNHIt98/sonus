import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/auth/auth_service.dart';
import '../../../home/domain/entities/home.dart';

part 'profile_controller.freezed.dart';
part 'profile_controller.g.dart';

@freezed
class ProfileState with _$ProfileState {
  const factory ProfileState({
    Map<String, dynamic>? userProfile,
    @Default(0) int playHistoryCount,
    @Default(0) int favoritesCount,
    @Default(0) int playlistsCount,
    @Default([]) List<Home> topTracks,
    @Default(false) bool isLoading,
    String? error,
  }) = _ProfileState;
}

@riverpod
class ProfileController extends _$ProfileController {
  @override
  FutureOr<ProfileState> build() async {
    return _loadProfileData();
  }

  Future<ProfileState> _loadProfileData() async {
    final userProfile = await ref.read(authServiceProvider).getCurrentUser();
    final stats = userProfile?['stats'] as Map<String, dynamic>?;

    return ProfileState(
      userProfile: userProfile,
      playHistoryCount: stats?['listened_count'] as int? ?? 0,
      favoritesCount: stats?['favorites_count'] as int? ?? 0,
      playlistsCount: stats?['playlists_count'] as int? ?? 0,
      topTracks: const [],
      isLoading: false,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadProfileData());
  }

  Future<void> updateProfile({String? displayName, File? avatarFile}) async {
    state = const AsyncValue.loading();

    try {
      if (avatarFile != null) {
        throw 'Avatar upload sẽ được chuyển sang backend ở phase sau';
      }

      await ref
          .read(authServiceProvider)
          .updateCurrentUser(displayName: displayName);

      // Refresh data to update UI
      state = await AsyncValue.guard(() => _loadProfileData());
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }
}
