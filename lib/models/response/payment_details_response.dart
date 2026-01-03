import '../entities/payment.dart';
import '../entities/weighing_slip.dart';

class PaymentDetailsResponse {
  final bool success;
  final PaymentDetailsData? data;
  final String? error;

  PaymentDetailsResponse({
    required this.success,
    this.data,
    this.error,
  });

  factory PaymentDetailsResponse.fromJson(Map<String, dynamic> json) {
    return PaymentDetailsResponse(
      success: json['success'] as bool? ?? true,
      data: json['data'] != null ? PaymentDetailsData.fromJson(json['data']) : null,
      error: json['error'] as String?,
    );
  }
}

class PaymentDetailsData {
  final SlipDetail slip;
  final List<PaymentDetail> payments;

  PaymentDetailsData({
    required this.slip,
    required this.payments,
  });

  factory PaymentDetailsData.fromJson(Map<String, dynamic> json) {
    return PaymentDetailsData(
      slip: SlipDetail.fromJson(json['slip'] as Map<String, dynamic>),
      payments: (json['payments'] as List<dynamic>?)
              ?.map((p) => PaymentDetail.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class SlipDetail {
  final int id;
  final String? slipNumber;
  final ClientDetail client;
  final MaterialDetail material;
  final double weightTons;
  final double pricePerTon;
  final double totalAmount;
  final int createdBy;
  final DateTime createdAt;
  final CreditInfo creditInfo;

  SlipDetail({
    required this.id,
    this.slipNumber,
    required this.client,
    required this.material,
    required this.weightTons,
    required this.pricePerTon,
    required this.totalAmount,
    required this.createdBy,
    required this.createdAt,
    required this.creditInfo,
  });

  factory SlipDetail.fromJson(Map<String, dynamic> json) {
    return SlipDetail(
      id: json['id'] as int,
      slipNumber: json['slip_number'] as String?,
      client: ClientDetail.fromJson(json['client'] as Map<String, dynamic>),
      material: MaterialDetail.fromJson(json['material'] as Map<String, dynamic>),
      weightTons: (json['weight_tons'] as num).toDouble(),
      pricePerTon: (json['price_per_ton'] as num).toDouble(),
      totalAmount: (json['total_amount'] as num).toDouble(),
      createdBy: json['created_by'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      creditInfo: CreditInfo.fromJson(json['credit_info'] as Map<String, dynamic>),
    );
  }
}

class ClientDetail {
  final int id;
  final String name;
  final String type;

  ClientDetail({
    required this.id,
    required this.name,
    required this.type,
  });

  factory ClientDetail.fromJson(Map<String, dynamic> json) {
    return ClientDetail(
      id: json['id'] as int,
      name: json['name'] as String,
      type: json['type'] as String,
    );
  }
}

class MaterialDetail {
  final int id;
  final String name;

  MaterialDetail({
    required this.id,
    required this.name,
  });

  factory MaterialDetail.fromJson(Map<String, dynamic> json) {
    return MaterialDetail(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}

class CreditInfo {
  final double totalPaid;
  final double remainingCredit;
  final bool isFullyPaid;
  final double totalSlipAmount;

  CreditInfo({
    required this.totalPaid,
    required this.remainingCredit,
    required this.isFullyPaid,
    required this.totalSlipAmount,
  });

  factory CreditInfo.fromJson(Map<String, dynamic> json) {
    return CreditInfo(
      totalPaid: (json['total_paid'] as num).toDouble(),
      remainingCredit: (json['remaining_credit'] as num).toDouble(),
      isFullyPaid: json['is_fully_paid'] as bool,
      totalSlipAmount: (json['total_slip_amount'] as num).toDouble(),
    );
  }
}

class PaymentDetail {
  final int id;
  final String paymentType;
  final double amountPaid;
  final String paymentDate;
  final String? checkNumber;
  final String? checkDate;
  final String? checkBank;
  final String? checkStatus;
  final String? notes;
  final int createdBy;
  final String? createdByUsername;
  final DateTime createdAt;

  PaymentDetail({
    required this.id,
    required this.paymentType,
    required this.amountPaid,
    required this.paymentDate,
    this.checkNumber,
    this.checkDate,
    this.checkBank,
    this.checkStatus,
    this.notes,
    required this.createdBy,
    this.createdByUsername,
    required this.createdAt,
  });

  factory PaymentDetail.fromJson(Map<String, dynamic> json) {
    return PaymentDetail(
      id: json['id'] as int,
      paymentType: json['payment_type'] as String,
      amountPaid: (json['amount_paid'] as num).toDouble(),
      paymentDate: json['payment_date'] as String,
      checkNumber: json['check_number'] as String?,
      checkDate: json['check_date'] as String?,
      checkBank: json['check_bank'] as String?,
      checkStatus: json['check_status'] as String?,
      notes: json['notes'] as String?,
      createdBy: json['created_by'] as int,
      createdByUsername: json['created_by_username'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
