# Tienda Local - App de Productos Locales

Una aplicación móvil desarrollada en Flutter para promocionar y vender productos de emprendimientos locales, siguiendo la arquitectura MVVM con Firebase como backend.

## 🏗️ Arquitectura

La aplicación está estructurada siguiendo el patrón **MVVM (Model-View-ViewModel)** con las siguientes capas:

```
lib/
├── models/          # Modelos de datos (User, Product, Category, Order, CartItem)
├── repositories/    # Capa de acceso a datos (Auth, Product, Order)
├── services/        # Servicios de Firebase (Auth, Firestore)
├── viewmodels/      # Lógica de negocio y estado (Provider)
├── views/
│   ├── screens/     # Pantallas de la aplicación
│   └── widgets/     # Componentes reutilizables
├── utils/           # Utilidades, temas y constantes
└── main.dart        # Punto de entrada de la aplicación
```

## 📱 Funcionalidades

### Navegación
- **DrawerView** con las siguientes opciones:
  - Inicio
  - Mis pedidos  
  - Perfil

- **BottomNavigationBar** con:
  - Productos
  - Categorías
  - Carrito

### Características Principales
- ✅ Autenticación de usuarios con Firebase Auth
- ✅ Catálogo de productos con Firestore
- ✅ Gestión de carrito de compras (persistente)
- ✅ Sistema de pedidos
- ✅ Perfiles de usuario
- ✅ Búsqueda y filtros de productos
- ✅ Categorización de productos
- ✅ Interfaz moderna y responsiva

## 🔧 Configuración

### Prerrequisitos
- Flutter SDK (>=3.7.2)
- Dart SDK
- Android Studio / VS Code
- Cuenta de Firebase

### Instalación

1. **Clonar el repositorio**
```bash
git clone <url-del-repositorio>
cd menus_contextuales
```

2. **Instalar dependencias**
```bash
flutter pub get
```

3. **Configurar Firebase**

   a. Instalar FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```

   b. Configurar Firebase para el proyecto:
   ```bash
   flutterfire configure
   ```

   c. En la consola de Firebase:
   - Habilitar Authentication (Email/Password)
   - Crear base de datos Firestore
   - Configurar reglas de seguridad

4. **Configurar datos de ejemplo**

   En Firestore, crear las siguientes colecciones:

   **Categorías** (`categories`):
   ```json
   {
     "id": "cat1",
     "name": "Alimentos",
     "description": "Productos alimenticios locales",
     "color": "#4CAF50",
     "iconUrl": "",
     "isActive": true,
     "createdAt": "timestamp"
   }
   ```

   **Productos** (`products`):
   ```json
   {
     "name": "Miel Orgánica",
     "description": "Miel pura de abejas locales",
     "price": 25.99,
     "imageUrl": "https://example.com/image.jpg",
     "categoryId": "cat1",
     "sellerId": "seller1",
     "sellerName": "Emprendimiento Local",
     "stock": 50,
     "tags": ["orgánico", "natural", "local"],
     "isActive": true,
     "createdAt": "timestamp",
     "updatedAt": "timestamp"
   }
   ```

5. **Ejecutar la aplicación**
```bash
flutter run
```

## 🔐 Reglas de Firestore

```javascript
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
      allow read, create: if request.auth != null && 
        request.auth.uid == resource.data.userId;
    }
  }
}
```

## 📦 Dependencias Principales

- **flutter**: Framework de desarrollo
- **firebase_core**: Core de Firebase
- **firebase_auth**: Autenticación
- **cloud_firestore**: Base de datos NoSQL
- **provider**: Gestión de estado
- **cached_network_image**: Caché de imágenes
- **shared_preferences**: Almacenamiento local
- **intl**: Formateo de fechas y números

## 🎨 Tema y Diseño

La aplicación utiliza Material Design 3 con una paleta de colores personalizada:

- **Primary**: Azul (#2196F3)
- **Secondary**: Verde (#4CAF50) 
- **Accent**: Naranja (#FF9800)
- **Error**: Rojo (#F44336)

## 🔄 Estados de la Aplicación

### AuthViewModel
- `initial`: Estado inicial
- `loading`: Cargando
- `authenticated`: Usuario autenticado
- `unauthenticated`: Usuario no autenticado
- `error`: Error en autenticación

### ProductViewModel
- Gestión de productos y categorías
- Búsqueda y filtros
- Paginación y carga

### CartViewModel
- Gestión del carrito de compras
- Persistencia local con SharedPreferences
- Validación de stock

### OrderViewModel
- Creación y gestión de pedidos
- Historial de órdenes
- Estados de pedidos

## 🧪 Testing

Para ejecutar las pruebas:

```bash
flutter test
```

## 📱 Plataformas Soportadas

- ✅ Android
- ✅ iOS
- ✅ Web (con configuración adicional)

## 🚀 Despliegue

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## 🤝 Contribución

1. Fork el proyecto
2. Crear una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abrir un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE.md](LICENSE.md) para detalles.

## 📞 Soporte

Si tienes preguntas o necesitas ayuda:

- Email: soporte@tiendalocal.com
- Issues: [GitHub Issues](link-to-issues)

## 🔄 Roadmap

- [ ] Sistema de calificaciones y reseñas
- [ ] Chat en tiempo real con vendedores
- [ ] Notificaciones push
- [ ] Sistema de cupones y descuentos
- [ ] Integración con pasarelas de pago
- [ ] Modo offline
- [ ] Dashboard para vendedores
