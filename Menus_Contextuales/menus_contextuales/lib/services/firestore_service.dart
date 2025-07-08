import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../models/order_model.dart';
import '../models/supplier_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Colecciones
  static const String usersCollection = 'users';
  static const String productsCollection = 'products';
  static const String categoriesCollection = 'categories';
  static const String ordersCollection = 'orders';
  static const String suppliersCollection = 'suppliers';

  // ===== USUARIOS =====
  
  // Crear usuario en Firestore
  Future<void> createUser(UserModel user) async {
    try {
      await _firestore.collection(usersCollection).doc(user.uid).set(user.toJson());
    } catch (e) {
      print('Error al crear usuario: $e');
      rethrow;
    }
  }

  // Obtener usuario por ID
  Future<UserModel?> getUserById(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection(usersCollection).doc(uid).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error al obtener usuario: $e');
      return null;
    }
  }

  // Actualizar usuario
  Future<void> updateUser(UserModel user) async {
    try {
      await _firestore.collection(usersCollection).doc(user.uid).update(user.toJson());
    } catch (e) {
      print('Error al actualizar usuario: $e');
      rethrow;
    }
  }

  // ===== PRODUCTOS =====

  // Obtener todos los productos
  Future<List<ProductModel>> getAllProducts() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(productsCollection)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ProductModel.fromJson({
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>
              }))
          .toList();
    } catch (e) {
      print('Error al obtener productos: $e');
      return [];
    }
  }

  // Obtener productos por categoría
  Future<List<ProductModel>> getProductsByCategory(String categoryId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(productsCollection)
          .where('categoryId', isEqualTo: categoryId)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ProductModel.fromJson({
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>
              }))
          .toList();
    } catch (e) {
      print('Error al obtener productos por categoría: $e');
      return [];
    }
  }

  // Buscar productos
  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(productsCollection)
          .where('isActive', isEqualTo: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ProductModel.fromJson({
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>
              }))
          .where((product) =>
              product.name.toLowerCase().contains(query.toLowerCase()) ||
              product.description.toLowerCase().contains(query.toLowerCase()) ||
              product.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase())))
          .toList();
    } catch (e) {
      print('Error al buscar productos: $e');
      return [];
    }
  }

  // Crear producto
  Future<String> createProduct(ProductModel product) async {
    try {
      DocumentReference docRef = await _firestore
          .collection(productsCollection)
          .add(product.toJson());
      return docRef.id;
    } catch (e) {
      print('Error al crear producto: $e');
      rethrow;
    }
  }

  // Crear producto desde datos simples (para administración)
  Future<String> createProductFromData(Map<String, dynamic> productData) async {
    try {
      DocumentReference docRef = await _firestore
          .collection(productsCollection)
          .add(productData);
      
      // Actualizar el documento con su propio ID
      await docRef.update({'id': docRef.id});
      
      return docRef.id;
    } catch (e) {
      print('Error al crear producto desde datos: $e');
      rethrow;
    }
  }

  // Actualizar producto
  Future<bool> updateProduct(String productId, Map<String, dynamic> productData) async {
    try {
      await _firestore
          .collection(productsCollection)
          .doc(productId)
          .update(productData);
      return true;
    } catch (e) {
      print('Error al actualizar producto: $e');
      return false;
    }
  }

  // Reducir stock de producto
  Future<bool> reduceProductStock(String productId, int quantityToReduce) async {
    try {
      // Usar transacción para asegurar la integridad de los datos
      await _firestore.runTransaction((transaction) async {
        DocumentReference productRef = _firestore.collection(productsCollection).doc(productId);
        DocumentSnapshot productSnapshot = await transaction.get(productRef);
        
        if (!productSnapshot.exists) {
          throw Exception('Producto no encontrado');
        }
        
        Map<String, dynamic> productData = productSnapshot.data() as Map<String, dynamic>;
        int currentStock = productData['stock'] ?? 0;
        
        if (currentStock < quantityToReduce) {
          throw Exception('Stock insuficiente. Stock actual: $currentStock, cantidad solicitada: $quantityToReduce');
        }
        
        int newStock = currentStock - quantityToReduce;
        transaction.update(productRef, {'stock': newStock});
      });
      
      return true;
    } catch (e) {
      print('Error al reducir stock del producto: $e');
      return false;
    }
  }

  // Eliminar producto (marcarlo como inactivo)
  Future<bool> deleteProduct(String productId) async {
    try {
      await _firestore
          .collection(productsCollection)
          .doc(productId)
          .update({'isActive': false});
      return true;
    } catch (e) {
      print('Error al eliminar producto: $e');
      return false;
    }
  }

  // Obtener TODOS los productos (incluyendo inactivos) - Para administración
  Future<List<ProductModel>> getAllProductsIncludingInactive() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(productsCollection)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ProductModel.fromJson({
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>
              }))
          .toList();
    } catch (e) {
      print('Error al obtener todos los productos: $e');
      return [];
    }
  }

  // ===== CATEGORÍAS =====

  // Obtener todas las categorías
  Future<List<CategoryModel>> getAllCategories() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(categoriesCollection)
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => CategoryModel.fromJson({
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>
              }))
          .toList();
    } catch (e) {
      print('Error al obtener categorías: $e');
      return [];
    }
  }

  // Crear categoría
  Future<String> createCategory(CategoryModel category) async {
    try {
      DocumentReference docRef = await _firestore
          .collection(categoriesCollection)
          .add(category.toJson());
      return docRef.id;
    } catch (e) {
      print('Error al crear categoría: $e');
      rethrow;
    }
  }

  // Actualizar categoría
  Future<bool> updateCategory(String categoryId, Map<String, dynamic> categoryData) async {
    try {
      await _firestore
          .collection(categoriesCollection)
          .doc(categoryId)
          .update(categoryData);
      return true;
    } catch (e) {
      print('Error al actualizar categoría: $e');
      return false;
    }
  }

  // Eliminar categoría (marcarla como inactiva)
  Future<bool> deleteCategory(String categoryId) async {
    try {
      await _firestore
          .collection(categoriesCollection)
          .doc(categoryId)
          .update({'isActive': false});
      return true;
    } catch (e) {
      print('Error al eliminar categoría: $e');
      return false;
    }
  }

  // ===== ÓRDENES =====

  // Crear orden
  Future<String> createOrder(OrderModel order) async {
    try {
      DocumentReference docRef = await _firestore.collection(ordersCollection).add(order.toJson());
      return docRef.id;
    } catch (e) {
      print('Error al crear orden: $e');
      rethrow;
    }
  }

  // Obtener órdenes del usuario
  Future<List<OrderModel>> getUserOrders(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(ordersCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => OrderModel.fromJson({
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>
              }))
          .toList();
    } catch (e) {
      print('Error al obtener órdenes del usuario: $e');
      return [];
    }
  }

  // Obtener todas las órdenes (para administradores)
  Future<List<OrderModel>> getAllOrders() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(ordersCollection)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => OrderModel.fromJson({
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>
              }))
          .toList();
    } catch (e) {
      print('Error al obtener todas las órdenes: $e');
      return [];
    }
  }

  // Obtener órdenes por estado
  Future<List<OrderModel>> getOrdersByStatus(OrderStatus status) async {
    try {
      // Primero obtenemos todas las órdenes
      QuerySnapshot querySnapshot = await _firestore
          .collection(ordersCollection)
          .get();

      // Filtramos por estado en memoria
      List<OrderModel> allOrders = querySnapshot.docs
          .map((doc) => OrderModel.fromJson({
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>
              }))
          .toList();
      
      // Filtrar por estado y ordenar por fecha
      List<OrderModel> filteredOrders = allOrders
          .where((order) => order.status == status)
          .toList();
      
      // Ordenar por fecha de creación (más reciente primero)
      filteredOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return filteredOrders;
    } catch (e) {
      print('Error al obtener órdenes por estado: $e');
      return [];
    }
  }

  // Actualizar estado de orden
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      await _firestore.collection(ordersCollection).doc(orderId).update({
        'status': newStatus.toString().split('.').last,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error al actualizar estado de orden: $e');
      rethrow;
    }
  }

  // Actualizar el ID de la orden
  Future<void> updateOrderId(String orderId) async {
    try {
      await _firestore.collection(ordersCollection).doc(orderId).update({
        'id': orderId,
      });
    } catch (e) {
      print('Error al actualizar ID de orden: $e');
      rethrow;
    }
  }

  // Stream de productos en tiempo real
  Stream<List<ProductModel>> getProductsStream() {
    return _firestore
        .collection(productsCollection)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductModel.fromJson({
                  'id': doc.id,
                  ...doc.data()
                }))
            .toList());
  }

  // Stream de categorías en tiempo real
  Stream<List<CategoryModel>> getCategoriesStream() {
    return _firestore
        .collection(categoriesCollection)
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CategoryModel.fromJson({
                  'id': doc.id,
                  ...doc.data()
                }))
            .toList());
  }

  // Stream de órdenes del usuario en tiempo real
  Stream<List<OrderModel>> getUserOrdersStream(String userId) {
    return _firestore
        .collection(ordersCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromJson({
                  'id': doc.id,
                  ...doc.data()
                }))
            .toList());
  }

  // ===== PROVEEDORES =====

  // Crear proveedor
  Future<String?> addSupplier(Map<String, dynamic> supplierData) async {
    try {
      final now = DateTime.now();
      supplierData['createdAt'] = now.toIso8601String();
      supplierData['updatedAt'] = now.toIso8601String();
      
      DocumentReference docRef = await _firestore.collection(suppliersCollection).add(supplierData);
      return docRef.id;
    } catch (e) {
      print('Error al crear proveedor: $e');
      return null;
    }
  }

  // Obtener todos los proveedores
  Future<List<SupplierModel>> getSuppliers() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection(suppliersCollection).get();
      return snapshot.docs.map((doc) => SupplierModel.fromJson({
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>
      })).toList();
    } catch (e) {
      print('Error al obtener proveedores: $e');
      return [];
    }
  }

  // Obtener proveedores activos
  Future<List<SupplierModel>> getActiveSuppliers() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(suppliersCollection)
          .where('isActive', isEqualTo: true)
          .get();
      return snapshot.docs.map((doc) => SupplierModel.fromJson({
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>
      })).toList();
    } catch (e) {
      print('Error al obtener proveedores activos: $e');
      return [];
    }
  }

  // Obtener proveedor por ID
  Future<SupplierModel?> getSupplierById(String supplierId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection(suppliersCollection).doc(supplierId).get();
      if (doc.exists) {
        return SupplierModel.fromJson({
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>
        });
      }
      return null;
    } catch (e) {
      print('Error al obtener proveedor por ID: $e');
      return null;
    }
  }

  // Actualizar proveedor
  Future<bool> updateSupplier(String supplierId, Map<String, dynamic> updateData) async {
    try {
      updateData['updatedAt'] = DateTime.now().toIso8601String();
      await _firestore.collection(suppliersCollection).doc(supplierId).update(updateData);
      return true;
    } catch (e) {
      print('Error al actualizar proveedor: $e');
      return false;
    }
  }
}
