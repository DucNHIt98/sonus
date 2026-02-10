// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'player_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$PlayerState {
  List<Home> get queue => throw _privateConstructorUsedError;
  int get currentIndex => throw _privateConstructorUsedError;
  Home? get currentSong => throw _privateConstructorUsedError;
  bool get isPlaying => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  List<Home> get aiRecommendations => throw _privateConstructorUsedError;
  LoopMode get repeatMode => throw _privateConstructorUsedError;
  bool get isShuffleModeEnabled => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $PlayerStateCopyWith<PlayerState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlayerStateCopyWith<$Res> {
  factory $PlayerStateCopyWith(
          PlayerState value, $Res Function(PlayerState) then) =
      _$PlayerStateCopyWithImpl<$Res, PlayerState>;
  @useResult
  $Res call(
      {List<Home> queue,
      int currentIndex,
      Home? currentSong,
      bool isPlaying,
      bool isLoading,
      String? error,
      List<Home> aiRecommendations,
      LoopMode repeatMode,
      bool isShuffleModeEnabled});

  $HomeCopyWith<$Res>? get currentSong;
}

/// @nodoc
class _$PlayerStateCopyWithImpl<$Res, $Val extends PlayerState>
    implements $PlayerStateCopyWith<$Res> {
  _$PlayerStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? queue = null,
    Object? currentIndex = null,
    Object? currentSong = freezed,
    Object? isPlaying = null,
    Object? isLoading = null,
    Object? error = freezed,
    Object? aiRecommendations = null,
    Object? repeatMode = null,
    Object? isShuffleModeEnabled = null,
  }) {
    return _then(_value.copyWith(
      queue: null == queue
          ? _value.queue
          : queue // ignore: cast_nullable_to_non_nullable
              as List<Home>,
      currentIndex: null == currentIndex
          ? _value.currentIndex
          : currentIndex // ignore: cast_nullable_to_non_nullable
              as int,
      currentSong: freezed == currentSong
          ? _value.currentSong
          : currentSong // ignore: cast_nullable_to_non_nullable
              as Home?,
      isPlaying: null == isPlaying
          ? _value.isPlaying
          : isPlaying // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      aiRecommendations: null == aiRecommendations
          ? _value.aiRecommendations
          : aiRecommendations // ignore: cast_nullable_to_non_nullable
              as List<Home>,
      repeatMode: null == repeatMode
          ? _value.repeatMode
          : repeatMode // ignore: cast_nullable_to_non_nullable
              as LoopMode,
      isShuffleModeEnabled: null == isShuffleModeEnabled
          ? _value.isShuffleModeEnabled
          : isShuffleModeEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $HomeCopyWith<$Res>? get currentSong {
    if (_value.currentSong == null) {
      return null;
    }

    return $HomeCopyWith<$Res>(_value.currentSong!, (value) {
      return _then(_value.copyWith(currentSong: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PlayerStateImplCopyWith<$Res>
    implements $PlayerStateCopyWith<$Res> {
  factory _$$PlayerStateImplCopyWith(
          _$PlayerStateImpl value, $Res Function(_$PlayerStateImpl) then) =
      __$$PlayerStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<Home> queue,
      int currentIndex,
      Home? currentSong,
      bool isPlaying,
      bool isLoading,
      String? error,
      List<Home> aiRecommendations,
      LoopMode repeatMode,
      bool isShuffleModeEnabled});

  @override
  $HomeCopyWith<$Res>? get currentSong;
}

/// @nodoc
class __$$PlayerStateImplCopyWithImpl<$Res>
    extends _$PlayerStateCopyWithImpl<$Res, _$PlayerStateImpl>
    implements _$$PlayerStateImplCopyWith<$Res> {
  __$$PlayerStateImplCopyWithImpl(
      _$PlayerStateImpl _value, $Res Function(_$PlayerStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? queue = null,
    Object? currentIndex = null,
    Object? currentSong = freezed,
    Object? isPlaying = null,
    Object? isLoading = null,
    Object? error = freezed,
    Object? aiRecommendations = null,
    Object? repeatMode = null,
    Object? isShuffleModeEnabled = null,
  }) {
    return _then(_$PlayerStateImpl(
      queue: null == queue
          ? _value._queue
          : queue // ignore: cast_nullable_to_non_nullable
              as List<Home>,
      currentIndex: null == currentIndex
          ? _value.currentIndex
          : currentIndex // ignore: cast_nullable_to_non_nullable
              as int,
      currentSong: freezed == currentSong
          ? _value.currentSong
          : currentSong // ignore: cast_nullable_to_non_nullable
              as Home?,
      isPlaying: null == isPlaying
          ? _value.isPlaying
          : isPlaying // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      aiRecommendations: null == aiRecommendations
          ? _value._aiRecommendations
          : aiRecommendations // ignore: cast_nullable_to_non_nullable
              as List<Home>,
      repeatMode: null == repeatMode
          ? _value.repeatMode
          : repeatMode // ignore: cast_nullable_to_non_nullable
              as LoopMode,
      isShuffleModeEnabled: null == isShuffleModeEnabled
          ? _value.isShuffleModeEnabled
          : isShuffleModeEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$PlayerStateImpl implements _PlayerState {
  const _$PlayerStateImpl(
      {final List<Home> queue = const [],
      this.currentIndex = -1,
      this.currentSong,
      this.isPlaying = false,
      this.isLoading = false,
      this.error,
      final List<Home> aiRecommendations = const [],
      this.repeatMode = LoopMode.off,
      this.isShuffleModeEnabled = false})
      : _queue = queue,
        _aiRecommendations = aiRecommendations;

  final List<Home> _queue;
  @override
  @JsonKey()
  List<Home> get queue {
    if (_queue is EqualUnmodifiableListView) return _queue;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_queue);
  }

  @override
  @JsonKey()
  final int currentIndex;
  @override
  final Home? currentSong;
  @override
  @JsonKey()
  final bool isPlaying;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? error;
  final List<Home> _aiRecommendations;
  @override
  @JsonKey()
  List<Home> get aiRecommendations {
    if (_aiRecommendations is EqualUnmodifiableListView)
      return _aiRecommendations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_aiRecommendations);
  }

  @override
  @JsonKey()
  final LoopMode repeatMode;
  @override
  @JsonKey()
  final bool isShuffleModeEnabled;

  @override
  String toString() {
    return 'PlayerState(queue: $queue, currentIndex: $currentIndex, currentSong: $currentSong, isPlaying: $isPlaying, isLoading: $isLoading, error: $error, aiRecommendations: $aiRecommendations, repeatMode: $repeatMode, isShuffleModeEnabled: $isShuffleModeEnabled)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlayerStateImpl &&
            const DeepCollectionEquality().equals(other._queue, _queue) &&
            (identical(other.currentIndex, currentIndex) ||
                other.currentIndex == currentIndex) &&
            (identical(other.currentSong, currentSong) ||
                other.currentSong == currentSong) &&
            (identical(other.isPlaying, isPlaying) ||
                other.isPlaying == isPlaying) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            const DeepCollectionEquality()
                .equals(other._aiRecommendations, _aiRecommendations) &&
            (identical(other.repeatMode, repeatMode) ||
                other.repeatMode == repeatMode) &&
            (identical(other.isShuffleModeEnabled, isShuffleModeEnabled) ||
                other.isShuffleModeEnabled == isShuffleModeEnabled));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_queue),
      currentIndex,
      currentSong,
      isPlaying,
      isLoading,
      error,
      const DeepCollectionEquality().hash(_aiRecommendations),
      repeatMode,
      isShuffleModeEnabled);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PlayerStateImplCopyWith<_$PlayerStateImpl> get copyWith =>
      __$$PlayerStateImplCopyWithImpl<_$PlayerStateImpl>(this, _$identity);
}

abstract class _PlayerState implements PlayerState {
  const factory _PlayerState(
      {final List<Home> queue,
      final int currentIndex,
      final Home? currentSong,
      final bool isPlaying,
      final bool isLoading,
      final String? error,
      final List<Home> aiRecommendations,
      final LoopMode repeatMode,
      final bool isShuffleModeEnabled}) = _$PlayerStateImpl;

  @override
  List<Home> get queue;
  @override
  int get currentIndex;
  @override
  Home? get currentSong;
  @override
  bool get isPlaying;
  @override
  bool get isLoading;
  @override
  String? get error;
  @override
  List<Home> get aiRecommendations;
  @override
  LoopMode get repeatMode;
  @override
  bool get isShuffleModeEnabled;
  @override
  @JsonKey(ignore: true)
  _$$PlayerStateImplCopyWith<_$PlayerStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
