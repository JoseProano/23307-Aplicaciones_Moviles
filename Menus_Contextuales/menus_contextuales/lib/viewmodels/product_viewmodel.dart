import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../repositories/product_repository.dart';

enum ProductState {
  initial,
  loading,
  loaded,
  error,
}

class ProductViewModel extends ChangeNotifier {
  final ProductRepository _productRepository;

  ProductViewModel({ProductRepository? productRepository})
      : _productRepository = productRepository ?? ProductRepository();

  // Estado
  ProductState _state = ProductState.initial;
  List<ProductModel> _products = [];
  List<CategoryModel> _categories = [];
  List<ProductModel> _featuredProducts = [];
  List<ProductModel> _filteredProducts = [];
  String _errorMessage = '';
  bool _isLoading = false;
  String _searchQuery = '';
  String? _selectedCategoryId;

  // Getters
  ProductState get state => _state;
  List<ProductModel> get products => _products;
  List<CategoryModel> get categories => _categories;
  List<ProductModel> get featuredProducts => _featuredProducts;
  List<ProductModel> get filteredProducts => _filteredProducts;
  String get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String? get selectedCategoryId => _selectedCategoryId;

  // Inicializar datos
  Future<void> initialize() async {
    await loadCategories();
    await loadProducts();
    await loadFeaturedProducts();
  }

