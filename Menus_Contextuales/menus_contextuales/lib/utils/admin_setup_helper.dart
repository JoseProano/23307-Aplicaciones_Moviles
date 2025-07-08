import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AdminSetupHelper {
  static const String adminEmail = 'admin@tienda-local.com';
  static const String adminPassword = 'Admin123!';
  
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Crear el usuario administrador por defecto
  /// Este método debe ejecutarse una sola vez durante la configuración inicial
  static Future<bool> createAdminUser() async {
    try {
      // Guardar el usuario actual si está autenticado
      final currentUser = _auth.currentUser;
      
      // Verificar si el usuario administrador ya existe
      final existingUser = await _checkIfAdminExists();
      if (existingUser != null) {
        print('✅ Usuario administrador ya existe: ${existingUser.email}');
        // Verificar si también existe en Firestore
        await _ensureAdminInFirestore(existingUser.uid);
        return true;
      }

      print('🔄 Creando usuario administrador...');
      
      // Crear cuenta de Firebase Auth
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: adminEmail,
        password: adminPassword,
      );

      if (userCredential.user != null) {
        // Crear documento del usuario en Firestore
        await _createAdminUserDocument(userCredential.user!.uid);

        print('✅ Usuario administrador creado exitosamente!');
        print('📧 Email: $adminEmail');
        print('🔑 Contraseña: $adminPassword');
        
        // Restaurar el usuario anterior si existía
        if (currentUser != null) {
          try {
            await _auth.signOut();
            // Aquí el usuario anterior deberá autenticarse nuevamente
            print('ℹ️ Se cerró la sesión del administrador para restaurar el usuario anterior');
          } catch (e) {
            print('⚠️ No se pudo restaurar la sesión anterior: $e');
          }
        } else {
          // Si no había usuario anterior, cerrar sesión del admin
          await _auth.signOut();
        }
        
        // Cerrar sesión después de crear el admin
        await _auth.signOut();
        
        return true;
      } else {
        print('❌ Error: No se pudo crear la cuenta de Firebase Auth');
        return false;
      }
    } catch (e) {
      if (e.toString().contains('email-already-in-use')) {
        print('⚠️  La cuenta de administrador ya existe en Firebase Auth');
        
        // Intentar crear el documento en Firestore si no existe
        try {
          final adminCredential = await _auth.signInWithEmailAndPassword(
            email: adminEmail,
            password: adminPassword,
          );
          
          if (adminCredential.user != null) {
            final userDoc = await _firestore
                .collection('users')
                .doc(adminCredential.user!.uid)
                .get();
            
            if (!userDoc.exists) {
              final adminUser = UserModel(
                uid: adminCredential.user!.uid,
                email: adminEmail,
                name: 'Administrador Principal',
                phone: '+34 600 123 456',
                address: 'Calle Principal 123, Local 1',
                createdAt: DateTime.now(),
              );

              await _firestore
                  .collection('users')
                  .doc(adminCredential.user!.uid)
                  .set(adminUser.toJson());
              
              print('✅ Documento de usuario administrador creado en Firestore');
            }
            
            await _auth.signOut();
            return true;
          }
        } catch (signInError) {
          print('❌ Error al verificar/crear documento de administrador: $signInError');
        }
        
        return true; // La cuenta ya existe, consideramos que es exitoso
      } else {
        print('❌ Error al crear usuario administrador: $e');
        return false;
      }
    }
  }

  /// Verificar si el usuario administrador ya existe
  static Future<UserModel?> _checkIfAdminExists() async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: adminEmail)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return UserModel.fromJson({
          'uid': querySnapshot.docs.first.id,
          ...querySnapshot.docs.first.data()
        });
      }
      return null;
    } catch (e) {
      print('Error al verificar usuario administrador: $e');
      return null;
    }
  }

  /// Asegurar que el administrador existe en Firestore
  static Future<void> _ensureAdminInFirestore(String uid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      
      if (!userDoc.exists) {
        await _createAdminUserDocument(uid);
        print('✅ Documento de administrador creado en Firestore');
      } else {
        print('✅ Documento de administrador ya existe en Firestore');
      }
    } catch (e) {
      print('⚠️ Error al verificar documento en Firestore: $e');
    }
  }

  /// Crear documento del usuario administrador en Firestore
  static Future<void> _createAdminUserDocument(String uid) async {
    final adminUser = UserModel(
      uid: uid,
      email: adminEmail,
      name: 'Administrador Principal',
      phone: '+34 600 123 456',
      address: 'Calle Principal 123, Local 1',
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection('users')
        .doc(uid)
        .set(adminUser.toJson());
  }

  /// Resetear contraseña del administrador (útil para recuperación)
  static Future<bool> resetAdminPassword() async {
    try {
      await _auth.sendPasswordResetEmail(email: adminEmail);
      print('✅ Email de recuperación enviado a $adminEmail');
      return true;
    } catch (e) {
      print('❌ Error al enviar email de recuperación: $e');
      return false;
    }
  }

  /// Verificar credenciales del administrador
  static Future<bool> verifyAdminCredentials() async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: adminEmail,
        password: adminPassword,
      );
      
      if (userCredential.user != null) {
        await _auth.signOut();
        print('✅ Credenciales de administrador verificadas correctamente');
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error al verificar credenciales de administrador: $e');
      return false;
    }
  }

  /// Actualizar información del administrador
  static Future<bool> updateAdminInfo({
    String? name,
    String? phone,
    String? address,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: adminEmail)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final updateData = <String, dynamic>{
          'updatedAt': DateTime.now().toIso8601String(),
        };
        
        if (name != null) updateData['name'] = name;
        if (phone != null) updateData['phone'] = phone;
        if (address != null) updateData['address'] = address;

        await _firestore
            .collection('users')
            .doc(querySnapshot.docs.first.id)
            .update(updateData);
        
        print('✅ Información de administrador actualizada');
        return true;
      } else {
        print('❌ Usuario administrador no encontrado');
        return false;
      }
    } catch (e) {
      print('❌ Error al actualizar información de administrador: $e');
      return false;
    }
  }

  /// Mostrar información del administrador
  static void showAdminCredentials() {
    print('\n🔐 CREDENCIALES DEL ADMINISTRADOR 🔐');
    print('══════════════════════════════════════');
    print('📧 Email: $adminEmail');
    print('🔑 Contraseña: $adminPassword');
    print('👤 Nombre: Administrador Principal');
    print('📞 Teléfono: +34 600 123 456');
    print('🏠 Dirección: Calle Principal 123, Local 1');
    print('🎭 Rol: admin');
    print('══════════════════════════════════════');
    print('⚠️  IMPORTANTE: Cambia estas credenciales en producción\n');
  }
}
