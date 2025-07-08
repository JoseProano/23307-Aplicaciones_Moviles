import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final AuthService _authService;
  final FirestoreService _firestoreService;

  AuthRepository({
    AuthService? authService,
    FirestoreService? firestoreService,
  })  : _authService = authService ?? AuthService(),
        _firestoreService = firestoreService ?? FirestoreService();

  // Obtener usuario actual
  User? get currentUser => _authService.currentUser;

  // Stream del estado de autenticación
  Stream<User?> get authStateChanges => _authService.authStateChanges;

  // Registrar usuario
  Future<UserModel?> registerUser({
    required String email,
    required String password,
    required String name,
    String? phone,
    String? address,
  }) async {
    try {
      UserCredential? userCredential = await _authService.registerWithEmailAndPassword(
        email,
        password,
        name,
      );

      if (userCredential?.user != null) {
        UserModel newUser = UserModel(
          uid: userCredential!.user!.uid,
          email: email,
          name: name,
          phone: phone,
          address: address,
          createdAt: DateTime.now(),
        );

        await _firestoreService.createUser(newUser);
        return newUser;
      }
      return null;
    } catch (e) {
      print('Error en AuthRepository.registerUser: $e');
      rethrow;
    }
  }

  // Iniciar sesión
  Future<UserModel?> signInUser({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential? userCredential = await _authService.signInWithEmailAndPassword(
        email,
        password,
      );

      if (userCredential?.user != null) {
        UserModel? user = await _firestoreService.getUserById(userCredential!.user!.uid);
        return user;
      }
      return null;
    } catch (e) {
      print('Error en AuthRepository.signInUser: $e');
      rethrow;
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    try {
      await _authService.signOut();
    } catch (e) {
      print('Error en AuthRepository.signOut: $e');
      rethrow;
    }
  }

  // Obtener datos del usuario actual
  Future<UserModel?> getCurrentUserData() async {
    try {
      if (_authService.currentUser != null) {
        return await _firestoreService.getUserById(_authService.currentUser!.uid);
      }
      return null;
    } catch (e) {
      print('Error en AuthRepository.getCurrentUserData: $e');
      return null;
    }
  }

  // Actualizar perfil del usuario
  Future<bool> updateUserProfile(UserModel user) async {
    try {
      await _firestoreService.updateUser(user);
      return true;
    } catch (e) {
      print('Error en AuthRepository.updateUserProfile: $e');
      return false;
    }
  }

  // Restablecer contraseña
  Future<void> resetPassword(String email) async {
    try {
      await _authService.resetPassword(email);
    } catch (e) {
      print('Error en AuthRepository.resetPassword: $e');
      rethrow;
    }
  }

  // Verificar si el usuario está autenticado
  bool isUserAuthenticated() {
    return _authService.isUserAuthenticated();
  }
}
