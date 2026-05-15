/// Response from POST /api/Payments/create-checkout-session.
class CheckoutSessionResponse {
  final String paymentUrl;
  final String? sessionId;

  const CheckoutSessionResponse({
    required this.paymentUrl,
    this.sessionId,
  });

  factory CheckoutSessionResponse.fromJson(Map<String, dynamic> json) {
    return CheckoutSessionResponse(
      paymentUrl: json['paymentUrl'] as String? ?? '',
      sessionId: json['sessionId'] as String?,
    );
  }
}
