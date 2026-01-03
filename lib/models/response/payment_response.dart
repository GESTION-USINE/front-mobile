import '../entities/payment.dart';

class PaymentResponse {
  final bool success;
  final Payment? payment;
  final String? error;
  final Map<String, dynamic>? details;

  PaymentResponse({
    required this.success,
    this.payment,
    this.error,
    this.details,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    // API returns status code (201 = success, 4xx/5xx = error)
    final int status = json['status'] as int? ?? 200;
    final bool isSuccess = status >= 200 && status < 300;
    
    return PaymentResponse(
      success: isSuccess,
      payment: json['data'] != null && json['data'] is Map ? Payment.fromJson(json['data'] as Map<String, dynamic>) : null,
      error: json['error'] as String? ?? json['message'] as String?,
      details: json['details'] as Map<String, dynamic>?,
    );
  }
}
