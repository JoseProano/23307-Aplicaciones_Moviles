import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class QuickAdminCreator {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  static const String adminEmail = 'admin@tienda-local.com';
  static const String adminPassword = 'Admin123!';

  /// Crear administrador de forma simple y directa
  static Future<bool> createAdminNow() async {
    try {
      print('🚀 Creando administrador...');
      
      // Paso 1: Crear en Firebase Auth
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: adminEmail,
        password: adminPassword,
      );

      if (result.user != null) {
        print('✅ Usuario creado en Firebase Auth');
        
        // Paso 2: Crear documento en Firestore
        final adminUser = UserModel(
          uid: result.user!.uid,
          email: adminEmail,
          name: 'Administrador Principal',
          phone: '+593 99 999 9999',
          address: 'Oficina Principal - Ecuador',
          createdAt: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(result.user!.uid)
            .set(adminUser.toJson());

        print('✅ Documento creado en Firestore');
        
        // Paso 3: Cerrar sesión del admin
        await _auth.signOut();
        print('✅ Sesión de admin cerrada');
        
        print('\n🎉 ¡ADMINISTRADOR CREADO EXITOSAMENTE!');
        print('📧 Email: $adminEmail');
        print('🔑 Contraseña: $adminPassword');
        
        return true;
      }
      
      return false;
    } catch (e) {
      if (e.toString().contains('email-already-in-use')) {
        print('⚠️ El email ya está en uso, intentando reparar...');
        return await repairAdminAccount();
      } else {
        print('❌ Error creando administrador: $e');
        return false;
      }
    }
  }

  /// Reparar completamente la cuenta de administrador
  static Future<bool> repairAdminAccount() async {
    try {
      print('🛠️ INICIANDO REPARACIÓN COMPLETA DE CUENTA ADMINISTRADOR\n');
      
      // Paso 1: Eliminar cualquier sesión activa
      await _auth.signOut();
      print('🔄 Sesión cerrada\n');
      
      // Paso 2: Buscar y eliminar usuario existente en Firestore si es necesario
      print('🔍 Buscando documentos existentes en Firestore...');
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: adminEmail)
          .get();
      
      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
        print('🗑️ Documento existente eliminado: ${doc.id}');
      }
      
      // Paso 3: Verificar si el usuario existe en Auth
      bool userExistsInAuth = false;
      try {
        final signInMethods = await _auth.fetchSignInMethodsForEmail(adminEmail);
        userExistsInAuth = signInMethods.isNotEmpty;
        print('📧 Usuario en Auth: ${userExistsInAuth ? "SÍ existe" : "NO existe"}');
      } catch (e) {
        print('📧 Usuario en Auth: NO existe (error al verificar)');
        userExistsInAuth = false;
      }
      
      String uid;
      
      if (userExistsInAuth) {
        // Paso 4a: Si existe en Auth, obtener el UID
        print('🔑 Haciendo login para obtener UID...');
        try {
          final credential = await _auth.signInWithEmailAndPassword(
            email: adminEmail,
            password: adminPassword,
          );
          uid = credential.user!.uid;
          print('✅ Login exitoso, UID obtenido: $uid');
        } catch (e) {
          print('❌ Error en login: $e');
          print('🔧 Intentando recrear usuario...');
          // Si no puede hacer login, eliminar y recrear
          return await _recreateAdminUser();
        }
      } else {
        // Paso 4b: Si no existe en Auth, crearlo
        print('➕ Creando nuevo usuario en Auth...');
        final credential = await _auth.createUserWithEmailAndPassword(
          email: adminEmail,
          password: adminPassword,
        );
        uid = credential.user!.uid;
        print('✅ Usuario creado en Auth, UID: $uid');
      }
      
      // Paso 5: Crear documento en Firestore
      print('📄 Creando documento en Firestore...');
      final adminUser = UserModel(
        uid: uid,
        email: adminEmail,
        name: 'Administrador Principal',
        phone: '+593 99 999 9999',
        address: 'Oficina Principal - Ecuador',
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(uid)
          .set(adminUser.toJson());
      
      print('✅ Documento creado en Firestore');
      
      // Paso 6: Cerrar sesión
      await _auth.signOut();
      print('🔄 Sesión cerrada');
      
      // Paso 7: Verificación final
      print('\n🔍 Verificación final...');
      final finalCredential = await _auth.signInWithEmailAndPassword(
        email: adminEmail,
        password: adminPassword,
      );
      
      final finalDoc = await _firestore
          .collection('users')
          .doc(finalCredential.user!.uid)
          .get();
      
      await _auth.signOut();
      
      if (finalDoc.exists) {
        print('🎉 ¡REPARACIÓN COMPLETADA EXITOSAMENTE!');
        print('📧 Email: $adminEmail');
        print('🔑 Contraseña: $adminPassword');
        print('🆔 UID: ${finalCredential.user!.uid}');
        return true;
      } else {
        print('❌ La verificación final falló');
        return false;
      }
      
    } catch (e) {
      print('❌ Error en reparación: $e');
      return false;
    }
  }
  
  /// Recrear completamente el usuario administrador
  static Future<bool> _recreateAdminUser() async {
    try {
      print('🔄 Recreando usuario administrador...');
      
      // Crear nuevo usuario
      final credential = await _auth.createUserWithEmailAndPassword(
        email: adminEmail,
        password: adminPassword,
      );
      
      // Crear documento
      final adminUser = UserModel(
        uid: credential.user!.uid,
        email: adminEmail,
        name: 'Administrador Principal',
        phone: '+593 99 999 9999',
        address: 'Oficina Principal - Ecuador',
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(adminUser.toJson());
      
      await _auth.signOut();
      
      print('✅ Usuario recreado exitosamente');
      return true;
    } catch (e) {
      print('❌ Error recreando usuario: $e');
      return false;
    }
  }

  /// Widget para usar en la pantalla de administración
  static Widget buildCreateAdminButton() {
    return ElevatedButton.icon(
      onPressed: () async {
        await repairAdminAccount();
      },
      icon: const Icon(Icons.admin_panel_settings),
      label: const Text('Reparar Administrador'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }
}
