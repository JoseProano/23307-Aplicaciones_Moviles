import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  // Inicializar Firebase Auth y Firestore
  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;
  
  const adminEmail = 'admin@tienda-local.com';
  const adminPassword = 'Admin123!';
  
  print('🚀 CREANDO USUARIO ADMINISTRADOR...\n');
  
  try {
    // Paso 1: Crear usuario en Firebase Auth
    print('📧 Creando cuenta en Firebase Auth...');
    final UserCredential userCredential = await auth.createUserWithEmailAndPassword(
      email: adminEmail,
      password: adminPassword,
    );
    
    if (userCredential.user != null) {
      print('✅ Cuenta de Auth creada: ${userCredential.user!.uid}');
      
      // Paso 2: Crear documento en Firestore
      print('📄 Creando documento en Firestore...');
      await firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': adminEmail,
        'name': 'Administrador Principal',
        'phone': '+593 999 123 456',
        'address': 'Oficina Central - Ecuador',
        'createdAt': DateTime.now().toIso8601String(),
        'isAdmin': true, // Campo especial para identificar administradores
      });
      
      print('✅ Documento de Firestore creado');
      
      // Paso 3: Cerrar sesión para no interferir
      await auth.signOut();
      print('🔓 Sesión cerrada');
      
      print('\n🎉 ¡USUARIO ADMINISTRADOR CREADO EXITOSAMENTE!');
      print('═══════════════════════════════════════════════');
      print('📧 Email: $adminEmail');
      print('🔑 Contraseña: $adminPassword');
      print('👤 Nombre: Administrador Principal');
      print('🆔 UID: ${userCredential.user!.uid}');
      print('═══════════════════════════════════════════════');
      print('\n✨ Ahora puedes iniciar sesión como administrador en tu app!');
      
    } else {
      print('❌ Error: No se pudo crear la cuenta de Firebase Auth');
    }
    
  } catch (e) {
    if (e.toString().contains('email-already-in-use')) {
      print('⚠️ La cuenta ya existe en Firebase Auth');
      print('🔍 Intentando verificar si existe en Firestore...');
      
      try {
        // Intentar iniciar sesión para obtener el UID
        final UserCredential signInCredential = await auth.signInWithEmailAndPassword(
          email: adminEmail,
          password: adminPassword,
        );
        
        if (signInCredential.user != null) {
          final uid = signInCredential.user!.uid;
          print('✅ Login exitoso con UID: $uid');
          
          // Verificar si existe en Firestore
          final userDoc = await firestore.collection('users').doc(uid).get();
          
          if (!userDoc.exists) {
            print('📄 Creando documento faltante en Firestore...');
            await firestore.collection('users').doc(uid).set({
              'uid': uid,
              'email': adminEmail,
              'name': 'Administrador Principal',
              'phone': '+593 999 123 456',
              'address': 'Oficina Central - Ecuador',
              'createdAt': DateTime.now().toIso8601String(),
              'isAdmin': true,
            });
            print('✅ Documento de Firestore creado');
          } else {
            print('✅ El documento ya existe en Firestore');
          }
          
          await auth.signOut();
          print('🔓 Sesión cerrada');
          
          print('\n🎉 ¡VERIFICACIÓN COMPLETADA!');
          print('📧 Email: $adminEmail');
          print('🔑 Contraseña: $adminPassword');
        }
        
      } catch (signInError) {
        print('❌ Error al verificar credenciales: $signInError');
        
        if (signInError.toString().contains('wrong-password')) {
          print('\n🔧 SOLUCION: La contraseña es incorrecta.');
          print('   Ve a Firebase Console → Authentication → Users');
          print('   Busca admin@tienda-local.com y cambia la contraseña a: Admin123!');
        } else if (signInError.toString().contains('user-not-found')) {
          print('\n🔧 SOLUCION: La cuenta fue eliminada.');
          print('   Ejecuta este script nuevamente para recrearla.');
        }
      }
    } else {
      print('❌ Error inesperado: $e');
    }
  }
  
  print('\n🏁 PROCESO TERMINADO.');
}
