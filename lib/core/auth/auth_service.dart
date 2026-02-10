import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../network/supabase_provider.dart';

part 'auth_service.g.dart';

@Riverpod(keepAlive: true)
AuthService authService(AuthServiceRef ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return AuthService(supabase);
}

class AuthService {
  final SupabaseClient _supabase;

  AuthService(this._supabase);

  /// Performs user registration with username uniqueness check.
  Future<AuthResponse> signUpWithUsername({
    required String email,
    required String password,
    required String username,
    String? fullName,
  }) async {
    try {
      // 1. Check if username already exists
      final existing = await _supabase
          .from('users')
          .select('username')
          .eq('username', username)
          .maybeSingle();

      if (existing != null) {
        throw 'Tên người dùng đã bị chiếm';
      }

      // 2. Proceed with sign up
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'username': username, 'full_name': fullName ?? username},
      );

      return response;
    } on AuthException catch (e) {
      debugPrint(
        'DEBUG: AuthException during sign up: ${e.message} (Code: ${e.statusCode})',
      );
      if (e.message == 'User already registered') {
        throw 'Email này đã được đăng ký';
      }
      if (e.message.contains('Database error saving new user')) {
        throw 'Tên người dùng đã bị chiếm hoặc lỗi hệ thống. Vui lòng thử username khác.';
      }
      rethrow;
    } catch (e) {
      if (e is String) rethrow;
      debugPrint('DEBUG: Unexpected error during sign up: $e');
      rethrow;
    }
  }

  /// Performs user registration with detailed error handling.
  @Deprecated('Use signUpWithUsername instead')
  Future<AuthResponse> signUp({
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
  Future<AuthResponse> loginWithUsername({
    required String username,
    required String password,
  }) async {
    try {
      // 1. Find email by username in public.users
      final userRow = await _supabase
          .from('users')
          .select('email')
          .eq('username', username)
          .maybeSingle();

      if (userRow == null) {
        throw 'Thông tin đăng nhập không chính xác';
      }

      final email = userRow['email'] as String;

      // 2. Sign in with the retrieved email
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      return response;
    } on AuthException catch (_) {
      // General error for security reasons
      throw 'Thông tin đăng nhập không chính xác';
    } catch (e) {
      if (e is String) rethrow;
      debugPrint('DEBUG: Unexpected error during login: $e');
      throw 'Đã xảy ra lỗi, vui lòng thử lại sau';
    }
  }

  /// Performs user login.
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user != null) {
      await _syncUser(response.user!);
    }

    return response;
  }

  /// Performs Google Sign-In and syncs user info to database.
  Future<AuthResponse?> signInWithGoogle() async {
    try {
      // 1. Initial Google Sign-In
      final googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
      final googleUser = await googleSignIn.signIn();

      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null) {
        throw 'No ID Token found.';
      }

      // 2. Sign in with Supabase using ID Token
      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      // 3. Sync user info to database
      if (response.user != null) {
        await _syncUser(response.user!);
      }

      return response;
    } catch (e) {
      debugPrint('DEBUG: Error during Google Sign-In: $e');
      rethrow;
    }
  }

  /// Syncs user basic information to 'public.users' table
  Future<void> _syncUser(User user) async {
    try {
      final userData = {
        'id': user.id,
        'email': user.email,
        'full_name':
            user.userMetadata?['full_name'] ?? user.userMetadata?['name'] ?? '',
        'avatar_url':
            user.userMetadata?['avatar_url'] ??
            user.userMetadata?['picture'] ??
            '',
        'created_at': DateTime.now().toIso8601String(),
      };

      await _supabase.from('users').upsert(userData);
      debugPrint('Supabase: Synced user profile for ${user.email}');
    } catch (e) {
      // Log error but don't block login
      debugPrint('DEBUG: Error syncing user to database: $e');
    }
  }

  /// Retrieves the current user information from 'public.users' table.
  /// Assumes the table 'users' exists in the public schema and is keyed by 'id'.
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', user.id)
          .single();

      return response;
    } catch (_) {
      return null;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
