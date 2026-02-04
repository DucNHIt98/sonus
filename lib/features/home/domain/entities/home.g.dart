// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HomeImpl _$$HomeImplFromJson(Map<String, dynamic> json) => _$HomeImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
    );

Map<String, dynamic> _$$HomeImplToJson(_$HomeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'subtitle': instance.subtitle,
      'imageUrl': instance.imageUrl,
    };
