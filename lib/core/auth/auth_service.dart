import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../network/dio_client.dart';
import '../network/supabase_provider.dart';

part 'auth_service.g.dart';

@Riverpod(keepAlive: true)
AuthService authService(AuthServiceRef ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return AuthService(supabase);
}

class AuthService {
  static const _tokenKey = 'sonus_backend_token';

  final SupabaseClient _supabase;
  final Dio _dio = Dio(BaseOptions(baseUrl: '$kBackendBaseUrl/api'));

  // Single instance of GoogleSignIn for consistency
  final _googleSignIn = GoogleSignIn(
    clientId: defaultTargetPlatform == TargetPlatform.iOS
        ? '715942914082-1h6dtjhb9400oa8n70gkbmn4g56amalo.apps.googleusercontent.com'
        : null,
    serverClientId:
        '715942914082-69ef0n1657t80mktp9jo3imera2vv91m.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );

  AuthService(this._supabase);

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<BackendAuthResult> _storeAuthResponse(Response response) async {
    final data = Map<String, dynamic>.from(response.data as Map);
    final token = data['token'] as String;
    await _saveToken(token);
    return BackendAuthResult(
      user: Map<String, dynamic>.from(data['user'] as Map),
      token: token,
      expiresAt: data['expires_at'] as String?,
    );
  }

  String _messageFromDioError(DioException error, String fallback) {
    final data = error.response?.data;
    if (data is Map && data['detail'] != null) return data['detail'].toString();
    if (data is Map && data['non_field_errors'] is List) {
      return (data['non_field_errors'] as List).join('\n');
    }
    if (data is Map && data.isNotEmpty) {
      final first = data.values.first;
      if (first is List && first.isNotEmpty) return first.first.toString();
      return first.toString();
    }
    return fallback;
  }

  /// Performs user registration with username uniqueness check.
  Future<BackendAuthResult> signUpWithUsername({
    required String email,
    required String password,
    required String username,
    String? fullName,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/register/',
        data: {
          'email': email,
          'password': password,
          'username': username,
          'display_name': fullName ?? username,
        },
      );
      return _storeAuthResponse(response);
    } on DioException catch (e) {
      throw _messageFromDioError(e, 'Đăng ký thất bại');
    } catch (e) {
      if (e is String) rethrow;
      debugPrint('DEBUG: Unexpected error during sign up: $e');
      rethrow;
    }
  }

  /// Performs user registration with detailed error handling.
  @Deprecated('Use signUpWithUsername instead')
  Future<BackendAuthResult> signUp({
    required String email,
    required String password,
    required String name,
    required String username,
  }) async {
    return signUpWithUsername(
      email: email,
      password: password,
      username: username,
      fullName: name,
    );
  }

  /// Performs user login using username instead of email.
  Future<BackendAuthResult> loginWithUsername({
    required String username,
    required String password,
  }) async {
    try {
      return signIn(email: username, password: password);
    } on DioException catch (e) {
      throw _messageFromDioError(e, 'Thông tin đăng nhập không chính xác');
    } catch (e) {
      if (e is String) rethrow;
      debugPrint('DEBUG: Unexpected error during login: $e');
      throw 'Đã xảy ra lỗi, vui lòng thử lại sau';
    }
  }

  /// Performs user login.
  Future<BackendAuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/login/',
        data: {'email': email, 'password': password},
      );
      return _storeAuthResponse(response);
    } on DioException catch (e) {
      throw _messageFromDioError(e, 'Thông tin đăng nhập không chính xác');
    }
  }

  /// Performs Google Sign-In and syncs user info to database.
  Future<BackendAuthResult?> signInWithGoogle() async {
    try {
      // Note: For iOS, you may need to provide the iosClientId here if you
      // don't have GoogleService-Info.plist correctly integrated.
      // For Supabase to receive an ID Token, you MUST provide the webClientId
      // (from Google Cloud Console -> Credentials -> Web Client ID) as serverClientId.

      final googleUser = await _googleSignIn.signIn();

      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null) {
        throw 'Không tìm thấy ID Token từ Google.';
      }

      // 2. Sign in with Supabase using ID Token
      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
        nonce: _nonceFromIdToken(idToken),
      );

      final supabaseAccessToken = response.session?.accessToken;
      if (supabaseAccessToken == null) {
        throw 'Không nhận được Supabase access token.';
      }

      final backendResponse = await _dio.post(
        '/auth/google/',
        data: {'token': supabaseAccessToken},
      );
      return _storeAuthResponse(backendResponse);
    } catch (e) {
      debugPrint('DEBUG: Error during Google Sign-In: $e');
      rethrow;
    }
  }

  String? _nonceFromIdToken(String idToken) {
    final parts = idToken.split('.');
    if (parts.length != 3) return null;

    try {
      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final claims = jsonDecode(payload) as Map<String, dynamic>;
      return claims['nonce'] as String?;
    } catch (_) {
      return null;
    }
  }

  Future<bool> hasValidSession() async {
    return await getCurrentUser() != null;
  }

  /// Retrieves the current user information from the Sonus backend.
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final token = await getToken();
    if (token == null) return null;

    try {
      final response = await _dio.get(
        '/auth/me/',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException {
      await _clearToken();
      return null;
    }
  }

  Future<Map<String, dynamic>> updateCurrentUser({String? displayName}) async {
    final token = await getToken();
    if (token == null) throw 'Bạn chưa đăng nhập';
    final response = await _dio.patch(
      '/auth/me/',
      data: {'display_name': displayName},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// Sign out
  Future<void> signOut() async {
    final token = await getToken();
    if (token != null) {
      try {
        await _dio.post(
          '/auth/logout/',
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );
      } catch (e) {
        debugPrint('DEBUG: Backend logout failed: $e');
      }
    }
    await _clearToken();
    await _supabase.auth.signOut();
    try {
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
    } catch (e) {
      debugPrint('DEBUG: Error signing out from Google: $e');
    }
  }
}

class BackendAuthResult {
  final Map<String, dynamic> user;
  final String token;
  final String? expiresAt;

  BackendAuthResult({
    required this.user,
    required this.token,
    required this.expiresAt,
  });
}
