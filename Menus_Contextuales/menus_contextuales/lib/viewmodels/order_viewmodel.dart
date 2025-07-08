import 'package:flutter/foundation.dart';
import '../models/order_model.dart';
import '../models/cart_item_model.dart';
import '../models/invoice_model.dart';
import '../repositories/order_repository.dart';
import '../repositories/invoice_repository.dart';

enum OrderState {
  initial,
  loading,
  loaded,
  error,
}

class OrderViewModel extends ChangeNotifier {
  final OrderRepository _orderRepository;
  final InvoiceRepository _invoiceRepository;

  OrderViewModel({
    OrderRepository? orderRepository,
    InvoiceRepository? invoiceRepository,
  })  : _orderRepository = orderRepository ?? OrderRepository(),
        _invoiceRepository = invoiceRepository ?? InvoiceRepository();

  // Estado
  OrderState _state = OrderState.initial;
  List<OrderModel> _orders = [];
  List<OrderModel> _pendingOrders = [];
  List<OrderModel> _completedOrders = [];
  String _errorMessage = '';
  bool _isLoading = false;
  bool _isCreatingOrder = false;

  // Getters
  OrderState get state => _state;
  List<OrderModel> get orders => _orders;
  List<OrderModel> get pendingOrders => _pendingOrders;
  List<OrderModel> get completedOrders => _completedOrders;
  String get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isCreatingOrder => _isCreatingOrder;

  // Crear nueva orden
  Future<bool> createOrder({
    required String userId,
    required String userEmail,
    required List<CartItemModel> cartItems,
    String? notes,
    String? deliveryAddress,
  }) async {
    _setCreatingOrder(true);
    try {
      String? orderId = await _orderRepository.createOrder(
        userId: userId,
        userEmail: userEmail,
        items: cartItems,
        notes: notes,
        deliveryAddress: deliveryAddress,
      );

      if (orderId != null) {
        // Recargar órdenes después de crear una nueva
        await loadUserOrders(userId);
        _setCreatingOrder(false);
        return true;
      } else {
        _setError('Error al crear la orden');
        return false;
      }
    } catch (e) {
      _setError('Error al crear la orden: $e');
      return false;
    }
  }

  // Crear nueva orden con factura
  Future<bool> createOrderWithInvoice({
    required String userId,
    required String userEmail,
    required List<CartItemModel> cartItems,
    required String deliveryAddress,
    required Map<String, String> customerInfo,
    Map<String, String>? invoiceInfo,
    required double ivaPercentage,
    required double subtotal,
    required double ivaAmount,
    required double totalAmount,
  }) async {
    _setCreatingOrder(true);
    try {
      // Crear la orden primero
      String? orderId = await _orderRepository.createOrder(
        userId: userId,
        userEmail: userEmail,
        items: cartItems,
        notes: customerInfo['notes'],
        deliveryAddress: deliveryAddress,
      );

      if (orderId != null) {
        // Si se requiere factura, crearla
        if (invoiceInfo != null) {
          await _createInvoiceForOrder(
            orderId: orderId,
            userId: userId,
            userEmail: userEmail,
            customerInfo: customerInfo,
            invoiceInfo: invoiceInfo,
            cartItems: cartItems,
            ivaPercentage: ivaPercentage,
            subtotal: subtotal,
            ivaAmount: ivaAmount,
            totalAmount: totalAmount,
          );
        }

        // Recargar órdenes después de crear una nueva
        await loadUserOrders(userId);
        _setCreatingOrder(false);
        return true;
      } else {
        _setError('Error al crear la orden');
        return false;
      }
    } catch (e) {
      _setError('Error al crear la orden con factura: $e');
      return false;
    }
  }

  // Crear factura para una orden
  Future<String?> _createInvoiceForOrder({
    required String orderId,
    required String userId,
    required String userEmail,
    required Map<String, String> customerInfo,
    required Map<String, String> invoiceInfo,
    required List<CartItemModel> cartItems,
    required double ivaPercentage,
    required double subtotal,
    required double ivaAmount,
    required double totalAmount,
  }) async {
    try {
      // Generar número de factura
      String invoiceNumber = await _invoiceRepository.generateInvoiceNumber();

      // Convertir items del carrito a items de factura
      List<InvoiceItemModel> invoiceItems = cartItems.map((cartItem) {
        return InvoiceItemModel(
          productId: cartItem.product.id,
          productName: cartItem.product.name,
          quantity: cartItem.quantity,
          unitPrice: cartItem.product.price,
          totalPrice: cartItem.product.price * cartItem.quantity,
        );
      }).toList();

      // Crear la factura
      InvoiceModel invoice = InvoiceModel(
        id: '',
        orderId: orderId,
        userId: userId,
        userEmail: userEmail,
        invoiceNumber: invoiceNumber,
        createdAt: DateTime.now(),
        customerName: customerInfo['name'] ?? '',
        customerPhone: customerInfo['phone'] ?? '',
        customerAddress: customerInfo['address'] ?? '',
        customerCity: customerInfo['city'] ?? '',
        cedula: invoiceInfo['cedula'] ?? '',
        businessName: invoiceInfo['businessName'] ?? '',
        businessAddress: invoiceInfo['businessAddress'] ?? '',
        subtotal: subtotal,
        ivaPercentage: ivaPercentage,
        ivaAmount: ivaAmount,
        totalAmount: totalAmount,
        items: invoiceItems,
        status: InvoiceStatus.pending,
      );

      return await _invoiceRepository.createInvoice(invoice);
    } catch (e) {
      print('Error creando factura: $e');
      return null;
    }
  }

