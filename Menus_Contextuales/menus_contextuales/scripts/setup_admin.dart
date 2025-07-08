import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../lib/firebase_options.dart';
import '../lib/utils/admin_auth_helper.dart';
import '../lib/utils/admin_setup_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  print('🚀 INICIANDO CONFIGURACIÓN DE ADMINISTRADOR...\n');
  
  try {
    // Paso 1: Diagnóstico completo
    print('📊 EJECUTANDO DIAGNÓSTICO...');
    final diagnosis = await AdminAuthHelper.diagnoseAdminAccount();
    
    print('\n📋 RESULTADO DEL DIAGNÓSTICO:');
    print('Auth existe: ${diagnosis['authExists']}');
    print('Firestore existe: ${diagnosis['firestoreExists']}');
    print('Puede autenticar: ${diagnosis['canAuthenticate']}');
    
    if (diagnosis['errors'].isNotEmpty) {
      print('\n❌ ERRORES ENCONTRADOS:');
      for (final error in diagnosis['errors']) {
        print('   • $error');
      }
    }
    
    // Paso 2: Reparación automática
    print('\n🛠️ INICIANDO REPARACIÓN AUTOMÁTICA...');
    final repaired = await AdminAuthHelper.repairAdminAccount();
    
    if (repaired) {
      print('\n✅ ¡REPARACIÓN COMPLETADA EXITOSAMENTE!');
      print('\n🔐 CREDENCIALES DEL ADMINISTRADOR:');
      print('📧 Email: ${AdminSetupHelper.adminEmail}');
      print('🔑 Contraseña: ${AdminSetupHelper.adminPassword}');
      print('\n🎉 ¡Ya puedes iniciar sesión como administrador!');
    } else {
      print('\n❌ No se pudo completar la reparación automática.');
      print('Ejecutando diagnóstico final...');
      
      final finalDiagnosis = await AdminAuthHelper.diagnoseAdminAccount();
      print('\nEstado final:');
      print('Auth existe: ${finalDiagnosis['authExists']}');
      print('Firestore existe: ${finalDiagnosis['firestoreExists']}');
      print('Puede autenticar: ${finalDiagnosis['canAuthenticate']}');
    }
    
  } catch (e) {
    print('❌ ERROR DURANTE LA CONFIGURACIÓN: $e');
  }
  
  print('\n🏁 CONFIGURACIÓN TERMINADA.');
}
