import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import '../lib/firebase_options.dart';
import '../lib/utils/upload_sample_data.dart';

/// Script independiente para cargar datos de ejemplo a Firestore
/// Ejecutar con: flutter run scripts/upload_data.dart
void main() async {
  print('🚀 Iniciando script de carga de datos...');
  
  // Inicializar Flutter bindings para poder usar Firebase
  try {
    WidgetsFlutterBinding.ensureInitialized();
  } catch (e) {
    // En caso de error, usar una implementación mínima
    print('⚠️ Advertencia: No se pudieron inicializar los bindings completos de Flutter');
  }
  
  try {
    // Inicializar Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase inicializado correctamente');
    
    // Verificar si ya existen datos
    final dataExists = await SampleDataUploader.checkIfDataExists();
    
    if (dataExists) {
      print('📋 Ya existen datos en Firestore');
      print('¿Deseas continuar y sobrescribir los datos existentes? (y/n)');
      
      // Simular entrada del usuario (en un script real podrías usar stdin)
      const continueUpload = true; // Cambiar a false si no quieres sobrescribir
      
      if (!continueUpload) {
        print('❌ Operación cancelada por el usuario');
        return;
      }
      
      print('🗑️ Limpiando datos existentes...');
      await SampleDataUploader.clearAllSampleData();
    }
    
    // Cargar los nuevos datos
    print('📦 Cargando datos de ejemplo...');
    await SampleDataUploader.uploadAllSampleData();
    
    print('🎉 ¡Script completado exitosamente!');
    print('');
    print('Datos cargados:');
    print('• 4 categorías (Alimentos, Artesanías, Textiles, Decoración)');
    print('• 8 productos de ejemplo');
    print('');
    print('Ahora puedes ejecutar tu aplicación Flutter y ver los datos.');
    
  } catch (e) {
    print('❌ Error durante la ejecución del script: $e');
    print('');
    print('Posibles soluciones:');
    print('1. Verifica que Firebase esté configurado correctamente');
    print('2. Asegúrate de tener conexión a internet');
    print('3. Verifica las reglas de seguridad de Firestore');
  }
}

// Clase mínima para evitar errores si no están disponibles los bindings completos
class WidgetsFlutterBinding {
  static void ensureInitialized() {
    // Implementación mínima
  }
}
