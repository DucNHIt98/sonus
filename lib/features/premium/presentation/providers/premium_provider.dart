import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sonus/features/premium/data/models/subscription_status.dart';
import 'package:sonus/features/premium/data/repositories/premium_repository.dart';

part 'premium_provider.g.dart';

@Riverpod(keepAlive: true)
class PremiumController extends _$PremiumController {
  @override
  Future<SubscriptionStatus> build() async {
    return _fetchStatus();
  }

  Future<SubscriptionStatus> _fetchStatus() async {
    final repo = ref.read(premiumRepositoryProvider);
    return repo.getSubscriptionStatus();
  }

  Future<String?> createCheckout({
    required String successUrl,
    required String cancelUrl,
  }) async {
    final repo = ref.read(premiumRepositoryProvider);
    final url = await repo.createCheckoutSession(
      successUrl: successUrl,
      cancelUrl: cancelUrl,
    );
    if (url != null) {
      ref.invalidateSelf();
    }
    return url;
  }

  Future<bool> cancel() async {
    final repo = ref.read(premiumRepositoryProvider);
    final success = await repo.cancelSubscription();
    if (success) {
      ref.invalidateSelf();
    }
    return success;
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}
