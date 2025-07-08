# Índices Requeridos en Firestore

Este documento lista todos los índices compuestos que deben crearse en Firestore para que la aplicación funcione correctamente.

## Índices para la colección 'orders'

### 1. Índice para consulta de órdenes por usuario
**Campos**: `userId` (Ascending), `createdAt` (Descending)
**Enlace directo para crear**:
```
https://console.firebase.google.com/project/LOCAL_PROJECT_ID/firestore/indexes?create_composite=ClBwcm9qZWN0cy9MT0NBTF9QUk9KRUNUX0lEL2RhdGFiYXNlcy8oZGVmYXVsdCkvY29sbGVjdGlvbkdyb3Vwcy9vcmRlcnMvaW5kZXhlcy9fEAEaCgoGdXNlcklkEAEaDAoIY3JlYXRlZEF0EAIYAQ
```

### 2. Índice para consulta de órdenes por usuario y estado
**Campos**: `userId` (Ascending), `status` (Ascending), `createdAt` (Descending)
**Enlace directo para crear**:
```
https://console.firebase.google.com/project/LOCAL_PROJECT_ID/firestore/indexes?create_composite=Clpwcm9qZWN0cy9MT0NBTF9QUk9KRUNUX0lEL2RhdGFiYXNlcy8oZGVmYXVsdCkvY29sbGVjdGlvbkdyb3Vwcy9vcmRlcnMvaW5kZXhlcy9fEAEaCgoGdXNlcklkEAEaCwoGc3RhdHVzEAEaDAoIY3JlYXRlZEF0EAIYAQ
```

## Índices para la colección 'products'

### 1. Índice para productos activos por categoría
**Campos**: `isActive` (Ascending), `categoryId` (Ascending)
**Enlace directo para crear**:
```
https://console.firebase.google.com/project/LOCAL_PROJECT_ID/firestore/indexes?create_composite=Clpwcm9qZWN0cy9MT0NBTF9QUk9KRUNUX0lEL2RhdGFiYXNlcy8oZGVmYXVsdCkvY29sbGVjdGlvbkdyb3Vwcy9wcm9kdWN0cy9pbmRleGVzL18QARoLCghpc0FjdGl2ZRABEL8KCgpjYXRlZ29yeUlkEAEYAQ
```

## Instrucciones para crear los índices

1. Reemplaza `LOCAL_PROJECT_ID` en los enlaces con tu ID real del proyecto Firebase
2. Accede a cada enlace desde una cuenta con permisos de administrador
3. Confirma la creación del índice
4. Espera a que el índice se complete (puede tomar varios minutos)

## Verificar índices existentes

Para ver todos los índices existentes en tu proyecto:
```
https://console.firebase.google.com/project/LOCAL_PROJECT_ID/firestore/indexes
```

## Comandos alternativos con Firebase CLI

Si prefieres usar Firebase CLI, puedes crear un archivo `firestore.indexes.json`:

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
      "collectionGroup": "products",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "isActive",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "categoryId",
          "order": "ASCENDING"
        }
      ]
    }
  ]
}
```

Luego ejecutar:
```bash
firebase deploy --only firestore:indexes
```
