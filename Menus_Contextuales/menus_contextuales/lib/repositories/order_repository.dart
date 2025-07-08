import '../models/order_model.dart';
import '../models/cart_item_model.dart';
import '../services/firestore_service.dart';

class OrderRepository {
  final FirestoreService _firestoreService;

  OrderRepository({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  // Crear nueva orden
  Future<String?> createOrder({
    required String userId,
    required String userEmail,
    required List<CartItemModel> items,
    String? notes,
    String? deliveryAddress,
  }) async {
    try {
      double totalAmount = items.fold(0.0, (sum, item) => sum + item.totalPrice);

      OrderModel order = OrderModel(
        id: '', // Temporal, se asignará después
        userId: userId,
        userEmail: userEmail,
        items: items,
        totalAmount: totalAmount,
        status: OrderStatus.pending,
        notes: notes,
        deliveryAddress: deliveryAddress,
        createdAt: DateTime.now(),
      );

      // Crear el documento y obtener el ID
      String orderId = await _firestoreService.createOrder(order);
      
      // Actualizar el documento con el ID correcto
      await _firestoreService.updateOrderId(orderId);
      
      return orderId;
    } catch (e) {
      print('Error en OrderRepository.createOrder: $e');
      return null;
    }
  }

  // Obtener órdenes del usuario
  Future<List<OrderModel>> getUserOrders(String userId) async {
    try {
      return await _firestoreService.getUserOrders(userId);
    } catch (e) {
      print('Error en OrderRepository.getUserOrders: $e');
      return [];
    }
  }

  // Stream de órdenes del usuario en tiempo real
  Stream<List<OrderModel>> getUserOrdersStream(String userId) {
    return _firestoreService.getUserOrdersStream(userId);
  }

  // Obtener orden por ID
  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      // En una implementación real, podrías tener un método específico en FirestoreService
      // Por ahora, buscaremos en las órdenes del usuario
      // Esto requeriría conocer el userId, por lo que sería mejor implementar
      // un método específico en FirestoreService
      return null;
    } catch (e) {
      print('Error en OrderRepository.getOrderById: $e');
      return null;
    }
  }

  // Obtener órdenes por estado
  Future<List<OrderModel>> getOrdersByStatus(String userId, OrderStatus status) async {
    try {
      List<OrderModel> orders = await getUserOrders(userId);
      return orders.where((order) => order.status == status).toList();
    } catch (e) {
      print('Error en OrderRepository.getOrdersByStatus: $e');
      return [];
    }
  }

  // Obtener órdenes pendientes
  Future<List<OrderModel>> getPendingOrders(String userId) async {
    return getOrdersByStatus(userId, OrderStatus.pending);
  }

  // Obtener órdenes completadas
  Future<List<OrderModel>> getCompletedOrders(String userId) async {
    return getOrdersByStatus(userId, OrderStatus.delivered);
  }

  // Calcular total de órdenes del usuario
  Future<double> getTotalSpent(String userId) async {
    try {
      List<OrderModel> orders = await getUserOrders(userId);
      return orders
          .where((order) => order.status == OrderStatus.delivered)
          .fold<double>(0.0, (sum, order) => sum + order.totalAmount);
    } catch (e) {
      print('Error en OrderRepository.getTotalSpent: $e');
      return 0.0;
    }
  }

  // Contar órdenes del usuario
  Future<int> getOrderCount(String userId) async {
    try {
      List<OrderModel> orders = await getUserOrders(userId);
      return orders.length;
    } catch (e) {
      print('Error en OrderRepository.getOrderCount: $e');
      return 0;
    }
  }

  // Obtener todas las órdenes (para administradores)
  Future<List<OrderModel>> getAllOrders() async {
    try {
      return await _firestoreService.getAllOrders();
    } catch (e) {
      print('Error en OrderRepository.getAllOrders: $e');
      return [];
    }
  }

  // Obtener órdenes por estado para administradores
  Future<List<OrderModel>> getOrdersByStatusAdmin(OrderStatus status) async {
    try {
      return await _firestoreService.getOrdersByStatus(status);
    } catch (e) {
      print('Error en OrderRepository.getOrdersByStatusAdmin: $e');
      return [];
    }
  }

  // Actualizar estado de orden
  Future<bool> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      await _firestoreService.updateOrderStatus(orderId, newStatus);
      return true;
    } catch (e) {
      print('Error en OrderRepository.updateOrderStatus: $e');
      return false;
    }
  }

  // Reducir stock de producto
  Future<bool> updateProductStock(String productId, int quantityToReduce) async {
    try {
      await _firestoreService.reduceProductStock(productId, quantityToReduce);
      return true;
    } catch (e) {
      print('Error en OrderRepository.updateProductStock: $e');
      return false;
    }
  }
}
