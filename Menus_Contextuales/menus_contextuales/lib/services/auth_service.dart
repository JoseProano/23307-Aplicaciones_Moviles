import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Obtener usuario actual
  User? get currentUser => _firebaseAuth.currentUser;

  // Stream del usuario actual
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Registrar usuario con email y password
  Future<UserCredential?> registerWithEmailAndPassword(
    String email,
    String password,
    String name,
  ) async {
    try {
      UserCredential result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Actualizar el nombre del usuario
      await result.user?.updateDisplayName(name);

      return result;
    } catch (e) {
      print('Error en registro: $e');
      rethrow;
    }
  }

  // Iniciar sesión con email y password
  Future<UserCredential?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result;
    } catch (e) {
      print('Error en login: $e');
      rethrow;
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      print('Error al cerrar sesión: $e');
      rethrow;
    }
  }

  // Restablecer contraseña
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Error al restablecer contraseña: $e');
      rethrow;
    }
  }

  // Verificar si el usuario está autenticado
  bool isUserAuthenticated() {
    return _firebaseAuth.currentUser != null;
  }

  // Obtener token del usuario actual
  Future<String?> getCurrentUserToken() async {
    try {
      return await _firebaseAuth.currentUser?.getIdToken();
    } catch (e) {
      print('Error al obtener token: $e');
      return null;
    }
  }
}
