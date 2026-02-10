import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/network/supabase_repository.dart';
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
    final repository = ref.read(supabaseRepositoryProvider);

    // Parallel fetch for efficiency
    final results = await Future.wait([
      repository.getUserProfile(),
      repository.getPlayHistoryCount(),
      repository.getFavoritesCount(),
      repository.getPlaylistsCount(),
      repository.getMostPlayedSongs(5), // Top 5 tracks based on play count
    ]);

    return ProfileState(
      userProfile: results[0] as Map<String, dynamic>?,
      playHistoryCount: results[1] as int,
      favoritesCount: results[2] as int,
      playlistsCount: results[3] as int,
      topTracks: results[4] as List<Home>,
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
      final repository = ref.read(supabaseRepositoryProvider);
      String? avatarUrl;

      if (avatarFile != null) {
        avatarUrl = await repository.uploadAvatar(avatarFile);
      }

      await repository.updateProfile(
        displayName: displayName,
        avatarUrl: avatarUrl,
      );

      // Refresh data to update UI
      state = await AsyncValue.guard(() => _loadProfileData());
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }
}
