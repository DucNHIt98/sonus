import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sonus/core/network/dio_client.dart';
import 'package:sonus/features/premium/data/models/subscription_status.dart';

part 'premium_repository.g.dart';

@Riverpod(keepAlive: true)
PremiumRepository premiumRepository(PremiumRepositoryRef ref) {
  return PremiumRepository(ref.read(dioClientProvider));
}

class PremiumRepository {
  final Dio _dio;

  PremiumRepository(this._dio);

  Future<String?> createCheckoutSession({
    required String successUrl,
    required String cancelUrl,
  }) async {
    try {
      final response = await _dio.post(
        '/api/payments/create-checkout-session/',
        data: {
          'success_url': successUrl,
          'cancel_url': cancelUrl,
        },
      );
      return response.data['url'] as String?;
    } catch (e) {
      debugPrint('createCheckoutSession error: $e');
      return null;
    }
  }

  Future<SubscriptionStatus> getSubscriptionStatus() async {
    try {
      final response = await _dio.get(
        '/api/payments/subscription/',
      );
      return SubscriptionStatus.fromJson(response.data);
    } catch (e) {
      debugPrint('getSubscriptionStatus error: $e');
      return SubscriptionStatus.notPremium();
    }
  }

  Future<bool> cancelSubscription() async {
    try {
      final response = await _dio.post(
        '/api/payments/subscription/cancel/',
      );
      return response.data['status'] == 'success';
    } catch (e) {
      debugPrint('cancelSubscription error: $e');
      return false;
    }
  }
}
