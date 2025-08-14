import 'package:flutter/material.dart';
import '../utils/date_utils.dart' as AppDateUtils;

class OrderHistory {
  final String id;
  final String licensePlate;
  final double value;
  final DateTime createdAt;
  final String status;
  final String? description;
  final String? paymentMethod;

  OrderHistory({
    required this.id,
    required this.licensePlate,
    required this.value,
    required this.createdAt,
    required this.status,
    this.description,
    this.paymentMethod,
  });

  factory OrderHistory.fromJson(Map<String, dynamic> json) {
    try {
      return OrderHistory(
        id: json['id']?.toString() ?? '',
        licensePlate: json['licensePlate']?.toString() ?? '',
        value: (json['value'] ?? json['valueTotal'] ?? 0.0).toDouble(),
        createdAt: AppDateUtils.DateUtils.parseUtcDate(json['createdAt'] ?? json['created_at']),
        status: json['status']?.toString() ?? '',
        description: json['description']?.toString(),
        paymentMethod: json['paymentMethod']?.toString() ?? json['payment_method']?.toString(),
      );
    } catch (e) {
      throw Exception('Erro ao fazer parse de OrderHistory: $e. JSON: $json');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'licensePlate': licensePlate,
      'value': value,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
      'description': description,
      'paymentMethod': paymentMethod,
    };
  }
}

class ActivationHistory {
  final String id;
  final String licensePlate;
  final int parkingTime;
  final DateTime activatedAt;
  final DateTime? expiresAt;
  final String status;
  final String? location;

  ActivationHistory({
    required this.id,
    required this.licensePlate,
    required this.parkingTime,
    required this.activatedAt,
    this.expiresAt,
    required this.status,
    this.location,
  });

  /// Calcula a quantidade de créditos baseado no tempo de estacionamento
  /// Baseado nas regras da cidade (1h = 4 créditos, 2h = 7 créditos, 3h = 10 créditos)
  int get quantity {
    switch (parkingTime) {
      case 60: // 1 hora
        return 4;
      case 120: // 2 horas
        return 7;
      case 180: // 3 horas
        return 10;
      default:
        // Para outros tempos, calcula proporcionalmente (1 crédito = 15 minutos)
        return (parkingTime / 15).ceil();
    }
  }

  /// Verifica se o estacionamento ainda está ativo (dentro do tempo)
  bool get isActive {
    if (expiresAt != null) {
      return DateTime.now().isBefore(expiresAt!);
    }
    // Se não tem expiresAt, calcula baseado no parkingTime
    final expirationTime = activatedAt.add(Duration(minutes: parkingTime));
    return DateTime.now().isBefore(expirationTime);
  }

  /// Retorna o tempo restante em minutos (0 se expirado)
  int get remainingMinutes {
    if (expiresAt != null) {
      final remaining = expiresAt!.difference(DateTime.now()).inMinutes;
      return remaining > 0 ? remaining : 0;
    }
    // Se não tem expiresAt, calcula baseado no parkingTime
    final expirationTime = activatedAt.add(Duration(minutes: parkingTime));
    final remaining = expirationTime.difference(DateTime.now()).inMinutes;
    return remaining > 0 ? remaining : 0;
  }

  /// Retorna o status visual do estacionamento
  String get displayStatus {
    if (isActive) {
      if (remainingMinutes <= 15) {
        return 'Expirando em ${remainingMinutes}min';
      } else if (remainingMinutes <= 30) {
        return 'Expira em ${remainingMinutes}min';
      } else {
        return 'Ativo';
      }
    } else {
      return 'Expirado';
    }
  }

  /// Retorna a cor do status
  Color get statusColor {
    if (isActive) {
      if (remainingMinutes <= 15) {
        return Colors.red;
      } else if (remainingMinutes <= 30) {
        return Colors.orange;
      } else {
        return Colors.green;
      }
    } else {
      return Colors.grey;
    }
  }

