# Instrucciones para Configurar Firebase

## 🔒 1. Actualizar Reglas de Firestore

### Para Desarrollo (Temporal):
1. Ve a [Firebase Console - Firestore Rules](https://console.firebase.google.com/project/tienda-local-flutter-2024/firestore/rules)
2. Reemplaza las reglas existentes con esto:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // REGLAS TEMPORALES PARA DESARROLLO
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

3. Haz clic en "Publicar"

### Para Producción (Después del desarrollo):
Usa las reglas del archivo `firestore.rules` que incluyen autenticación adecuada.

## 📊 2. Crear Índices Compuestos Requeridos

La aplicación necesita estos índices compuestos en Firestore:

### ⚡ ENLACES DIRECTOS (AUTOMÁTICOS):
La aplicación ha detectado automáticamente los índices necesarios. Usa estos enlaces para crearlos:

#### 🔗 Índice Principal para Products (categoryId + isActive + createdAt):
**[CREAR ÍNDICE AUTOMÁTICAMENTE](https://console.firebase.google.com/v1/r/project/tienda-local-flutter-2024/firestore/indexes?create_composite=Clpwcm9qZWN0cy90aWVuZGEtbG9jYWwtZmx1dHRlci0yMDI0L2RhdGFiYXNlcy8oZGVmYXVsdCkvY29sbGVjdGlvbkdyb3Vwcy9wcm9kdWN0cy9pbmRleGVzL18QARoOCgpjYXRlZ29yeUlkEAEaDAoIaXNBY3RpdmUQARoNCgljcmVhdGVkQXQQAhoMCghfX25hbWVfXxAC)**

- Colección: `products`
- Campos:
  - `categoryId` (Ascending)
  - `isActive` (Ascending)  
  - `createdAt` (Descending)

### 📝 Crear Índices Manualmente (Si los enlaces no funcionan):

#### Índice para Orders (userId + createdAt):
1. Ve a: https://console.firebase.google.com/project/tienda-local-flutter-2024/firestore/indexes
2. Crea un índice compuesto con:
   - Colección: `orders`
   - Campos:
     - `userId` (Ascending)
     - `createdAt` (Descending)

#### Índice para Products (categoryId + isActive + createdAt):
1. Crea otro índice compuesto con:
   - Colección: `products`
   - Campos:
     - `categoryId` (Ascending)
     - `isActive` (Ascending)
     - `createdAt` (Descending)

## 🔗 Enlaces Rápidos:

- **Reglas de Firestore**: https://console.firebase.google.com/project/tienda-local-flutter-2024/firestore/rules
- **Índices de Firestore**: https://console.firebase.google.com/project/tienda-local-flutter-2024/firestore/indexes
- **Datos de Firestore**: https://console.firebase.google.com/project/tienda-local-flutter-2024/firestore/data
- **Autenticación**: https://console.firebase.google.com/project/tienda-local-flutter-2024/authentication

## 📦 3. Datos de Ejemplo

Una vez configuradas las reglas, la aplicación cargará automáticamente:
- ✅ 4 categorías (Alimentos, Artesanías, Textiles, Decoración)
- ✅ 8 productos de ejemplo con detalles completos
- ✅ Imágenes placeholder para testing

## 🚀 4. Ejecutar la Aplicación

```bash
cd "tu_directorio/menus_contextuales"
flutter run -d chrome
```

## 🔧 5. Solución de Problemas

### Error de Permisos:
- Verifica que las reglas de Firestore estén actualizadas
- Asegúrate de haber hecho clic en "Publicar" en la consola

### Error de Índices:
- Los enlaces para crear índices aparecen en la consola cuando se ejecuta la app
- También puedes crearlos manualmente en la consola de Firebase

### Error de Timestamp (RESUELTO):
- ✅ Se corrigió el error de tipo "Instance of 'Timestamp': type 'Timestamp' is not a subtype of type 'String'"
- Los datos ahora usan formato string ISO para las fechas, compatible con los modelos

### Datos No Aparecen:
- Ve a la pantalla de "Administración" en la app (en el drawer)
- Usa los botones para verificar/cargar datos manualmente
- Si tienes datos con formato incorrecto, usa "Limpiar Todos los Datos" y luego "Cargar Datos de Ejemplo"

## 📱 6. Probar la Aplicación

Una vez configurado todo:
1. ✅ Regístrate o inicia sesión
2. ✅ Navega por productos y categorías
3. ✅ Agrega productos al carrito
4. ✅ Realiza pedidos
5. ✅ Ve historial de pedidos
6. ✅ Gestiona tu perfil

## 🎯 Próximos Pasos

Después de probar la aplicación:
1. Cambiar a reglas de producción (firestore.rules)
2. Agregar más validaciones de seguridad
3. Optimizar consultas
4. Agregar tests automáticos
5. Personalizar el diseño
