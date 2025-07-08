# Tienda Local - Aplicación Móvil Flutter

Una aplicación móvil completa para tiendas de productos locales, enfocada en turismo y educación, desarrollada con Flutter y Firebase.

## 🚀 Características Principales

### ✨ Funcionalidades Implementadas
- **Autenticación de usuarios** (Firebase Auth)
  - Registro e inicio de sesión con email/contraseña
  - Gestión de perfiles de usuario
  - Recuperación de contraseñas

- **Catálogo de productos**
  - Visualización de productos con imágenes
  - Filtrado por categorías
  - Búsqueda de productos
  - Detalles completos de productos
  - Productos destacados

- **Sistema de carrito de compras**
  - Agregar/quitar productos
  - Gestión de cantidades
  - Cálculo automático de totales
  - Persistencia entre sesiones

- **Gestión de pedidos**
  - Crear nuevos pedidos
  - Historial de pedidos
  - Estados de pedidos
  - Detalles de entrega

- **Navegación moderna**
  - Drawer de navegación lateral
  - Bottom Navigation Bar
  - Navegación fluida entre pantallas
  - Accesos rápidos en el inicio

### 🎨 Interfaz de Usuario
- **Diseño Material Design 3**
- **Tema consistente** con colores personalizados
- **Componentes reutilizables**
- **Animaciones y transiciones**
- **Responsive design**

### 🏗️ Arquitectura

La aplicación sigue el patrón **MVVM (Model-View-ViewModel)** con las siguientes capas:

```
lib/
├── models/              # Modelos de datos
├── services/            # Servicios (Firebase, API)
├── repositories/        # Repositorios (abstracción de datos)
├── viewmodels/          # ViewModels (lógica de negocio)
├── views/              # Vistas (UI)
│   ├── screens/        # Pantallas principales
│   └── widgets/        # Widgets reutilizables
├── controllers/        # Controladores (navegación, etc.)
└── utils/              # Utilidades y configuraciones
```

## 📱 Pantallas de la Aplicación

### 🔐 Autenticación
- **Login Screen**: Inicio de sesión
- **Register Screen**: Registro de nuevos usuarios

### 🏠 Pantalla Principal
- **Home Screen**: 
  - Saludo personalizado al usuario
  - Accesos rápidos a secciones principales
  - Productos destacados
  - Estadísticas del carrito

### 📋 Bottom Navigation
- **Productos**: Catálogo completo con filtros y búsqueda
- **Categorías**: Exploración por categorías
- **Carrito**: Gestión del carrito de compras

### 📂 Drawer Navigation  
- **Inicio**: Pantalla principal
- **Mis Pedidos**: Historial de pedidos
- **Perfil**: Gestión del perfil de usuario

### 🔍 Pantallas Adicionales
- **Product Detail**: Detalles completos del producto
- **Filtros avanzados**: Búsqueda y ordenamiento

## 🛠️ Tecnologías Utilizadas

### Frontend (Flutter)
- **Flutter SDK** 3.0+
- **Dart** 3.0+
- **Provider** - Estado de la aplicación
- **Cached Network Image** - Manejo eficiente de imágenes
- **Intl** - Internacionalización y formato

### Backend (Firebase)
- **Firebase Auth** - Autenticación
- **Cloud Firestore** - Base de datos NoSQL
- **Firebase Storage** - Almacenamiento de archivos

### Dependencias Principales
```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^3.6.0
  firebase_auth: ^5.3.1
  cloud_firestore: ^5.4.4
  provider: ^6.1.2
  cached_network_image: ^3.4.1
  shared_preferences: ^2.3.2
  intl: ^0.19.0
```

## 🚀 Instalación y Configuración

### Prerrequisitos
- Flutter SDK instalado
- Dart SDK
- Android Studio / VS Code
- Cuenta de Firebase

### Pasos de Instalación

1. **Clonar el repositorio**
```bash
git clone [url-del-repositorio]
cd menus_contextuales
```

2. **Instalar dependencias**
```bash
flutter pub get
```

3. **Configurar Firebase**

#### Opción A: Usando FlutterFire CLI (Recomendado)
```bash
# Instalar FlutterFire CLI
dart pub global activate flutterfire_cli

# Configurar Firebase para el proyecto
flutterfire configure
```

