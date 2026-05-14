import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sonus/core/models/music_model.dart';
import 'package:sonus/core/network/dio_client.dart';

part 'jamendo_service.g.dart';

@Riverpod(keepAlive: true)
JamendoService jamendoService(JamendoServiceRef ref) {
  return JamendoService(ref.read(dioClientProvider));
}

class JamendoService {
  final Dio _dio;
  static const String _clientId = 'b5094ba5';

  JamendoService(this._dio);

  Future<List<MusicModel>> getDiscoveryMusic({int offset = 0}) async {
    try {
      final response = await _dio.get(
        'https://api.jamendo.com/v3.0/tracks/',
        queryParameters: {
          'client_id': _clientId,
          'format': 'json',
          'limit': 20,
          'offset': offset,
          'order': 'popularity_total',
          'include': 'musicinfo',
          'audioformat': 'mp31',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> results = response.data['results'];
        return results.map((track) => MusicModel.fromJamendo(track)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<MusicModel>> getTracksByGenre(String genre) async {
    try {
      final response = await _dio.get(
        'https://api.jamendo.com/v3.0/tracks/',
        queryParameters: {
          'client_id': _clientId,
          'format': 'json',
          'limit': 20,
          'tags': genre,
          'order': 'popularity_week',
          'include': 'musicinfo',
          'audioformat': 'mp31',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> results = response.data['results'];
        return results.map((track) {
          return MusicModel.fromJamendo(track, genre: genre);
        }).toList();
      }
      return [];
    } catch (e) {
      debugPrint('JamendoService Error (getTracksByGenre): $e');
      return [];
    }
  }

  Future<List<MusicModel>> searchSongs(String query) async {
    try {
      final response = await _dio.get(
        'https://api.jamendo.com/v3.0/tracks/',
        queryParameters: {
          'client_id': _clientId,
          'format': 'json',
          'search': query,
          'limit': 10,
          'include': 'musicinfo',
          'audioformat': 'mp31',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> results = response.data['results'];
        return results.map((track) => MusicModel.fromJamendo(track)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('JamendoService Search Error: $e');
      return [];
    }
  }
}