  factory ActivationHistory.fromJson(Map<String, dynamic> json) {
    try {
      return ActivationHistory(
        id: json['id']?.toString() ?? '',
        licensePlate: json['licensePlate']?.toString() ?? '',
        parkingTime: json['parkingTime'] ?? 0,
        activatedAt: AppDateUtils.DateUtils.parseUtcDate(json['activatedAt'] ?? json['activated_at']),
        expiresAt: json['expiresAt'] != null ? AppDateUtils.DateUtils.parseUtcDate(json['expiresAt']) : 
                  json['expires_at'] != null ? AppDateUtils.DateUtils.parseUtcDate(json['expires_at']) : null,
        status: json['status']?.toString() ?? 'active', // Default para 'active' se não existir
        location: json['location']?.toString(),
      );
    } catch (e) {
      throw Exception('Erro ao fazer parse de ActivationHistory: $e. JSON: $json');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'licensePlate': licensePlate,
      'parkingTime': parkingTime,
      'activatedAt': activatedAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'status': status,
      'location': location,
    };
  }
}

class HistoryFilter {
  final String? licensePlate;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? status;

  HistoryFilter({
    this.licensePlate,
    this.startDate,
    this.endDate,
    this.status,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    
    if (licensePlate != null && licensePlate!.isNotEmpty) {
      map['licensePlate'] = licensePlate;
    }
    if (startDate != null) {
      map['startDate'] = startDate!.toIso8601String();
    }
    if (endDate != null) {
      map['endDate'] = endDate!.toIso8601String();
    }
    if (status != null && status!.isNotEmpty) {
      map['status'] = status;
    }
    
    return map;
  }
}

class HistoryState {
  final List<OrderHistory> orders;
  final List<ActivationHistory> activations;
  final bool isLoadingOrders;
  final bool isLoadingActivations;
  final String? error;
  final int currentPage;
  final bool hasMoreData;

  HistoryState({
    this.orders = const [],
    this.activations = const [],
    this.isLoadingOrders = false,
    this.isLoadingActivations = false,
    this.error,
    this.currentPage = 0,
    this.hasMoreData = true,
  });

  HistoryState copyWith({
    List<OrderHistory>? orders,
    List<ActivationHistory>? activations,
    bool? isLoadingOrders,
    bool? isLoadingActivations,
    String? error,
    int? currentPage,
    bool? hasMoreData,
    bool clearError = false,
  }) {
    return HistoryState(
      orders: orders ?? this.orders,
      activations: activations ?? this.activations,
      isLoadingOrders: isLoadingOrders ?? this.isLoadingOrders,
      isLoadingActivations: isLoadingActivations ?? this.isLoadingActivations,
      error: clearError ? null : (error ?? this.error),
      currentPage: currentPage ?? this.currentPage,
      hasMoreData: hasMoreData ?? this.hasMoreData,
    );
  }
}

// Detailed models for order details
class OrderPaymentPix {
  final String text;
  final String url;

  OrderPaymentPix({
    required this.text,
    required this.url,
  });

  factory OrderPaymentPix.fromJson(Map<String, dynamic> json) {
    return OrderPaymentPix(
      text: json['text']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
    );
  }
}

class OrderPaymentBillet {
  final String url;
  final String expirationDate;
  final String lineCode;

  OrderPaymentBillet({
    required this.url,
    required this.expirationDate,
    required this.lineCode,
  });

  factory OrderPaymentBillet.fromJson(Map<String, dynamic> json) {
    return OrderPaymentBillet(
      url: json['url']?.toString() ?? '',
      expirationDate: json['expirationDate']?.toString() ?? '',
      lineCode: json['lineCode']?.toString() ?? '',
    );
  }
}

class OrderPaymentCreditCard {
  final String number;
  final String? holderName;

  OrderPaymentCreditCard({
    required this.number,
    this.holderName,
  });

  factory OrderPaymentCreditCard.fromJson(Map<String, dynamic> json) {
    final holder = json['holder'];
    return OrderPaymentCreditCard(
      number: json['number']?.toString() ?? '',
      holderName: holder != null ? holder['name']?.toString() : null,
    );
  }
}

class OrderPayment {
  final String id;
  final String status;
  final String gateway;
  final String method;
  final OrderPaymentPix? pix;
  final OrderPaymentBillet? billet;
  final OrderPaymentCreditCard? creditCard;

