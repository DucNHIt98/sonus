// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ProfileState {
  Map<String, dynamic>? get userProfile => throw _privateConstructorUsedError;
  int get playHistoryCount => throw _privateConstructorUsedError;
  int get favoritesCount => throw _privateConstructorUsedError;
  int get playlistsCount => throw _privateConstructorUsedError;
  List<Home> get topTracks => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ProfileStateCopyWith<ProfileState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProfileStateCopyWith<$Res> {
  factory $ProfileStateCopyWith(
          ProfileState value, $Res Function(ProfileState) then) =
      _$ProfileStateCopyWithImpl<$Res, ProfileState>;
  @useResult
  $Res call(
      {Map<String, dynamic>? userProfile,
      int playHistoryCount,
      int favoritesCount,
      int playlistsCount,
      List<Home> topTracks,
      bool isLoading,
      String? error});
}

/// @nodoc
class _$ProfileStateCopyWithImpl<$Res, $Val extends ProfileState>
    implements $ProfileStateCopyWith<$Res> {
  _$ProfileStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userProfile = freezed,
    Object? playHistoryCount = null,
    Object? favoritesCount = null,
    Object? playlistsCount = null,
    Object? topTracks = null,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      userProfile: freezed == userProfile
          ? _value.userProfile
          : userProfile // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      playHistoryCount: null == playHistoryCount
          ? _value.playHistoryCount
          : playHistoryCount // ignore: cast_nullable_to_non_nullable
              as int,
      favoritesCount: null == favoritesCount
          ? _value.favoritesCount
          : favoritesCount // ignore: cast_nullable_to_non_nullable
              as int,
      playlistsCount: null == playlistsCount
          ? _value.playlistsCount
          : playlistsCount // ignore: cast_nullable_to_non_nullable
              as int,
      topTracks: null == topTracks
          ? _value.topTracks
          : topTracks // ignore: cast_nullable_to_non_nullable
              as List<Home>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProfileStateImplCopyWith<$Res>
    implements $ProfileStateCopyWith<$Res> {
  factory _$$ProfileStateImplCopyWith(
          _$ProfileStateImpl value, $Res Function(_$ProfileStateImpl) then) =
      __$$ProfileStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Map<String, dynamic>? userProfile,
      int playHistoryCount,
      int favoritesCount,
      int playlistsCount,
      List<Home> topTracks,
      bool isLoading,
      String? error});
}

/// @nodoc
class __$$ProfileStateImplCopyWithImpl<$Res>
    extends _$ProfileStateCopyWithImpl<$Res, _$ProfileStateImpl>
    implements _$$ProfileStateImplCopyWith<$Res> {
  __$$ProfileStateImplCopyWithImpl(
      _$ProfileStateImpl _value, $Res Function(_$ProfileStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userProfile = freezed,
    Object? playHistoryCount = null,
    Object? favoritesCount = null,
    Object? playlistsCount = null,
    Object? topTracks = null,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(_$ProfileStateImpl(
      userProfile: freezed == userProfile
          ? _value._userProfile
          : userProfile // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      playHistoryCount: null == playHistoryCount
          ? _value.playHistoryCount
          : playHistoryCount // ignore: cast_nullable_to_non_nullable
              as int,
      favoritesCount: null == favoritesCount
          ? _value.favoritesCount
          : favoritesCount // ignore: cast_nullable_to_non_nullable
              as int,
      playlistsCount: null == playlistsCount
          ? _value.playlistsCount
          : playlistsCount // ignore: cast_nullable_to_non_nullable
              as int,
      topTracks: null == topTracks
          ? _value._topTracks
          : topTracks // ignore: cast_nullable_to_non_nullable
              as List<Home>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$ProfileStateImpl implements _ProfileState {
  const _$ProfileStateImpl(
      {final Map<String, dynamic>? userProfile,
      this.playHistoryCount = 0,
      this.favoritesCount = 0,
      this.playlistsCount = 0,
      final List<Home> topTracks = const [],
      this.isLoading = false,
      this.error})
      : _userProfile = userProfile,
        _topTracks = topTracks;

  final Map<String, dynamic>? _userProfile;
  @override
  Map<String, dynamic>? get userProfile {
    final value = _userProfile;
    if (value == null) return null;
    if (_userProfile is EqualUnmodifiableMapView) return _userProfile;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey()
  final int playHistoryCount;
  @override
  @JsonKey()
  final int favoritesCount;
  @override
  @JsonKey()
  final int playlistsCount;
  final List<Home> _topTracks;
  @override
  @JsonKey()
  List<Home> get topTracks {
    if (_topTracks is EqualUnmodifiableListView) return _topTracks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_topTracks);
  }

  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? error;

  @override
  String toString() {
    return 'ProfileState(userProfile: $userProfile, playHistoryCount: $playHistoryCount, favoritesCount: $favoritesCount, playlistsCount: $playlistsCount, topTracks: $topTracks, isLoading: $isLoading, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProfileStateImpl &&
            const DeepCollectionEquality()
                .equals(other._userProfile, _userProfile) &&
            (identical(other.playHistoryCount, playHistoryCount) ||
                other.playHistoryCount == playHistoryCount) &&
            (identical(other.favoritesCount, favoritesCount) ||
                other.favoritesCount == favoritesCount) &&
            (identical(other.playlistsCount, playlistsCount) ||
                other.playlistsCount == playlistsCount) &&
            const DeepCollectionEquality()
                .equals(other._topTracks, _topTracks) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_userProfile),
      playHistoryCount,
      favoritesCount,
      playlistsCount,
      const DeepCollectionEquality().hash(_topTracks),
      isLoading,
      error);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ProfileStateImplCopyWith<_$ProfileStateImpl> get copyWith =>
      __$$ProfileStateImplCopyWithImpl<_$ProfileStateImpl>(this, _$identity);
}

abstract class _ProfileState implements ProfileState {
  const factory _ProfileState(
      {final Map<String, dynamic>? userProfile,
      final int playHistoryCount,
      final int favoritesCount,
      final int playlistsCount,
      final List<Home> topTracks,
      final bool isLoading,
      final String? error}) = _$ProfileStateImpl;

  @override
  Map<String, dynamic>? get userProfile;
  @override
  int get playHistoryCount;
  @override
  int get favoritesCount;
  @override
  int get playlistsCount;
  @override
  List<Home> get topTracks;
  @override
  bool get isLoading;
  @override
  String? get error;
  @override
  @JsonKey(ignore: true)
  _$$ProfileStateImplCopyWith<_$ProfileStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
