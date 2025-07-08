// TODO: Configurar Firebase
// Este archivo debe ser reemplazado con la configuración real de Firebase
// 
// Pasos para configurar Firebase:
// 1. Ir a https://console.firebase.google.com/
// 2. Crear un nuevo proyecto
// 3. Agregar una aplicación Android/iOS
// 4. Descargar google-services.json (Android) y GoogleService-Info.plist (iOS)
// 5. Colocar los archivos en las carpetas correspondientes:
//    - android/app/google-services.json
//    - ios/Runner/GoogleService-Info.plist
// 6. Habilitar Authentication (Email/Password) y Firestore Database
//
// Para configuración web, agregar el firebase_options.dart generado por FlutterFire CLI

class FirebaseConfig {
  static const String projectId = 'tu-proyecto-id';
  static const String apiKey = 'tu-api-key';
  static const String authDomain = 'tu-proyecto-id.firebaseapp.com';
  static const String storageBucket = 'tu-proyecto-id.appspot.com';
  static const String messagingSenderId = '123456789';
  static const String appId = 'tu-app-id';
}

// Instrucciones adicionales:
//
// 1. Instalar FlutterFire CLI:
//    dart pub global activate flutterfire_cli
//
// 2. Configurar Firebase para el proyecto:
//    flutterfire configure
//
// 3. Esto generará el archivo firebase_options.dart automáticamente
//
// 4. En Firestore, crear las siguientes colecciones con datos de ejemplo:
//
// Colección 'categories':
// - id: cat1, name: "Alimentos", description: "Productos alimenticios locales", color: "#4CAF50"
// - id: cat2, name: "Artesanías", description: "Productos artesanales únicos", color: "#FF9800"
// - id: cat3, name: "Textiles", description: "Ropa y accesorios", color: "#2196F3"
//
// Colección 'products':
// - Agregar productos de ejemplo con los campos definidos en ProductModel
//
// Reglas de Firestore sugeridas:
/*
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Usuarios pueden leer y escribir sus propios datos
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Productos y categorías son de solo lectura para usuarios autenticados
    match /products/{productId} {
      allow read: if request.auth != null;
    }
    
    match /categories/{categoryId} {
      allow read: if request.auth != null;
    }
    
    // Órdenes pueden ser leídas y creadas por el usuario propietario
    match /orders/{orderId} {
      allow read, create: if request.auth != null && request.auth.uid == resource.data.userId;
    }
  }
}
*/
