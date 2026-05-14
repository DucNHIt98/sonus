class SubscriptionStatus {
  final bool isPremium;
  final DateTime? premiumUntil;
  final String? status;
  final bool cancelAtPeriodEnd;

  SubscriptionStatus({
    required this.isPremium,
    this.premiumUntil,
    this.status,
    this.cancelAtPeriodEnd = false,
  });

  factory SubscriptionStatus.fromJson(Map<String, dynamic> json) {
    return SubscriptionStatus(
      isPremium: json['is_premium'] as bool? ?? false,
      premiumUntil: json['premium_until'] != null
          ? DateTime.tryParse(json['premium_until'] as String)
          : null,
      status: json['status'] as String?,
      cancelAtPeriodEnd: json['cancel_at_period_end'] as bool? ?? false,
    );
  }

  factory SubscriptionStatus.notPremium() {
    return SubscriptionStatus(isPremium: false);
  }
}
