import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'admin_setup_helper.dart';

class AdminAuthHelper {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Diagnóstico completo del usuario administrador
  static Future<Map<String, dynamic>> diagnoseAdminAccount() async {
    final result = <String, dynamic>{
      'authExists': false,
      'firestoreExists': false,
      'canAuthenticate': false,
      'errors': <String>[],
      'suggestions': <String>[],
    };

    try {
      // 1. Verificar si existe en Firebase Auth
      print('🔍 Verificando cuenta en Firebase Auth...');
      try {
        final methods = await _auth.fetchSignInMethodsForEmail(AdminSetupHelper.adminEmail);
        result['authExists'] = methods.isNotEmpty;
        if (methods.isNotEmpty) {
          print('✅ Cuenta encontrada en Firebase Auth');
          print('   Métodos de inicio de sesión: ${methods.join(", ")}');
        } else {
          print('❌ Cuenta NO encontrada en Firebase Auth');
          result['suggestions'].add('Crear cuenta de administrador con AdminSetupHelper.createAdminUser()');
        }
      } catch (e) {
        print('❌ Error verificando Firebase Auth: $e');
        result['errors'].add('Error verificando Firebase Auth: $e');
      }

      // 2. Verificar si existe en Firestore
      print('\n🔍 Verificando documento en Firestore...');
      try {
        final querySnapshot = await _firestore
            .collection('users')
            .where('email', isEqualTo: AdminSetupHelper.adminEmail)
            .limit(1)
            .get();

        result['firestoreExists'] = querySnapshot.docs.isNotEmpty;
        if (querySnapshot.docs.isNotEmpty) {
          print('✅ Documento encontrado en Firestore');
          final userData = querySnapshot.docs.first.data();
          print('   UID: ${querySnapshot.docs.first.id}');
          print('   Nombre: ${userData['name']}');
          print('   Teléfono: ${userData['phone']}');
        } else {
          print('❌ Documento NO encontrado en Firestore');
          result['suggestions'].add('Crear documento de Firestore');
        }
      } catch (e) {
        print('❌ Error verificando Firestore: $e');
        result['errors'].add('Error verificando Firestore: $e');
      }

      // 3. Intentar autenticación
      if (result['authExists'] == true) {
        print('\n🔍 Probando autenticación...');
        try {
          final userCredential = await _auth.signInWithEmailAndPassword(
            email: AdminSetupHelper.adminEmail,
            password: AdminSetupHelper.adminPassword,
          );
          
          if (userCredential.user != null) {
            result['canAuthenticate'] = true;
            print('✅ Autenticación exitosa');
            await _auth.signOut();
            print('   Sesión cerrada correctamente');
          }
        } catch (e) {
          print('❌ Error en autenticación: $e');
          result['errors'].add('Error en autenticación: $e');
          
          if (e.toString().contains('wrong-password')) {
            result['suggestions'].add('La contraseña puede haber cambiado. Usar resetear contraseña.');
          } else if (e.toString().contains('user-not-found')) {
            result['suggestions'].add('La cuenta fue eliminada. Recrear con createAdminUser()');
          } else if (e.toString().contains('too-many-requests')) {
            result['suggestions'].add('Demasiados intentos fallidos. Esperar antes de reintentar.');
          }
        }
      }

      return result;
    } catch (e) {
      print('❌ Error general en diagnóstico: $e');
      result['errors'].add('Error general: $e');
      return result;
    }
  }

