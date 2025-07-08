# Script para Reiniciar Datos de la Aplicación

## 🔄 Pasos para Reiniciar Completamente los Datos

### 1. Abrir la Aplicación
```bash
cd "tu_directorio/menus_contextuales"
flutter run -d chrome
```

### 2. Ir a la Pantalla de Administración
- Una vez que la app esté funcionando
- Abre el menú lateral (drawer)
- Toca en "Administración"

### 3. Limpiar Datos Existentes (Si hay errores de formato)
- En la pantalla de administración
- Toca "Limpiar Todos los Datos"
- Confirma la acción

### 4. Cargar Datos Corregidos
- Después de limpiar, toca "Cargar Datos de Ejemplo"
- Espera a que aparezca el mensaje de éxito

### 5. Verificar Datos
- Toca "Verificar Datos Existentes" para confirmar
- Navega por la app para ver productos y categorías

## ✅ Datos que se Cargarán (Formato Corregido)

### Categorías (4):
- 🥬 **Alimentos** - Productos alimenticios locales frescos
- 🎨 **Artesanías** - Productos artesanales únicos  
- 👕 **Textiles** - Ropa y accesorios tradicionales
- 🏺 **Decoración** - Elementos decorativos para el hogar

### Productos (8):
- 🍯 **Miel de Abeja Orgánica** - $25.99 (Alimentos, Destacado)
- 🧀 **Queso Fresco Artesanal** - $18.50 (Alimentos)
- 👜 **Bolso Tejido a Mano** - $45.00 (Artesanías, Destacado)
- 🏺 **Cerámica Decorativa** - $65.75 (Decoración)
- 👘 **Huipil Tradicional** - $120.00 (Textiles, Destacado)
- ☕ **Café Orgánico de Altura** - $32.00 (Alimentos)
- 🍓 **Mermelada de Frutas Tropicales** - $15.25 (Alimentos)
- 🏖️ **Hamaca Artesanal** - $85.00 (Artesanías, Destacado)

## 🚨 Problemas Conocidos Resueltos

### ✅ Error de Timestamp
- **Problema**: `Instance of 'Timestamp': type 'Timestamp' is not a subtype of type 'String'`
- **Solución**: Se cambió el formato de fechas de Timestamp a String ISO
- **Estado**: ✅ RESUELTO

### ✅ Error de Permisos
- **Problema**: `Missing or insufficient permissions`
- **Solución**: Reglas de Firestore actualizadas para desarrollo
- **Estado**: ✅ RESUELTO (con reglas de desarrollo)

### ⚠️ Índices de Firestore
- **Problema**: Consultas requieren índices compuestos
- **Solución**: Enlaces automáticos en la consola, o crear manualmente
- **Estado**: ⚠️ PENDIENTE (se crean automáticamente al usar la app)

## 📱 Funcionalidades para Probar

Después de cargar los datos:

1. **🏠 Pantalla de Inicio**
   - Ver productos destacados
   - Usar accesos rápidos por categoría
   - Buscar productos

2. **📦 Pantalla de Productos**
   - Ver lista completa
   - Filtrar por categoría
   - Ver detalles de producto
   - Agregar al carrito

3. **📂 Pantalla de Categorías**
   - Ver todas las categorías
   - Tocar para filtrar productos

4. **🛒 Carrito de Compras**
   - Agregar/quitar productos
   - Cambiar cantidades
   - Proceder al checkout

5. **📋 Realizar Pedido**
   - Completar datos de envío
   - Confirmar pedido
   - Ver en historial de pedidos

6. **👤 Perfil**
   - Ver información del usuario
   - Cambiar datos personales
   - Ver estadísticas

## 🎯 Resultado Esperado

Una aplicación de tienda local completamente funcional con:
- ✅ Autenticación automática (admin@tienda.local)
- ✅ 4 categorías de productos
- ✅ 8 productos de ejemplo
- ✅ Navegación completa (Drawer + BottomNav)
- ✅ Carrito de compras funcional
- ✅ Sistema de pedidos
- ✅ Gestión de perfil de usuario