  OrderPayment({
    required this.id,
    required this.status,
    required this.gateway,
    required this.method,
    this.pix,
    this.billet,
    this.creditCard,
  });

  factory OrderPayment.fromJson(Map<String, dynamic> json) {
    return OrderPayment(
      id: json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      gateway: json['gateway']?.toString() ?? '',
      method: json['method']?.toString() ?? 'Dinheiro',
      pix: json['pix'] != null ? OrderPaymentPix.fromJson(json['pix']) : null,
      billet: json['billet'] != null ? OrderPaymentBillet.fromJson(json['billet']) : null,
      creditCard: json['creditCard'] != null ? OrderPaymentCreditCard.fromJson(json['creditCard']) : null,
    );
  }
}

class OrderProduct {
  final int? vehicleType;

  OrderProduct({
    this.vehicleType,
  });

  factory OrderProduct.fromJson(Map<String, dynamic> json) {
    return OrderProduct(
      vehicleType: json['vehicleType']?.toInt(),
    );
  }
}

class OrderChargeback {
  final String message;
  final OrderChargebackAction action;
  final OrderChargebackLast? last;

  OrderChargeback({
    required this.message,
    required this.action,
    this.last,
  });

  factory OrderChargeback.fromJson(Map<String, dynamic> json) {
    return OrderChargeback(
      message: json['message']?.toString() ?? '',
      action: OrderChargebackAction.fromJson(json['action'] ?? {}),
      last: json['last'] != null ? OrderChargebackLast.fromJson(json['last']) : null,
    );
  }
}

class OrderChargebackAction {
  final double value;
  final int quantity;

  OrderChargebackAction({
    required this.value,
    required this.quantity,
  });

  factory OrderChargebackAction.fromJson(Map<String, dynamic> json) {
    return OrderChargebackAction(
      value: (json['value'] ?? 0).toDouble(),
      quantity: (json['quantity'] ?? 0).toInt(),
    );
  }
}

class OrderChargebackLast {
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double value;

  OrderChargebackLast({
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.value,
  });

  factory OrderChargebackLast.fromJson(Map<String, dynamic> json) {
    return OrderChargebackLast(
      status: json['status']?.toString() ?? '',
      createdAt: AppDateUtils.DateUtils.parseUtcDate(json['createdAt']?.toString()),
      updatedAt: AppDateUtils.DateUtils.parseUtcDate(json['updatedAt']?.toString()),
      value: (json['value'] ?? 0).toDouble(),
    );
  }
}

class OrderDetail {
  final String id;
  final DateTime createdAt;
  final String status;
  final String? action;
  final double value;
  final String gateway;
  final List<OrderProduct> products;
  final List<OrderPayment> payments;
  final OrderChargeback? chargeback;
  final String? referenceCode;

  OrderDetail({
    required this.id,
    required this.createdAt,
    required this.status,
    this.action,
    required this.value,
    required this.gateway,
    required this.products,
    required this.payments,
    this.chargeback,
    this.referenceCode,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    try {
      return OrderDetail(
        id: json['id']?.toString() ?? '',
        createdAt: AppDateUtils.DateUtils.parseUtcDate(json['createdAt']?.toString()),
        status: json['status']?.toString() ?? 'Desconhecido',
        action: json['action']?.toString(),
        value: (json['value'] ?? 0).toDouble(),
        gateway: json['gateway']?.toString() ?? '',
        products: (json['products'] as List<dynamic>?)
            ?.map((p) => OrderProduct.fromJson(p as Map<String, dynamic>))
            .toList() ?? [],
        payments: (json['payments'] as List<dynamic>?)
            ?.map((p) => OrderPayment.fromJson(p as Map<String, dynamic>))
            .toList() ?? [],
        chargeback: json['chargeback'] != null ? OrderChargeback.fromJson(json['chargeback']) : null,
        referenceCode: json['referenceCode']?.toString(),
      );
    } catch (e) {
      throw Exception('Erro ao fazer parse de OrderDetail: $e. JSON: $json');
    }
  }
}