#### Opción B: Configuración Manual
1. Crear proyecto en [Firebase Console](https://console.firebase.google.com/)
2. Agregar aplicación Android/iOS
3. Descargar archivos de configuración:
   - `google-services.json` → `android/app/`
   - `GoogleService-Info.plist` → `ios/Runner/`

4. **Habilitar servicios en Firebase**
   - Authentication (Email/Password)
   - Cloud Firestore Database
   - Storage (opcional)

5. **Agregar datos de ejemplo**
   - Usar el archivo `sample_data.json` para crear colecciones y documentos en Firestore

6. **Ejecutar la aplicación**
```bash
flutter run
```

## 📊 Estructura de Datos (Firestore)

### Colecciones Principales

#### `users`
```json
{
  "id": "user_id",
  "name": "Nombre Usuario",
  "email": "usuario@email.com",
  "phone": "1234567890",
  "address": "Dirección completa",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

#### `categories`  
```json
{
  "id": "cat_id",
  "name": "Nombre Categoría",
  "description": "Descripción",
  "color": "#HEX_COLOR",
  "imageUrl": "url_imagen",
  "isActive": true,
  "productCount": 0
}
```

#### `products`
```json
{
  "id": "prod_id",
  "name": "Nombre Producto",
  "description": "Descripción detallada",
  "price": 29.99,
  "imageUrl": "url_imagen",
  "categoryId": "cat_id",
  "sellerId": "seller_id",
  "sellerName": "Nombre Vendedor",
  "stock": 100,
  "tags": ["tag1", "tag2"],
  "isActive": true,
  "isFeatured": false
}
```

#### `orders`
```json
{
  "id": "order_id",
  "userId": "user_id",
  "items": [...],
  "totalAmount": 99.99,
  "status": "pending",
  "deliveryAddress": "dirección",
  "createdAt": "timestamp"
}
```

## 🎯 Funcionalidades Avanzadas

### 🔍 Sistema de Búsqueda y Filtros
- **Búsqueda en tiempo real** por nombre de producto
- **Filtrado por categorías** con chips interactivos
- **Ordenamiento** por precio, nombre, fecha
- **Filtros visuales** con colores de categorías

### 🛒 Carrito de Compras Inteligente
- **Persistencia local** con SharedPreferences
- **Sincronización** con Firestore
- **Validación de stock** en tiempo real
- **Cálculos automáticos** de totales y descuentos

### 📱 Navegación Avanzada
- **Controlador de navegación** centralizado
- **Gestión de estados** entre pantallas
- **Deep linking** preparado
- **Animaciones fluidas** entre vistas

### 🎨 Tema y UI/UX
- **Sistema de colores** consistente
- **Tipografías** escalables
- **Componentes reutilizables**
- **Modo responsive** para diferentes tamaños

## 🔧 Desarrollo y Personalización

### Agregar Nuevas Pantallas
1. Crear archivo en `lib/views/screens/`
2. Implementar StatefulWidget o StatelessWidget
3. Agregar navegación en el controlador
4. Actualizar rutas si es necesario

### Modificar Tema
Editar `lib/utils/app_theme.dart`:
```dart
class AppColors {
  static const Color primary = Color(0xFF2196F3);
  static const Color secondary = Color(0xFF4CAF50);
  // ... otros colores
}
```

### Agregar Nuevos Modelos
1. Crear archivo en `lib/models/`
2. Implementar métodos `fromJson()` y `toJson()`
3. Agregar al repositorio correspondiente

### ViewModels Personalizados
Extender `ChangeNotifier`:
```dart
class MiViewModel extends ChangeNotifier {
  // Estado y lógica de negocio
  
  void updateData() {
    // Lógica
    notifyListeners();
  }
}
```

## 🧪 Testing

### Ejecutar Tests
```bash
# Tests unitarios
flutter test

# Tests de integración
flutter test integration_test/
```

### Estructura de Tests
```
test/
├── unit/           # Tests unitarios
├── widget/         # Tests de widgets
└── integration/    # Tests de integración
```

## 🚀 Deployment

### Android
1. **Generar keystore**
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

2. **Configurar signing**
Editar `android/key.properties`

3. **Build APK/Bundle**
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS
1. **Configurar certificados** en Xcode
2. **Build para App Store**
```bash
flutter build ios --release
```

## 📋 Configuraciones de Seguridad

### Reglas de Firestore
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Usuarios autenticados pueden leer/escribir sus datos
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Productos: lectura pública, escritura autenticada
    match /products/{productId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    // Categorías: lectura pública
    match /categories/{categoryId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    // Pedidos: solo el propietario
    match /orders/{orderId} {
      allow read, write: if request.auth != null && 
        (resource.data.userId == request.auth.uid || 
         request.data.userId == request.auth.uid);
    }
  }
}
```

## 🤝 Contribución

1. Fork el proyecto
2. Crear rama para feature (`git checkout -b feature/AmazingFeature`)
3. Commit cambios (`git commit -m 'Add AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abrir Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para detalles.

## 👥 Autores

- **Tu Nombre** - *Desarrollo inicial* - [TuGitHub](https://github.com/tuusuario)

## 🙏 Reconocimientos

- Flutter Team por el framework
- Firebase por los servicios backend
- Comunidad de Flutter por los packages utilizados

---

**Nota**: Esta aplicación está diseñada con fines educativos y de demostración. Para uso en producción, considere implementar medidas de seguridad adicionales, optimizaciones de rendimiento y testing más exhaustivo.