  // Cargar todos los productos
  Future<void> loadProducts() async {
    _setLoading(true);
    try {
      _products = await _productRepository.getAllProducts();
      _filteredProducts = List.from(_products);
      _state = ProductState.loaded;
      _errorMessage = '';
    } catch (e) {
      _setError('Error al cargar productos: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Cargar TODOS los productos (incluyendo inactivos) - Para administración
  Future<void> loadAllProducts() async {
    _setLoading(true);
    try {
      _products = await _productRepository.getAllProductsIncludingInactive();
      _filteredProducts = List.from(_products);
      _state = ProductState.loaded;
      _errorMessage = '';
    } catch (e) {
      _setError('Error al cargar todos los productos: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Cargar categorías
  Future<void> loadCategories() async {
    try {
      _categories = await _productRepository.getAllCategories();
      notifyListeners();
    } catch (e) {
      print('Error al cargar categorías: $e');
    }
  }

  // Cargar productos destacados
  Future<void> loadFeaturedProducts() async {
    try {
      _featuredProducts = await _productRepository.getFeaturedProducts();
      notifyListeners();
    } catch (e) {
      print('Error al cargar productos destacados: $e');
    }
  }

  // Cargar productos por categoría
  Future<void> loadProductsByCategory(String categoryId) async {
    _setLoading(true);
    try {
      _selectedCategoryId = categoryId;
      _products = await _productRepository.getProductsByCategory(categoryId);
      _filteredProducts = List.from(_products);
      _state = ProductState.loaded;
      _errorMessage = '';
    } catch (e) {
      _setError('Error al cargar productos por categoría: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Buscar productos
  Future<void> searchProducts(String query) async {
    _searchQuery = query;
    
    if (query.isEmpty) {
      _filteredProducts = List.from(_products);
    } else {
      _setLoading(true);
      try {
        List<ProductModel> searchResults = await _productRepository.searchProducts(query);
        _filteredProducts = searchResults;
      } catch (e) {
        _setError('Error al buscar productos: $e');
      } finally {
        _setLoading(false);
      }
    }
    notifyListeners();
  }

  // Filtrar productos localmente
  void filterProductsLocally(String query) {
    _searchQuery = query;
    
    if (query.isEmpty) {
      _filteredProducts = List.from(_products);
    } else {
      _filteredProducts = _products
          .where((product) =>
              product.name.toLowerCase().contains(query.toLowerCase()) ||
              product.description.toLowerCase().contains(query.toLowerCase()) ||
              product.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase())))
          .toList();
    }
    notifyListeners();
  }

  // Filtrar por rango de precio
  Future<void> filterByPriceRange(double minPrice, double maxPrice) async {
    _setLoading(true);
    try {
      List<ProductModel> filteredByPrice = await _productRepository.getProductsByPriceRange(minPrice, maxPrice);
      _filteredProducts = filteredByPrice;
    } catch (e) {
      _setError('Error al filtrar por precio: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Ordenar productos
  void sortProducts(String sortBy) {
    switch (sortBy) {
      case 'name_asc':
        _filteredProducts.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'name_desc':
        _filteredProducts.sort((a, b) => b.name.compareTo(a.name));
        break;
      case 'price_asc':
        _filteredProducts.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_desc':
        _filteredProducts.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'newest':
        _filteredProducts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'oldest':
        _filteredProducts.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
    }
    notifyListeners();
  }

  // Obtener productos por vendedor
  Future<void> loadProductsBySeller(String sellerId) async {
    _setLoading(true);
    try {
      _products = await _productRepository.getProductsBySeller(sellerId);
      _filteredProducts = List.from(_products);
      _state = ProductState.loaded;
      _errorMessage = '';
    } catch (e) {
      _setError('Error al cargar productos del vendedor: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Limpiar filtros
  void clearFilters() {
    _searchQuery = '';
    _selectedCategoryId = null;
    _filteredProducts = List.from(_products);
    notifyListeners();
  }

  // Refrescar datos
  Future<void> refresh() async {
    await initialize();
  }

  // Obtener categoría por ID
  CategoryModel? getCategoryById(String categoryId) {
    try {
      return _categories.firstWhere((category) => category.id == categoryId);
    } catch (e) {
      return null;
    }
  }

  // Crear producto
  Future<bool> createProduct(Map<String, dynamic> productData) async {
    _setLoading(true);
    try {
      String productId = await _productRepository.createProductFromData(productData);
      
      if (productId.isNotEmpty) {
        // Recargar productos para mostrar el nuevo
        await loadAllProducts(); // Usar loadAllProducts para administración
        return true;
      } else {
        _setError('Error al crear el producto');
        return false;
      }
    } catch (e) {
      _setError('Error al crear producto: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Actualizar producto
  Future<bool> updateProduct(String productId, Map<String, dynamic> productData) async {
    _setLoading(true);
    try {
      // Agregar timestamp de actualización
      productData['updatedAt'] = DateTime.now().toIso8601String();
      
      bool success = await _productRepository.updateProduct(productId, productData);
      
      if (success) {
        // Recargar productos para mostrar los cambios
        await loadAllProducts();
        return true;
      } else {
        _setError('Error al actualizar el producto');
        return false;
      }
    } catch (e) {
      _setError('Error al actualizar producto: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Eliminar producto
  Future<bool> deleteProduct(String productId) async {
    _setLoading(true);
    try {
      bool success = await _productRepository.deleteProduct(productId);
      
      if (success) {
        // Recargar productos para reflejar la eliminación
        await loadAllProducts();
        return true;
      } else {
        _setError('Error al eliminar el producto');
        return false;
      }
    } catch (e) {
      _setError('Error al eliminar producto: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Crear categoría
  Future<bool> createCategory(Map<String, dynamic> categoryData) async {
    _setLoading(true);
    try {
      final category = CategoryModel(
        id: '', // Se asignará automáticamente
        name: categoryData['name'],
        description: categoryData['description'],
        iconUrl: categoryData['iconUrl'] ?? 'https://via.placeholder.com/100x100?text=Cat',
        color: categoryData['color'] ?? '#2196F3',
        isActive: categoryData['isActive'] ?? true,
        createdAt: DateTime.now(),
      );

      String categoryId = await _productRepository.createCategory(category);
      
      if (categoryId.isNotEmpty) {
        // Recargar categorías para mostrar la nueva
        await loadCategories();
        return true;
      } else {
        _setError('Error al crear la categoría');
        return false;
      }
    } catch (e) {
      _setError('Error al crear categoría: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Actualizar categoría
  Future<bool> updateCategory(String categoryId, Map<String, dynamic> categoryData) async {
    _setLoading(true);
    try {
      // Agregar timestamp de actualización
      categoryData['updatedAt'] = DateTime.now().toIso8601String();
      
      bool success = await _productRepository.updateCategory(categoryId, categoryData);
      
      if (success) {
        // Recargar categorías para mostrar los cambios
        await loadCategories();
        return true;
      } else {
        _setError('Error al actualizar la categoría');
        return false;
      }
    } catch (e) {
      _setError('Error al actualizar categoría: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Eliminar categoría
  Future<bool> deleteCategory(String categoryId) async {
    _setLoading(true);
    try {
      bool success = await _productRepository.deleteCategory(categoryId);
      
      if (success) {
        // Recargar categorías para reflejar la eliminación
        await loadCategories();
        return true;
      } else {
        _setError('Error al eliminar la categoría');
        return false;
      }
    } catch (e) {
      _setError('Error al eliminar categoría: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Métodos privados
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _state = ProductState.error;
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
  }
}
