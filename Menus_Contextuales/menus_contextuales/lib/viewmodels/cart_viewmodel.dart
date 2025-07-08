import 'package:flutter/foundation.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CartViewModel extends ChangeNotifier {
  List<CartItemModel> _cartItems = [];
  bool _isLoading = false;

  // Getters
  List<CartItemModel> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  
  int get itemCount => _cartItems.length;
  
  int get totalQuantity => _cartItems.fold(0, (sum, item) => sum + item.quantity);
  
  double get totalAmount => _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);

  bool get isEmpty => _cartItems.isEmpty;

  // Inicializar carrito (cargar desde SharedPreferences)
  Future<void> initialize() async {
    await _loadCartFromStorage();
  }

  // Agregar producto al carrito
  Future<void> addToCart(ProductModel product, {int quantity = 1}) async {
    try {
      // Verificar si el producto ya está en el carrito
      int existingIndex = _cartItems.indexWhere((item) => item.product.id == product.id);
      
      if (existingIndex != -1) {
        // Si ya existe, actualizar la cantidad
        CartItemModel existingItem = _cartItems[existingIndex];
        _cartItems[existingIndex] = existingItem.copyWith(
          quantity: existingItem.quantity + quantity,
        );
      } else {
        // Si no existe, agregar nuevo item
        CartItemModel newItem = CartItemModel(
          id: '${product.id}_${DateTime.now().millisecondsSinceEpoch}',
          product: product,
          quantity: quantity,
          addedAt: DateTime.now(),
        );
        _cartItems.add(newItem);
      }
      
      await _saveCartToStorage();
      notifyListeners();
    } catch (e) {
      print('Error al agregar al carrito: $e');
    }
  }

  // Remover producto del carrito
  Future<void> removeFromCart(String cartItemId) async {
    try {
      _cartItems.removeWhere((item) => item.id == cartItemId);
      await _saveCartToStorage();
      notifyListeners();
    } catch (e) {
      print('Error al remover del carrito: $e');
    }
  }

  // Actualizar cantidad de un item
  Future<void> updateQuantity(String cartItemId, int newQuantity) async {
    try {
      if (newQuantity <= 0) {
        await removeFromCart(cartItemId);
        return;
      }

      int index = _cartItems.indexWhere((item) => item.id == cartItemId);
      if (index != -1) {
        _cartItems[index] = _cartItems[index].copyWith(quantity: newQuantity);
        await _saveCartToStorage();
        notifyListeners();
      }
    } catch (e) {
      print('Error al actualizar cantidad: $e');
    }
  }

  // Incrementar cantidad de un item
  Future<void> incrementQuantity(String cartItemId) async {
    CartItemModel? item = getCartItem(cartItemId);
    if (item != null) {
      await updateQuantity(cartItemId, item.quantity + 1);
    }
  }

  // Decrementar cantidad de un item
  Future<void> decrementQuantity(String cartItemId) async {
    CartItemModel? item = getCartItem(cartItemId);
    if (item != null) {
      await updateQuantity(cartItemId, item.quantity - 1);
    }
  }

  // Obtener item del carrito por ID
  CartItemModel? getCartItem(String cartItemId) {
    try {
      return _cartItems.firstWhere((item) => item.id == cartItemId);
    } catch (e) {
      return null;
    }
  }

  // Verificar si un producto está en el carrito
  bool isProductInCart(String productId) {
    return _cartItems.any((item) => item.product.id == productId);
  }

  // Obtener cantidad de un producto en el carrito
  int getProductQuantity(String productId) {
    try {
      CartItemModel item = _cartItems.firstWhere((item) => item.product.id == productId);
      return item.quantity;
    } catch (e) {
      return 0;
    }
  }

  // Limpiar carrito
  Future<void> clearCart() async {
    try {
      _cartItems.clear();
      await _saveCartToStorage();
      notifyListeners();
    } catch (e) {
      print('Error al limpiar carrito: $e');
    }
  }

  // Obtener resumen del carrito
  Map<String, dynamic> getCartSummary() {
    return {
      'itemCount': itemCount,
      'totalQuantity': totalQuantity,
      'totalAmount': totalAmount,
      'items': _cartItems.map((item) => {
        'productName': item.product.name,
        'quantity': item.quantity,
        'unitPrice': item.product.price,
        'totalPrice': item.totalPrice,
      }).toList(),
    };
  }

  // Aplicar descuento
  double calculateDiscountedTotal(double discountPercentage) {
    return totalAmount * (1 - discountPercentage / 100);
  }

  // Cargar carrito desde SharedPreferences
  Future<void> _loadCartFromStorage() async {
    try {
      _isLoading = true;
      notifyListeners();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? cartData = prefs.getString('cart_items');
      
      if (cartData != null) {
        List<dynamic> cartJson = json.decode(cartData);
        _cartItems = cartJson.map((item) => CartItemModel.fromJson(item)).toList();
      }
    } catch (e) {
      print('Error al cargar carrito: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Guardar carrito en SharedPreferences
  Future<void> _saveCartToStorage() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String cartData = json.encode(_cartItems.map((item) => item.toJson()).toList());
      await prefs.setString('cart_items', cartData);
    } catch (e) {
      print('Error al guardar carrito: $e');
    }
  }

  // Validar stock antes de proceder al checkout
  bool validateStock() {
    for (CartItemModel item in _cartItems) {
      if (item.quantity > item.product.stock) {
        return false;
      }
    }
    return true;
  }

  // Obtener items con stock insuficiente
  List<CartItemModel> getItemsWithInsufficientStock() {
    return _cartItems.where((item) => item.quantity > item.product.stock).toList();
  }
}