  // Cargar órdenes del usuario
  Future<void> loadUserOrders(String userId) async {
    _setLoading(true);
    try {
      _orders = await _orderRepository.getUserOrders(userId);
      _updateOrdersByStatus();
      _state = OrderState.loaded;
      _errorMessage = '';
    } catch (e) {
      String errorMessage = 'Error al cargar órdenes: $e';
      
      // Manejar error específico del índice
      if (e.toString().contains('index') || e.toString().contains('requires an index')) {
        errorMessage = 'Los índices de Firestore están pendientes. Por favor, contacta al administrador.';
        print('❌ Error de índice Firestore detectado. Consulta docs/INDICES_FIRESTORE.md para crear los índices.');
      }
      
      _setError(errorMessage);
    } finally {
      _setLoading(false);
    }
  }

  // Cargar órdenes pendientes
  Future<void> loadPendingOrders(String userId) async {
    _setLoading(true);
    try {
      _pendingOrders = await _orderRepository.getPendingOrders(userId);
      _state = OrderState.loaded;
      _errorMessage = '';
    } catch (e) {
      _setError('Error al cargar órdenes pendientes: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Cargar órdenes completadas
  Future<void> loadCompletedOrders(String userId) async {
    _setLoading(true);
    try {
      _completedOrders = await _orderRepository.getCompletedOrders(userId);
      _state = OrderState.loaded;
      _errorMessage = '';
    } catch (e) {
      _setError('Error al cargar órdenes completadas: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Obtener estadísticas del usuario
  Future<Map<String, dynamic>> getUserOrderStats(String userId) async {
    try {
      double totalSpent = await _orderRepository.getTotalSpent(userId);
      int orderCount = await _orderRepository.getOrderCount(userId);
      
      return {
        'totalSpent': totalSpent,
        'orderCount': orderCount,
        'averageOrderValue': orderCount > 0 ? totalSpent / orderCount : 0.0,
      };
    } catch (e) {
      print('Error al obtener estadísticas: $e');
      return {
        'totalSpent': 0.0,
        'orderCount': 0,
        'averageOrderValue': 0.0,
      };
    }
  }

  // Filtrar órdenes por estado
  List<OrderModel> getOrdersByStatus(OrderStatus status) {
    return _orders.where((order) => order.status == status).toList();
  }

  // Obtener órdenes recientes (últimas 5)
  List<OrderModel> getRecentOrders() {
    List<OrderModel> sortedOrders = List.from(_orders);
    sortedOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sortedOrders.take(5).toList();
  }

  // Buscar órdenes por ID o fecha
  List<OrderModel> searchOrders(String query) {
    if (query.isEmpty) {
      return _orders;
    }

    return _orders.where((order) {
      return order.id.toLowerCase().contains(query.toLowerCase()) ||
          order.createdAt.toString().contains(query);
    }).toList();
  }

  // Obtener total gastado en el último mes
  double getMonthlySpending() {
    DateTime now = DateTime.now();
    DateTime lastMonth = DateTime(now.year, now.month - 1, now.day);
    
    return _orders
        .where((order) => 
            order.createdAt.isAfter(lastMonth) && 
            order.status == OrderStatus.delivered)
        .fold(0.0, (sum, order) => sum + order.totalAmount);
  }

  // Obtener número de órdenes en el último mes
  int getMonthlyOrderCount() {
    DateTime now = DateTime.now();
    DateTime lastMonth = DateTime(now.year, now.month - 1, now.day);
    
    return _orders
        .where((order) => order.createdAt.isAfter(lastMonth))
        .length;
  }

  // Refrescar órdenes
  Future<void> refresh(String userId) async {
    await loadUserOrders(userId);
  }

  // Limpiar error
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  // Métodos privados
  void _updateOrdersByStatus() {
    _pendingOrders = _orders.where((order) => 
        order.status == OrderStatus.pending ||
        order.status == OrderStatus.confirmed ||
        order.status == OrderStatus.preparing ||
        order.status == OrderStatus.ready
    ).toList();
    
    _completedOrders = _orders.where((order) => 
        order.status == OrderStatus.delivered
    ).toList();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setCreatingOrder(bool creating) {
    _isCreatingOrder = creating;
    notifyListeners();
  }

  void _setError(String message) {
    _state = OrderState.error;
    _errorMessage = message;
    _isLoading = false;
    _isCreatingOrder = false;
    notifyListeners();
  }
}
