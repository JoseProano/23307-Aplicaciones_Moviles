class InvoiceModel {
  final String id;
  final String orderId;
  final String userId;
  final String userEmail;
  final String invoiceNumber;
  final DateTime createdAt;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final String customerCity;
  
  // Datos de identificación Ecuador
  final String cedula; // Cédula o RUC del cliente
  final String? businessName; // Razón social (opcional para empresas)
  final String? businessAddress; // Dirección fiscal (opcional)
  
  // Datos financieros Ecuador (IVA 15%)
  final double subtotal;
  final double ivaPercentage; // Por defecto 15%
  final double ivaAmount;
  final double totalAmount;
  
  // Items de la factura
  final List<InvoiceItemModel> items;
  
  // Estado de la factura
  final InvoiceStatus status;
  final DateTime? paidAt;

  InvoiceModel({
    required this.id,
    required this.orderId,
    required this.userId,
    required this.userEmail,
    required this.invoiceNumber,
    required this.createdAt,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.customerCity,
    required this.cedula,
    this.businessName,
    this.businessAddress,
    required this.subtotal,
    this.ivaPercentage = 15.0, // IVA Ecuador 15%
    required this.ivaAmount,
    required this.totalAmount,
    required this.items,
    this.status = InvoiceStatus.pending,
    this.paidAt,
  });

  factory InvoiceModel.fromMap(Map<String, dynamic> map, String id) {
    return InvoiceModel(
      id: id,
      orderId: map['orderId'] ?? '',
      userId: map['userId'] ?? '',
      userEmail: map['userEmail'] ?? '',
      invoiceNumber: map['invoiceNumber'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      customerName: map['customerName'] ?? '',
      customerPhone: map['customerPhone'] ?? '',
      customerAddress: map['customerAddress'] ?? '',
      customerCity: map['customerCity'] ?? '',
      cedula: map['cedula'] ?? '',
      businessName: map['businessName'],
      businessAddress: map['businessAddress'],
      subtotal: (map['subtotal'] ?? 0.0).toDouble(),
      ivaPercentage: (map['ivaPercentage'] ?? 15.0).toDouble(),
      ivaAmount: (map['ivaAmount'] ?? 0.0).toDouble(),
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
      items: (map['items'] as List<dynamic>?)
          ?.map((item) => InvoiceItemModel.fromMap(item))
          .toList() ?? [],
      status: InvoiceStatus.values.firstWhere(
        (e) => e.toString() == 'InvoiceStatus.${map['status']}',
        orElse: () => InvoiceStatus.pending,
      ),
      paidAt: map['paidAt'] != null ? DateTime.parse(map['paidAt']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'userId': userId,
      'userEmail': userEmail,
      'invoiceNumber': invoiceNumber,
      'createdAt': createdAt.toIso8601String(),
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerAddress': customerAddress,
      'customerCity': customerCity,
      'cedula': cedula,
      'businessName': businessName,
      'businessAddress': businessAddress,
      'subtotal': subtotal,
      'ivaPercentage': ivaPercentage,
      'ivaAmount': ivaAmount,
      'totalAmount': totalAmount,
      'items': items.map((item) => item.toMap()).toList(),
      'status': status.toString().split('.').last,
      'paidAt': paidAt?.toIso8601String(),
    };
  }

  InvoiceModel copyWith({
    String? id,
    String? orderId,
    String? userId,
    String? userEmail,
    String? invoiceNumber,
    DateTime? createdAt,
    String? customerName,
    String? customerPhone,
    String? customerAddress,
    String? customerCity,
    String? cedula,
    String? businessName,
    String? businessAddress,
    double? subtotal,
    double? ivaPercentage,
    double? ivaAmount,
    double? totalAmount,
    List<InvoiceItemModel>? items,
    InvoiceStatus? status,
    DateTime? paidAt,
  }) {
    return InvoiceModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      createdAt: createdAt ?? this.createdAt,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerAddress: customerAddress ?? this.customerAddress,
      customerCity: customerCity ?? this.customerCity,
      cedula: cedula ?? this.cedula,
      businessName: businessName ?? this.businessName,
      businessAddress: businessAddress ?? this.businessAddress,
      subtotal: subtotal ?? this.subtotal,
      ivaPercentage: ivaPercentage ?? this.ivaPercentage,
      ivaAmount: ivaAmount ?? this.ivaAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      items: items ?? this.items,
      status: status ?? this.status,
      paidAt: paidAt ?? this.paidAt,
    );
  }

  // Getters de conveniencia
  bool get isPaid => status == InvoiceStatus.paid;
  bool get isPending => status == InvoiceStatus.pending;
  bool get isCancelled => status == InvoiceStatus.cancelled;
  
  String get statusDisplayName {
    switch (status) {
      case InvoiceStatus.pending:
        return 'Pendiente';
      case InvoiceStatus.paid:
        return 'Pagada';
      case InvoiceStatus.cancelled:
        return 'Cancelada';
    }
  }
}

class InvoiceItemModel {
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  InvoiceItemModel({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory InvoiceItemModel.fromMap(Map<String, dynamic> map) {
    return InvoiceItemModel(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      quantity: map['quantity'] ?? 0,
      unitPrice: (map['unitPrice'] ?? 0.0).toDouble(),
      totalPrice: (map['totalPrice'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
    };
  }
}

enum InvoiceStatus {
  pending,
  paid,
  cancelled,
}