  /// Reparar automáticamente la cuenta de administrador
  static Future<bool> repairAdminAccount() async {
    print('🛠️ INICIANDO REPARACIÓN DE CUENTA ADMINISTRADOR\n');
    
    final diagnosis = await diagnoseAdminAccount();
    
    print('\n📋 RESUMEN DEL DIAGNÓSTICO:');
    print('Auth existe: ${diagnosis['authExists']}');
    print('Firestore existe: ${diagnosis['firestoreExists']}');
    print('Puede autenticar: ${diagnosis['canAuthenticate']}');
    
    if (diagnosis['errors'].isNotEmpty) {
      print('\n❌ Errores encontrados:');
      for (final error in diagnosis['errors']) {
        print('   - $error');
      }
    }

    // Si todo está bien, no hay nada que reparar
    if (diagnosis['authExists'] == true && 
        diagnosis['firestoreExists'] == true && 
        diagnosis['canAuthenticate'] == true) {
      print('\n✅ La cuenta de administrador está funcionando correctamente');
      return true;
    }

    print('\n🛠️ Iniciando reparaciones...');

    try {
      // Reparación 1: Crear cuenta si no existe
      if (diagnosis['authExists'] == false) {
        print('\n1️⃣ Creando cuenta en Firebase Auth...');
        final success = await AdminSetupHelper.createAdminUser();
        if (!success) {
          print('❌ No se pudo crear la cuenta de administrador');
          return false;
        }
      }

      // Reparación 2: Crear documento en Firestore si no existe
      if (diagnosis['firestoreExists'] == false) {
        print('\n2️⃣ Creando documento en Firestore...');
        await _ensureFirestoreDocument();
      }

      // Verificación final
      print('\n🔍 Verificación final...');
      final finalDiagnosis = await diagnoseAdminAccount();
      
      if (finalDiagnosis['canAuthenticate'] == true) {
        print('\n✅ REPARACIÓN COMPLETADA EXITOSAMENTE');
        print('El administrador puede ahora autenticarse correctamente');
        return true;
      } else {
        print('\n❌ La reparación no fue completamente exitosa');
        print('Errores restantes:');
        for (final error in finalDiagnosis['errors']) {
          print('   - $error');
        }
        return false;
      }
    } catch (e) {
      print('❌ Error durante la reparación: $e');
      return false;
    }
  }

  /// Asegurar que el documento existe en Firestore
  static Future<void> _ensureFirestoreDocument() async {
    try {
      // Buscar por email
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: AdminSetupHelper.adminEmail)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        // Intentar obtener el UID desde Firebase Auth
        User? adminUser;
        try {
          final userCredential = await _auth.signInWithEmailAndPassword(
            email: AdminSetupHelper.adminEmail,
            password: AdminSetupHelper.adminPassword,
          );
          adminUser = userCredential.user;
          await _auth.signOut();
        } catch (e) {
          print('⚠️ No se pudo obtener UID desde Auth: $e');
        }

        if (adminUser != null) {
          // Crear documento con UID correcto
          final adminUserModel = UserModel(
            uid: adminUser.uid,
            email: AdminSetupHelper.adminEmail,
            name: 'Administrador Principal',
            phone: '+34 600 123 456',
            address: 'Calle Principal 123, Local 1',
            createdAt: DateTime.now(),
          );

          await _firestore
              .collection('users')
              .doc(adminUser.uid)
              .set(adminUserModel.toJson());
          
          print('✅ Documento de Firestore creado correctamente');
        } else {
          print('❌ No se pudo crear el documento: UID no disponible');
        }
      } else {
        print('✅ El documento ya existe en Firestore');
      }
    } catch (e) {
      print('❌ Error asegurando documento de Firestore: $e');
      rethrow;
    }
  }

  /// Mostrar información de ayuda para solucionar problemas
  static void showTroubleshootingHelp() {
    print('\n🆘 GUÍA DE SOLUCIÓN DE PROBLEMAS\n');
    print('══════════════════════════════════════════════════════════════');
    print('1. DIAGNÓSTICO AUTOMÁTICO:');
    print('   AdminAuthHelper.diagnoseAdminAccount()');
    print('');
    print('2. REPARACIÓN AUTOMÁTICA:');
    print('   AdminAuthHelper.repairAdminAccount()');
    print('');
    print('3. CREAR USUARIO DESDE CERO:');
    print('   AdminSetupHelper.createAdminUser()');
    print('');
    print('4. VERIFICAR CREDENCIALES:');
    print('   AdminSetupHelper.verifyAdminCredentials()');
    print('');
    print('5. RESETEAR CONTRASEÑA:');
    print('   AdminSetupHelper.resetAdminPassword()');
    print('');
    print('6. CREDENCIALES POR DEFECTO:');
    print('   Email: ${AdminSetupHelper.adminEmail}');
    print('   Contraseña: ${AdminSetupHelper.adminPassword}');
    print('══════════════════════════════════════════════════════════════');
  }
}
