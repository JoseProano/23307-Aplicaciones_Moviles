import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../lib/firebase_options.dart';
import '../lib/models/user_model.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  print('🔧 REPARANDO USUARIO ADMINISTRADOR...\n');
  
  await repairAdminUser();
  
  print('🏁 PROCESO TERMINADO.');
}

Future<void> repairAdminUser() async {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  
  const adminEmail = 'admin@tienda-local.com';
  const adminPassword = 'Admin123!';
  
  try {
    print('📋 PASO 1: Verificando usuario en Authentication...');
    
    // Verificar si el usuario existe en Auth
    User? adminUser;
    try {
      final credential = await auth.signInWithEmailAndPassword(
        email: adminEmail,
        password: adminPassword,
      );
      adminUser = credential.user;
      print('✅ Usuario encontrado en Authentication');
      print('   UID: ${adminUser?.uid}');
    } catch (e) {
      print('❌ Error al verificar credenciales: $e');
      print('   Intentando resetear contraseña...');
      
      // Si existe pero la contraseña no funciona, resetear
      try {
        await auth.sendPasswordResetEmail(email: adminEmail);
        print('📧 Email de reset enviado a $adminEmail');
        print('   Revisa tu email y establece la contraseña como: $adminPassword');
        return;
      } catch (resetError) {
        print('❌ No se pudo enviar reset: $resetError');
        print('   El usuario puede no existir en Authentication');
        return;
      }
    }
    
    if (adminUser != null) {
      print('\n📋 PASO 2: Sincronizando con Firestore...');
      
      // Buscar documentos existentes del admin
      final querySnapshot = await firestore
          .collection('users')
          .where('email', isEqualTo: adminEmail)
          .get();
      
      // Eliminar documentos existentes con email admin
      for (final doc in querySnapshot.docs) {
        if (doc.id != adminUser.uid) {
          print('🗑️ Eliminando documento incorrecto: ${doc.id}');
          await doc.reference.delete();
        }
      }
      
      // Crear/actualizar el documento correcto
      final correctDocRef = firestore.collection('users').doc(adminUser.uid);
      
      final adminUserModel = UserModel(
        uid: adminUser.uid,
        email: adminEmail,
        name: 'Administrador Principal',
        phone: '+593 99 999 9999',
        address: 'Oficina Principal - Ecuador',
        createdAt: DateTime.now(),
      );
      
      await correctDocRef.set(adminUserModel.toJson());
      print('✅ Documento correcto creado/actualizado');
      print('   ID del documento: ${adminUser.uid}');
      
      // Cerrar sesión
      await auth.signOut();
      print('✅ Sesión cerrada');
      
      print('\n🎉 ¡REPARACIÓN COMPLETADA!');
      print('📧 Email: $adminEmail');
      print('🔑 Contraseña: $adminPassword');
      print('🆔 UID: ${adminUser.uid}');
      print('\n✅ Ahora puedes iniciar sesión como administrador');
    }
    
  } catch (e) {
    print('❌ Error durante la reparación: $e');
  }
}
