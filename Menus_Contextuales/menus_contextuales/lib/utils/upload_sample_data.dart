import 'package:cloud_firestore/cloud_firestore.dart';

class SampleDataUploader {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Sube todos los datos de ejemplo a Firestore
  static Future<void> uploadAllSampleData() async {
    try {
      print('🚀 Iniciando carga de datos de ejemplo...');
      
      // Subir categorías primero
      await uploadCategories();
      
      // Subir productos después
      await uploadProducts();
      
      print('✅ Datos de ejemplo cargados exitosamente!');
    } catch (e) {
      print('❌ Error al cargar datos de ejemplo: $e');
      rethrow;
    }
  }

  /// Sube las categorías de ejemplo
  static Future<void> uploadCategories() async {
    print('📁 Subiendo categorías...');
    
    final categories = [
      {
        "id": "cat1",
        "name": "Alimentos",
        "description": "Productos alimenticios locales frescos y de calidad",
        "color": "#4CAF50",
        "imageUrl": "https://via.placeholder.com/300x200/4CAF50/FFFFFF?text=Alimentos",
        "isActive": true,
        "productCount": 0,
        "createdAt": "2024-01-01T00:00:00.000Z",
        "updatedAt": "2024-01-01T00:00:00.000Z",
      },
      {
        "id": "cat2",
        "name": "Artesanías",
        "description": "Productos artesanales únicos hechos por artistas locales",
        "color": "#FF9800",
        "imageUrl": "https://via.placeholder.com/300x200/FF9800/FFFFFF?text=Artesanías",
        "isActive": true,
        "productCount": 0,
        "createdAt": "2024-01-01T00:00:00.000Z",
        "updatedAt": "2024-01-01T00:00:00.000Z",
      },
      {
        "id": "cat3",
        "name": "Textiles",
        "description": "Ropa y accesorios tradicionales y modernos",
        "color": "#2196F3",
        "imageUrl": "https://via.placeholder.com/300x200/2196F3/FFFFFF?text=Textiles",
        "isActive": true,
        "productCount": 0,
        "createdAt": "2024-01-01T00:00:00.000Z",
        "updatedAt": "2024-01-01T00:00:00.000Z",
      },
      {
        "id": "cat4",
        "name": "Decoración",
        "description": "Elementos decorativos para el hogar",
        "color": "#9C27B0",
        "imageUrl": "https://via.placeholder.com/300x200/9C27B0/FFFFFF?text=Decoración",
        "isActive": true,
        "productCount": 0,
        "createdAt": "2024-01-01T00:00:00.000Z",
        "updatedAt": "2024-01-01T00:00:00.000Z",
      },
    ];

    for (final category in categories) {
      await _firestore.collection('categories').doc(category['id'] as String).set(category);
      print('✓ Categoría agregada: ${category['name']}');
    }
  }

