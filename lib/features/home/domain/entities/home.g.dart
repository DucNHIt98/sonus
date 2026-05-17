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
  audioUrl: json['audioUrl'] as String? ?? '',
  source: json['source'] as String? ?? 'youtube',
  youtubeId: json['youtubeId'] as String?,
  deezerId: json['deezerId'] as String?,
  jamendoId: json['jamendoId'] as String?,
  nctId: json['nctId'] as String?,
  duration: json['duration'] == null
      ? null
      : Duration(microseconds: (json['duration'] as num).toInt()),
);

Map<String, dynamic> _$$HomeImplToJson(_$HomeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'subtitle': instance.subtitle,
      'imageUrl': instance.imageUrl,
      'audioUrl': instance.audioUrl,
      'source': instance.source,
      'youtubeId': instance.youtubeId,
      'deezerId': instance.deezerId,
      'jamendoId': instance.jamendoId,
      'nctId': instance.nctId,
      'duration': instance.duration?.inMicroseconds,
    };
