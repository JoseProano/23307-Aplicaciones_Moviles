import 'package:firebase_auth/firebase_auth.dart';

class DevAuthHelper {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  
  /// Crea una cuenta de usuario de prueba para desarrollo
  static Future<User?> createTestUser({
    String email = 'admin@tienda.local',
    String password = 'password123',
    String name = 'Administrador',
  }) async {
    try {
      print('👤 Creando usuario de prueba: $email');
      
      // Crear usuario
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Actualizar perfil
      await credential.user?.updateDisplayName(name);
      
      print('✅ Usuario de prueba creado exitosamente');
      return credential.user;
    } catch (e) {
      print('⚠️ Error al crear usuario de prueba (puede que ya exista): $e');
      
      // Intentar iniciar sesión si el usuario ya existe
      try {
        final credential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        print('✅ Sesión iniciada con usuario existente');
        return credential.user;
      } catch (loginError) {
        print('❌ Error al iniciar sesión: $loginError');
        return null;
      }
    }
  }
  
  /// Inicia sesión automáticamente para desarrollo
  static Future<User?> autoLogin() async {
    try {
      // Si ya hay un usuario autenticado, usarlo
      if (_auth.currentUser != null) {
        print('✅ Usuario ya autenticado: ${_auth.currentUser!.email}');
        return _auth.currentUser;
      }
      
      // Si no, crear/usar usuario de prueba
      return await createTestUser();
    } catch (e) {
      print('❌ Error en auto-login: $e');
      return null;
    }
  }
  
  /// Verifica si hay un usuario autenticado
  static bool isAuthenticated() {
    return _auth.currentUser != null;
  }
  
  /// Obtiene el usuario actual
  static User? getCurrentUser() {
    return _auth.currentUser;
  }
}
