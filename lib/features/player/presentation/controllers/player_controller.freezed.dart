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
  Home? get currentSong => throw _privateConstructorUsedError;
  List<Home> get queue => throw _privateConstructorUsedError;
  int get currentIndex => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  List<Home> get aiRecommendations => throw _privateConstructorUsedError;

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
      {Home? currentSong,
      List<Home> queue,
      int currentIndex,
      bool isLoading,
      String? error,
      List<Home> aiRecommendations});

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
    Object? currentSong = freezed,
    Object? queue = null,
    Object? currentIndex = null,
    Object? isLoading = null,
    Object? error = freezed,
    Object? aiRecommendations = null,
  }) {
    return _then(_value.copyWith(
      currentSong: freezed == currentSong
          ? _value.currentSong
          : currentSong // ignore: cast_nullable_to_non_nullable
              as Home?,
      queue: null == queue
          ? _value.queue
          : queue // ignore: cast_nullable_to_non_nullable
              as List<Home>,
      currentIndex: null == currentIndex
          ? _value.currentIndex
          : currentIndex // ignore: cast_nullable_to_non_nullable
              as int,
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
      {Home? currentSong,
      List<Home> queue,
      int currentIndex,
      bool isLoading,
      String? error,
      List<Home> aiRecommendations});

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
    Object? currentSong = freezed,
    Object? queue = null,
    Object? currentIndex = null,
    Object? isLoading = null,
    Object? error = freezed,
    Object? aiRecommendations = null,
  }) {
    return _then(_$PlayerStateImpl(
      currentSong: freezed == currentSong
          ? _value.currentSong
          : currentSong // ignore: cast_nullable_to_non_nullable
              as Home?,
      queue: null == queue
          ? _value._queue
          : queue // ignore: cast_nullable_to_non_nullable
              as List<Home>,
      currentIndex: null == currentIndex
          ? _value.currentIndex
          : currentIndex // ignore: cast_nullable_to_non_nullable
              as int,
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
    ));
  }
}

/// @nodoc

class _$PlayerStateImpl implements _PlayerState {
  const _$PlayerStateImpl(
      {this.currentSong,
      final List<Home> queue = const [],
      this.currentIndex = 0,
      this.isLoading = false,
      this.error,
      final List<Home> aiRecommendations = const []})
      : _queue = queue,
        _aiRecommendations = aiRecommendations;

  @override
  final Home? currentSong;
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
  String toString() {
    return 'PlayerState(currentSong: $currentSong, queue: $queue, currentIndex: $currentIndex, isLoading: $isLoading, error: $error, aiRecommendations: $aiRecommendations)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlayerStateImpl &&
            (identical(other.currentSong, currentSong) ||
                other.currentSong == currentSong) &&
            const DeepCollectionEquality().equals(other._queue, _queue) &&
            (identical(other.currentIndex, currentIndex) ||
                other.currentIndex == currentIndex) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            const DeepCollectionEquality()
                .equals(other._aiRecommendations, _aiRecommendations));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      currentSong,
      const DeepCollectionEquality().hash(_queue),
      currentIndex,
      isLoading,
      error,
      const DeepCollectionEquality().hash(_aiRecommendations));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PlayerStateImplCopyWith<_$PlayerStateImpl> get copyWith =>
      __$$PlayerStateImplCopyWithImpl<_$PlayerStateImpl>(this, _$identity);
}

abstract class _PlayerState implements PlayerState {
  const factory _PlayerState(
      {final Home? currentSong,
      final List<Home> queue,
      final int currentIndex,
      final bool isLoading,
      final String? error,
      final List<Home> aiRecommendations}) = _$PlayerStateImpl;

  @override
  Home? get currentSong;
  @override
  List<Home> get queue;
  @override
  int get currentIndex;
  @override
  bool get isLoading;
  @override
  String? get error;
  @override
  List<Home> get aiRecommendations;
  @override
  @JsonKey(ignore: true)
  _$$PlayerStateImplCopyWith<_$PlayerStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
