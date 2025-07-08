// Datos de ejemplo para Firebase Firestore
// Ejecutar este script en la consola de Firebase para agregar datos de prueba

// Colección: categories
// Documento: cat1
{
  "id": "cat1",
  "name": "Alimentos",
  "description": "Productos alimenticios locales frescos y de calidad",
  "color": "#4CAF50",
  "imageUrl": "https://via.placeholder.com/300x200/4CAF50/FFFFFF?text=Alimentos",
  "isActive": true,
  "productCount": 0,
  "createdAt": "2024-01-01T00:00:00.000Z",
  "updatedAt": "2024-01-01T00:00:00.000Z"
}

// Documento: cat2
{
  "id": "cat2",
  "name": "Artesanías",
  "description": "Productos artesanales únicos hechos por artistas locales",
  "color": "#FF9800",
  "imageUrl": "https://via.placeholder.com/300x200/FF9800/FFFFFF?text=Artesanías",
  "isActive": true,
  "productCount": 0,
  "createdAt": "2024-01-01T00:00:00.000Z",
  "updatedAt": "2024-01-01T00:00:00.000Z"
}

// Documento: cat3
{
  "id": "cat3",
  "name": "Textiles",
  "description": "Ropa y accesorios tradicionales y modernos",
  "color": "#2196F3",
  "imageUrl": "https://via.placeholder.com/300x200/2196F3/FFFFFF?text=Textiles",
  "isActive": true,
  "productCount": 0,
  "createdAt": "2024-01-01T00:00:00.000Z",
  "updatedAt": "2024-01-01T00:00:00.000Z"
}

// Documento: cat4
{
  "id": "cat4",
  "name": "Decoración",
  "description": "Elementos decorativos para el hogar",
  "color": "#9C27B0",
  "imageUrl": "https://via.placeholder.com/300x200/9C27B0/FFFFFF?text=Decoración",
  "isActive": true,
  "productCount": 0,
  "createdAt": "2024-01-01T00:00:00.000Z",
  "updatedAt": "2024-01-01T00:00:00.000Z"
}

// Colección: products
// Documento: prod1
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
  "updatedAt": "2024-01-15T00:00:00.000Z"
}

// Documento: prod2
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
  "updatedAt": "2024-01-20T00:00:00.000Z"
}

// Documento: prod3
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
  "updatedAt": "2024-01-10T00:00:00.000Z"
}

// Documento: prod4
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
  "updatedAt": "2024-01-25T00:00:00.000Z"
}

// Documento: prod5
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
  "updatedAt": "2024-01-05T00:00:00.000Z"
}

// Documento: prod6
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
  "updatedAt": "2024-02-01T00:00:00.000Z"
}

// Documento: prod7
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
  "updatedAt": "2024-01-18T00:00:00.000Z"
}

// Documento: prod8
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
  "updatedAt": "2024-01-12T00:00:00.000Z"
}

// Reglas de seguridad de Firestore sugeridas:
/*
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Reglas para usuarios autenticados
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Reglas para productos (lectura pública, escritura solo para vendedores)
    match /products/{productId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    // Reglas para categorías (lectura pública)
    match /categories/{categoryId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    // Reglas para pedidos (solo el usuario propietario)
    match /orders/{orderId} {
      allow read, write: if request.auth != null && 
        (resource.data.userId == request.auth.uid || 
         request.data.userId == request.auth.uid);
    }
    
    // Reglas para carritos (solo el usuario propietario)
    match /carts/{cartId} {
      allow read, write: if request.auth != null && 
        (resource.data.userId == request.auth.uid || 
         request.data.userId == request.auth.uid);
    }
  }
}
*/
