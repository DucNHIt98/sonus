// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'splash.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Splash _$SplashFromJson(Map<String, dynamic> json) {
  return _Splash.fromJson(json);
}

/// @nodoc
mixin _$Splash {
  String get status => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SplashCopyWith<Splash> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SplashCopyWith<$Res> {
  factory $SplashCopyWith(Splash value, $Res Function(Splash) then) =
      _$SplashCopyWithImpl<$Res, Splash>;
  @useResult
  $Res call({String status});
}

/// @nodoc
class _$SplashCopyWithImpl<$Res, $Val extends Splash>
    implements $SplashCopyWith<$Res> {
  _$SplashCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
  }) {
    return _then(_value.copyWith(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SplashImplCopyWith<$Res> implements $SplashCopyWith<$Res> {
  factory _$$SplashImplCopyWith(
          _$SplashImpl value, $Res Function(_$SplashImpl) then) =
      __$$SplashImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String status});
}

/// @nodoc
class __$$SplashImplCopyWithImpl<$Res>
    extends _$SplashCopyWithImpl<$Res, _$SplashImpl>
    implements _$$SplashImplCopyWith<$Res> {
  __$$SplashImplCopyWithImpl(
      _$SplashImpl _value, $Res Function(_$SplashImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
  }) {
    return _then(_$SplashImpl(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SplashImpl implements _Splash {
  const _$SplashImpl({required this.status});

  factory _$SplashImpl.fromJson(Map<String, dynamic> json) =>
      _$$SplashImplFromJson(json);

  @override
  final String status;

  @override
  String toString() {
    return 'Splash(status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SplashImpl &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, status);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SplashImplCopyWith<_$SplashImpl> get copyWith =>
      __$$SplashImplCopyWithImpl<_$SplashImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SplashImplToJson(
      this,
    );
  }
}

abstract class _Splash implements Splash {
  const factory _Splash({required final String status}) = _$SplashImpl;

  factory _Splash.fromJson(Map<String, dynamic> json) = _$SplashImpl.fromJson;

  @override
  String get status;
  @override
  @JsonKey(ignore: true)
  _$$SplashImplCopyWith<_$SplashImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
