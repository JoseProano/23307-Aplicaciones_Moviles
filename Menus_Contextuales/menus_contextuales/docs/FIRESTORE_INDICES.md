# Índices de Firestore Requeridos

## Descripción
Para que la aplicación funcione correctamente sin errores de índices, necesitas crear los siguientes índices compuestos en Firestore.

## Cómo crear los índices

### Opción 1: Usar Firebase Console (Recomendado)
1. Ve a Firebase Console: https://console.firebase.google.com/
2. Selecciona tu proyecto
3. Ve a "Firestore Database"
4. Haz clic en la pestaña "Índices"
5. Haz clic en "Crear índice"
6. Configura cada índice según las especificaciones a continuación

### Opción 2: Usar Firebase CLI
```bash
# Instalar Firebase CLI si no lo tienes
npm install -g firebase-tools

# Inicializar en tu proyecto
firebase init firestore

# Editar firestore.indexes.json con los índices
# Luego ejecutar:
firebase deploy --only firestore:indexes
```

## Índices Requeridos

### 1. Índice para Orders (Pedidos)
**Colección**: `orders`
**Campos**:
- `userId` (Ascending)
- `status` (Ascending)
- `createdAt` (Descending)

**Propósito**: Filtrar pedidos por usuario y estado, ordenados por fecha

### 2. Índice para Orders por Usuario y Fecha
**Colección**: `orders`
**Campos**:
- `userId` (Ascending)
- `createdAt` (Descending)

**Propósito**: Obtener todos los pedidos de un usuario ordenados por fecha

### 3. Índice para Invoices (Facturas)
**Colección**: `invoices`
**Campos**:
- `userId` (Ascending)
- `status` (Ascending)
- `createdAt` (Descending)

**Propósito**: Filtrar facturas por usuario y estado, ordenadas por fecha

### 4. Índice para Invoices por Usuario y Fecha
**Colección**: `invoices`
**Campos**:
- `userId` (Ascending)
- `createdAt` (Descending)

**Propósito**: Obtener todas las facturas de un usuario ordenadas por fecha

### 5. Índice para Orders por Estado (Admin)
**Colección**: `orders`
**Campos**:
- `status` (Ascending)
- `createdAt` (Descending)

**Propósito**: Filtrar todos los pedidos por estado (para administradores)

### 6. Índice para Invoices por Estado (Admin)
**Colección**: `invoices`
**Campos**:
- `status` (Ascending)
- `createdAt` (Descending)

**Propósito**: Filtrar todas las facturas por estado (para administradores)

## Configuración JSON para Firebase CLI

Si usas Firebase CLI, crea o actualiza el archivo `firestore.indexes.json`:

```json
{
  "indexes": [
    {
      "collectionGroup": "orders",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "userId",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "status",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "createdAt",
          "order": "DESCENDING"
        }
      ]
    },
    {
      "collectionGroup": "orders",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "userId",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "createdAt",
          "order": "DESCENDING"
        }
      ]
    },
    {
      "collectionGroup": "invoices",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "userId",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "status",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "createdAt",
          "order": "DESCENDING"
        }
      ]
    },
    {
      "collectionGroup": "invoices",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "userId",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "createdAt",
          "order": "DESCENDING"
        }
      ]
    },
    {
      "collectionGroup": "orders",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "status",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "createdAt",
          "order": "DESCENDING"
        }
      ]
    },
    {
      "collectionGroup": "invoices",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "status",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "createdAt",
          "order": "DESCENDING"
        }
      ]
    }
  ]
}
```

## Verificación

Después de crear los índices:
1. Espera a que se construyan (puede tomar varios minutos)
2. Prueba la aplicación filtrando pedidos y facturas
3. Verifica que no aparezcan errores de índices en la consola

## Notas Importantes

- Los índices pueden tardar varios minutos en construirse
- Si ya tienes datos en Firestore, la construcción puede ser más lenta
- Los índices consumen espacio de almacenamiento adicional
- Es recomendable crear estos índices antes de usar la aplicación en producción

## Troubleshooting

Si sigues teniendo errores:
1. Verifica que los nombres de los campos coincidan exactamente
2. Asegúrate de que los índices estén en estado "Enabled"
3. Revisa la consola de Firebase para ver mensajes de error
4. Reinicia la aplicación después de crear los índices