  /// Sube los productos de ejemplo
  static Future<void> uploadProducts() async {
    print('📦 Subiendo productos...');
    
    final products = [
      {
        "id": "prod1",
        "name": "Miel de Abeja Orgánica",
        "description": "Miel 100% natural de abejas locales, sin procesar y llena de sabor auténtico. Perfecta para endulzar tus desayunos y postres.",
        "price": 25.99,
        "imageUrl": "https://via.placeholder.com/400x300/FFC107/000000?text=Miel+Orgánica",
        "categoryId": "cat1",
        "sellerId": "seller1",
        "sellerName": "Apiario San José",
        "stock": 50,
        "tags": ["orgánico", "natural", "local", "sin-preservantes"],
        "isActive": true,
        "isFeatured": true,
        "createdAt": "2024-01-15T00:00:00.000Z",
        "updatedAt": "2024-01-15T00:00:00.000Z",
      },
      {
        "id": "prod2",
        "name": "Queso Fresco Artesanal",
        "description": "Queso fresco elaborado con leche de vacas criadas en pastizales naturales. Cremoso y lleno de sabor tradicional.",
        "price": 18.50,
        "imageUrl": "https://via.placeholder.com/400x300/FFFFFF/4CAF50?text=Queso+Fresco",
        "categoryId": "cat1",
        "sellerId": "seller2",
        "sellerName": "Lácteos La Pradera",
        "stock": 30,
        "tags": ["artesanal", "fresco", "lácteo", "tradicional"],
        "isActive": true,
        "isFeatured": false,
        "createdAt": "2024-01-20T00:00:00.000Z",
        "updatedAt": "2024-01-20T00:00:00.000Z",
      },
      {
        "id": "prod3",
        "name": "Bolso Tejido a Mano",
        "description": "Hermoso bolso tejido a mano con fibras naturales. Resistente, espacioso y con diseños únicos inspirados en la cultura local.",
        "price": 45.00,
        "imageUrl": "https://via.placeholder.com/400x300/8D6E63/FFFFFF?text=Bolso+Tejido",
        "categoryId": "cat2",
        "sellerId": "seller3",
        "sellerName": "Textiles Mayas",
        "stock": 15,
        "tags": ["tejido", "artesanal", "fibra-natural", "único"],
        "isActive": true,
        "isFeatured": true,
        "createdAt": "2024-01-10T00:00:00.000Z",
        "updatedAt": "2024-01-10T00:00:00.000Z",
      },
      {
        "id": "prod4",
        "name": "Cerámica Decorativa",
        "description": "Pieza de cerámica decorativa hecha por artistas locales. Cada pieza es única y refleja la tradición alfarera de la región.",
        "price": 65.75,
        "imageUrl": "https://via.placeholder.com/400x300/795548/FFFFFF?text=Cerámica",
        "categoryId": "cat4",
        "sellerId": "seller4",
        "sellerName": "Alfarería El Barro",
        "stock": 8,
        "tags": ["cerámica", "decorativo", "arte", "tradición"],
        "isActive": true,
        "isFeatured": false,
        "createdAt": "2024-01-25T00:00:00.000Z",
        "updatedAt": "2024-01-25T00:00:00.000Z",
      },
      {
        "id": "prod5",
        "name": "Huipil Tradicional",
        "description": "Auténtico huipil bordado a mano con hilos de colores vibrantes. Una prenda tradicional que combina historia y belleza.",
        "price": 120.00,
        "imageUrl": "https://via.placeholder.com/400x300/E91E63/FFFFFF?text=Huipil",
        "categoryId": "cat3",
        "sellerId": "seller3",
        "sellerName": "Textiles Mayas",
        "stock": 5,
        "tags": ["huipil", "bordado", "tradicional", "artesanal"],
        "isActive": true,
        "isFeatured": true,
        "createdAt": "2024-01-05T00:00:00.000Z",
        "updatedAt": "2024-01-05T00:00:00.000Z",
      },
      {
        "id": "prod6",
        "name": "Café Orgánico de Altura",
        "description": "Granos de café cultivados en las montañas locales a más de 1500 metros de altura. Tostado artesanal para un sabor excepcional.",
        "price": 32.00,
        "imageUrl": "https://via.placeholder.com/400x300/6D4C41/FFFFFF?text=Café+Orgánico",
        "categoryId": "cat1",
        "sellerId": "seller5",
        "sellerName": "Café de las Montañas",
        "stock": 100,
        "tags": ["café", "orgánico", "altura", "tostado-artesanal"],
        "isActive": true,
        "isFeatured": false,
        "createdAt": "2024-02-01T00:00:00.000Z",
        "updatedAt": "2024-02-01T00:00:00.000Z",
      },
      {
        "id": "prod7",
        "name": "Mermelada de Frutas Tropicales",
        "description": "Deliciosa mermelada elaborada con frutas tropicales de la región. Sin conservantes artificiales, puro sabor natural.",
        "price": 15.25,
        "imageUrl": "https://via.placeholder.com/400x300/FF5722/FFFFFF?text=Mermelada",
        "categoryId": "cat1",
        "sellerId": "seller6",
        "sellerName": "Dulces Tropicales",
        "stock": 75,
        "tags": ["mermelada", "frutas-tropicales", "natural", "sin-conservantes"],
        "isActive": true,
        "isFeatured": false,
        "createdAt": "2024-01-18T00:00:00.000Z",
        "updatedAt": "2024-01-18T00:00:00.000Z",
      },
      {
        "id": "prod8",
        "name": "Hamaca Artesanal",
        "description": "Hamaca tejida a mano con algodón 100% natural. Cómoda, resistente y perfecta para relajarse en cualquier espacio.",
        "price": 85.00,
        "imageUrl": "https://via.placeholder.com/400x300/009688/FFFFFF?text=Hamaca",
        "categoryId": "cat2",
        "sellerId": "seller7",
        "sellerName": "Tejidos del Caribe",
        "stock": 12,
        "tags": ["hamaca", "algodón", "tejido", "relajación"],
        "isActive": true,
        "isFeatured": true,
        "createdAt": "2024-01-12T00:00:00.000Z",
        "updatedAt": "2024-01-12T00:00:00.000Z",
      },
    ];

    for (final product in products) {
      await _firestore.collection('products').doc(product['id'] as String).set(product);
      print('✓ Producto agregado: ${product['name']}');
    }
  }

  /// Verifica si ya existen datos en Firestore
  static Future<bool> checkIfDataExists() async {
    final categoriesSnapshot = await _firestore.collection('categories').limit(1).get();
    final productsSnapshot = await _firestore.collection('products').limit(1).get();
    
    return categoriesSnapshot.docs.isNotEmpty || productsSnapshot.docs.isNotEmpty;
  }

  /// Limpia todos los datos de ejemplo (útil para testing)
  static Future<void> clearAllSampleData() async {
    print('🗑️ Limpiando datos existentes...');
    
    // Limpiar productos
    final productsSnapshot = await _firestore.collection('products').get();
    for (final doc in productsSnapshot.docs) {
      await doc.reference.delete();
    }
    
    // Limpiar categorías
    final categoriesSnapshot = await _firestore.collection('categories').get();
    for (final doc in categoriesSnapshot.docs) {
      await doc.reference.delete();
    }
    
    print('✅ Datos limpiados exitosamente!');
  }
}
