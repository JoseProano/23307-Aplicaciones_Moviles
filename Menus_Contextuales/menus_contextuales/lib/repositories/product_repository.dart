import '../models/product_model.dart';
import '../models/category_model.dart';
import '../services/firestore_service.dart';

class ProductRepository {
  final FirestoreService _firestoreService;

  ProductRepository({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  // Obtener todos los productos
  Future<List<ProductModel>> getAllProducts() async {
    try {
      return await _firestoreService.getAllProducts();
    } catch (e) {
      print('Error en ProductRepository.getAllProducts: $e');
      return [];
    }
  }

  // Obtener productos por categoría
  Future<List<ProductModel>> getProductsByCategory(String categoryId) async {
    try {
      return await _firestoreService.getProductsByCategory(categoryId);
    } catch (e) {
      print('Error en ProductRepository.getProductsByCategory: $e');
      return [];
    }
  }

  // Buscar productos
  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      return await _firestoreService.searchProducts(query);
    } catch (e) {
      print('Error en ProductRepository.searchProducts: $e');
      return [];
    }
  }

  // Obtener todas las categorías
  Future<List<CategoryModel>> getAllCategories() async {
    try {
      return await _firestoreService.getAllCategories();
    } catch (e) {
      print('Error en ProductRepository.getAllCategories: $e');
      return [];
    }
  }

  // Stream de productos en tiempo real
  Stream<List<ProductModel>> getProductsStream() {
    return _firestoreService.getProductsStream();
  }

  // Stream de categorías en tiempo real
  Stream<List<CategoryModel>> getCategoriesStream() {
    return _firestoreService.getCategoriesStream();
  }

  // Obtener productos destacados (últimos 10)
  Future<List<ProductModel>> getFeaturedProducts() async {
    try {
      List<ProductModel> products = await _firestoreService.getAllProducts();
      return products.take(10).toList();
    } catch (e) {
      print('Error en ProductRepository.getFeaturedProducts: $e');
      return [];
    }
  }

  // Filtrar productos por rango de precio
  Future<List<ProductModel>> getProductsByPriceRange(double minPrice, double maxPrice) async {
    try {
      List<ProductModel> products = await _firestoreService.getAllProducts();
      return products
          .where((product) => product.price >= minPrice && product.price <= maxPrice)
          .toList();
    } catch (e) {
      print('Error en ProductRepository.getProductsByPriceRange: $e');
      return [];
    }
  }

  // Obtener productos de un vendedor específico
  Future<List<ProductModel>> getProductsBySeller(String sellerId) async {
    try {
      List<ProductModel> products = await _firestoreService.getAllProducts();
      return products.where((product) => product.sellerId == sellerId).toList();
    } catch (e) {
      print('Error en ProductRepository.getProductsBySeller: $e');
      return [];
    }
  }

  // Crear producto
  Future<String> createProduct(ProductModel product) async {
    try {
      return await _firestoreService.createProduct(product);
    } catch (e) {
      print('Error en ProductRepository.createProduct: $e');
      return '';
    }
  }

  // Actualizar producto
  Future<bool> updateProduct(String productId, Map<String, dynamic> productData) async {
    try {
      return await _firestoreService.updateProduct(productId, productData);
    } catch (e) {
      print('Error en ProductRepository.updateProduct: $e');
      return false;
    }
  }

  // Eliminar producto
  Future<bool> deleteProduct(String productId) async {
    try {
      return await _firestoreService.deleteProduct(productId);
    } catch (e) {
      print('Error en ProductRepository.deleteProduct: $e');
      return false;
    }
  }

  // Crear categoría
  Future<String> createCategory(CategoryModel category) async {
    try {
      return await _firestoreService.createCategory(category);
    } catch (e) {
      print('Error en ProductRepository.createCategory: $e');
      return '';
    }
  }

  // Actualizar categoría
  Future<bool> updateCategory(String categoryId, Map<String, dynamic> categoryData) async {
    try {
      return await _firestoreService.updateCategory(categoryId, categoryData);
    } catch (e) {
      print('Error en ProductRepository.updateCategory: $e');
      return false;
    }
  }

  // Eliminar categoría
  Future<bool> deleteCategory(String categoryId) async {
    try {
      return await _firestoreService.deleteCategory(categoryId);
    } catch (e) {
      print('Error en ProductRepository.deleteCategory: $e');
      return false;
    }
  }

  // Obtener TODOS los productos (incluyendo inactivos) - Para administración
  Future<List<ProductModel>> getAllProductsIncludingInactive() async {
    try {
      return await _firestoreService.getAllProductsIncludingInactive();
    } catch (e) {
      print('Error en ProductRepository.getAllProductsIncludingInactive: $e');
      return [];
    }
  }

  // Crear producto desde datos simples (para administración)
  Future<String> createProductFromData(Map<String, dynamic> productData) async {
    try {
      // Agregar campos obligatorios
      productData['sellerId'] = 'admin';
      productData['sellerName'] = 'Administrador';
      productData['tags'] = productData['tags'] ?? [];
      productData['createdAt'] = DateTime.now().toIso8601String();
      productData['updatedAt'] = DateTime.now().toIso8601String();
      
      return await _firestoreService.createProductFromData(productData);
    } catch (e) {
      print('Error en ProductRepository.createProductFromData: $e');
      return '';
    }
  }
}
