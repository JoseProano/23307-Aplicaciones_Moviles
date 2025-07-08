import 'product_model.dart';

class CartItemModel {
  final String id;
  final ProductModel product;
  final int quantity;
  final DateTime addedAt;

  CartItemModel({
    required this.id,
    required this.product,
    required this.quantity,
    required this.addedAt,
  });

  // Propiedades calculadas para facilitar el acceso
  String get productName => product.name;
  double get price => product.price;

  double get totalPrice => product.price * quantity;

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] ?? '',
      product: ProductModel.fromJson(json['product']),
      quantity: json['quantity'] ?? 1,
      addedAt: DateTime.parse(json['addedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product.toJson(),
      'quantity': quantity,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  CartItemModel copyWith({
    String? id,
    ProductModel? product,
    int? quantity,
    DateTime? addedAt,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}
