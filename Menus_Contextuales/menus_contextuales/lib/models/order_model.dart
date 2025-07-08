import 'cart_item_model.dart';

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  ready,
  delivered,
  cancelled
}

class OrderModel {
  final String id;
  final String userId;
  final String userEmail;
  final List<CartItemModel> items;
  final double totalAmount;
  final OrderStatus status;
  final String? notes;
  final String? deliveryAddress;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deliveredAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.items,
    required this.totalAmount,
    required this.status,
    this.notes,
    this.deliveryAddress,
    required this.createdAt,
    this.updatedAt,
    this.deliveredAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userEmail: json['userEmail'] ?? '',
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => CartItemModel.fromJson(item))
          .toList() ?? [],
      totalAmount: (json['totalAmount'] ?? 0.0).toDouble(),
      status: OrderStatus.values.firstWhere(
        (e) => e.toString().split('.').last == (json['status'] ?? 'pending'),
        orElse: () => OrderStatus.pending,
      ),
      notes: json['notes'],
      deliveryAddress: json['deliveryAddress'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      deliveredAt: json['deliveredAt'] != null ? DateTime.parse(json['deliveredAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userEmail': userEmail,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'status': status.toString().split('.').last,
      'notes': notes,
      'deliveryAddress': deliveryAddress,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
    };
  }

  OrderModel copyWith({
    String? id,
    String? userId,
    String? userEmail,
    List<CartItemModel>? items,
    double? totalAmount,
    OrderStatus? status,
    String? notes,
    String? deliveryAddress,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deliveredAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
    );
  }

  String get statusText {
    switch (status) {
      case OrderStatus.pending:
        return 'Pendiente';
      case OrderStatus.confirmed:
        return 'Confirmado';
      case OrderStatus.preparing:
        return 'Preparando';
      case OrderStatus.ready:
        return 'Listo';
      case OrderStatus.delivered:
        return 'Entregado';
      case OrderStatus.cancelled:
        return 'Cancelado';
    }
  }

  // Propiedades calculadas para facilitar el acceso
  String get orderNumber {
    if (id.isEmpty) return 'ORD-PENDING';
    if (id.length < 8) return 'ORD-${id.toUpperCase()}';
    return 'ORD-${id.substring(0, 8).toUpperCase()}';
  }
  String get userName => 'Usuario'; // Podría obtenerse del usuario
  String get userPhone => '+593 99 999 9999'; // Podría obtenerse del usuario
  String get userAddress => deliveryAddress ?? 'Dirección no especificada';
}
