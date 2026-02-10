// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'artist_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ArtistData {
  Channel? get channel => throw _privateConstructorUsedError;
  List<Video> get songs => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ArtistDataCopyWith<ArtistData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ArtistDataCopyWith<$Res> {
  factory $ArtistDataCopyWith(
          ArtistData value, $Res Function(ArtistData) then) =
      _$ArtistDataCopyWithImpl<$Res, ArtistData>;
  @useResult
  $Res call({Channel? channel, List<Video> songs});

  $ChannelCopyWith<$Res>? get channel;
}

/// @nodoc
class _$ArtistDataCopyWithImpl<$Res, $Val extends ArtistData>
    implements $ArtistDataCopyWith<$Res> {
  _$ArtistDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? channel = freezed,
    Object? songs = null,
  }) {
    return _then(_value.copyWith(
      channel: freezed == channel
          ? _value.channel
          : channel // ignore: cast_nullable_to_non_nullable
              as Channel?,
      songs: null == songs
          ? _value.songs
          : songs // ignore: cast_nullable_to_non_nullable
              as List<Video>,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $ChannelCopyWith<$Res>? get channel {
    if (_value.channel == null) {
      return null;
    }

    return $ChannelCopyWith<$Res>(_value.channel!, (value) {
      return _then(_value.copyWith(channel: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ArtistDataImplCopyWith<$Res>
    implements $ArtistDataCopyWith<$Res> {
  factory _$$ArtistDataImplCopyWith(
          _$ArtistDataImpl value, $Res Function(_$ArtistDataImpl) then) =
      __$$ArtistDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Channel? channel, List<Video> songs});

  @override
  $ChannelCopyWith<$Res>? get channel;
}

/// @nodoc
class __$$ArtistDataImplCopyWithImpl<$Res>
    extends _$ArtistDataCopyWithImpl<$Res, _$ArtistDataImpl>
    implements _$$ArtistDataImplCopyWith<$Res> {
  __$$ArtistDataImplCopyWithImpl(
      _$ArtistDataImpl _value, $Res Function(_$ArtistDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? channel = freezed,
    Object? songs = null,
  }) {
    return _then(_$ArtistDataImpl(
      channel: freezed == channel
          ? _value.channel
          : channel // ignore: cast_nullable_to_non_nullable
              as Channel?,
      songs: null == songs
          ? _value._songs
          : songs // ignore: cast_nullable_to_non_nullable
              as List<Video>,
    ));
  }
}

/// @nodoc

class _$ArtistDataImpl implements _ArtistData {
  const _$ArtistDataImpl({this.channel, final List<Video> songs = const []})
      : _songs = songs;

  @override
  final Channel? channel;
  final List<Video> _songs;
  @override
  @JsonKey()
  List<Video> get songs {
    if (_songs is EqualUnmodifiableListView) return _songs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_songs);
  }

  @override
  String toString() {
    return 'ArtistData(channel: $channel, songs: $songs)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ArtistDataImpl &&
            (identical(other.channel, channel) || other.channel == channel) &&
            const DeepCollectionEquality().equals(other._songs, _songs));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, channel, const DeepCollectionEquality().hash(_songs));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ArtistDataImplCopyWith<_$ArtistDataImpl> get copyWith =>
      __$$ArtistDataImplCopyWithImpl<_$ArtistDataImpl>(this, _$identity);
}

abstract class _ArtistData implements ArtistData {
  const factory _ArtistData({final Channel? channel, final List<Video> songs}) =
      _$ArtistDataImpl;

  @override
  Channel? get channel;
  @override
  List<Video> get songs;
  @override
  @JsonKey(ignore: true)
  _$$ArtistDataImplCopyWith<_$ArtistDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
