import 'package:cloud_firestore/cloud_firestore.dart';
import 'upload_sample_data.dart';

class DataMigrationHelper {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Migra datos con formato incorrecto (Timestamp) a formato correcto (String)
  static Future<void> migrateTimestampData() async {
    try {
      print('🔄 Iniciando migración de datos...');
      
      // Verificar si hay datos con formato incorrecto
      final hasIncorrectData = await _checkForTimestampData();
      
      if (hasIncorrectData) {
        print('⚠️ Se detectaron datos con formato Timestamp incorrecto');
        print('🗑️ Limpiando datos con formato incorrecto...');
        
        // Limpiar todos los datos
        await SampleDataUploader.clearAllSampleData();
        
        print('📦 Cargando datos con formato correcto...');
        
        // Cargar datos corregidos
        await SampleDataUploader.uploadAllSampleData();
        
        print('✅ Migración completada exitosamente!');
      } else {
        print('✅ Los datos ya tienen el formato correcto');
      }
      
    } catch (e) {
      print('❌ Error durante la migración: $e');
      rethrow;
    }
  }
  
  /// Verifica si hay datos con formato Timestamp incorrecto
  static Future<bool> _checkForTimestampData() async {
    try {
      // Verificar categorías
      final categoriesSnapshot = await _firestore.collection('categories').limit(1).get();
      if (categoriesSnapshot.docs.isNotEmpty) {
        final data = categoriesSnapshot.docs.first.data();
        if (data['createdAt'] is Timestamp) {
          return true; // Datos con formato incorrecto
        }
      }
      
      // Verificar productos
      final productsSnapshot = await _firestore.collection('products').limit(1).get();
      if (productsSnapshot.docs.isNotEmpty) {
        final data = productsSnapshot.docs.first.data();
        if (data['createdAt'] is Timestamp) {
          return true; // Datos con formato incorrecto
        }
      }
      
      return false; // Datos con formato correcto
    } catch (e) {
      print('⚠️ Error al verificar formato de datos: $e');
      return false;
    }
  }
  
  /// Ejecuta migración automática si es necesario
  static Future<void> autoMigrateIfNeeded() async {
    try {
      final needsMigration = await _checkForTimestampData();
      if (needsMigration) {
        print('🔄 Auto-migración iniciada...');
        await migrateTimestampData();
      }
    } catch (e) {
      print('⚠️ Error en auto-migración: $e');
    }
  }
}
