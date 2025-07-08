import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthViewModel({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();

  // Estado
  AuthState _authState = AuthState.initial;
  UserModel? _currentUser;
  String _errorMessage = '';
  bool _isLoading = false;

  // Getters
  AuthState get authState => _authState;
  UserModel? get currentUser => _currentUser;
  String get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _authState == AuthState.authenticated;

  // Inicializar el ViewModel
  void initialize() {
    _authRepository.authStateChanges.listen((User? user) {
      if (user != null) {
        _loadCurrentUser();
      } else {
        _setUnauthenticated();
      }
    });

    // Verificar estado inicial
    if (_authRepository.isUserAuthenticated()) {
      _loadCurrentUser();
    } else {
      _setUnauthenticated();
    }
  }

  // Cargar datos del usuario actual
  Future<void> _loadCurrentUser() async {
    try {
      _currentUser = await _authRepository.getCurrentUserData();
      _authState = AuthState.authenticated;
      _errorMessage = '';
      notifyListeners();
    } catch (e) {
      _setError('Error al cargar datos del usuario');
    }
  }

  // Registrar usuario
  Future<bool> register({
    required String email,
    required String password,
    required String name,
    String? phone,
    String? address,
  }) async {
    _setLoading(true);
    try {
      _currentUser = await _authRepository.registerUser(
        email: email,
        password: password,
        name: name,
        phone: phone,
        address: address,
      );

      if (_currentUser != null) {
        _authState = AuthState.authenticated;
        _errorMessage = '';
        _setLoading(false);
        return true;
      } else {
        _setError('Error al registrar usuario');
        return false;
      }
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    }
  }

  // Iniciar sesión
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      _currentUser = await _authRepository.signInUser(
        email: email,
        password: password,
      );

      if (_currentUser != null) {
        _authState = AuthState.authenticated;
        _errorMessage = '';
        _setLoading(false);
        return true;
      } else {
        _setError('Credenciales incorrectas');
        return false;
      }
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _authRepository.signOut();
      _setUnauthenticated();
    } catch (e) {
      _setError('Error al cerrar sesión');
    }
  }

  // Actualizar perfil
  Future<bool> updateProfile(UserModel updatedUser) async {
    _setLoading(true);
    try {
      bool success = await _authRepository.updateUserProfile(updatedUser);
      if (success) {
        _currentUser = updatedUser;
        _errorMessage = '';
        _setLoading(false);
        return true;
      } else {
        _setError('Error al actualizar perfil');
        return false;
      }
    } catch (e) {
      _setError('Error al actualizar perfil');
      return false;
    }
  }

  // Restablecer contraseña
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    try {
      await _authRepository.resetPassword(email);
      _errorMessage = '';
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Error al enviar email de restablecimiento');
      return false;
    }
  }

  // Limpiar error
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  // Métodos privados
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _authState = AuthState.error;
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
  }

  void _setUnauthenticated() {
    _authState = AuthState.unauthenticated;
    _currentUser = null;
    _errorMessage = '';
    _isLoading = false;
    notifyListeners();
  }

  String _getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No se encontró un usuario con este email';
        case 'wrong-password':
          return 'Contraseña incorrecta';
        case 'email-already-in-use':
          return 'Este email ya está registrado';
        case 'weak-password':
          return 'La contraseña es muy débil';
        case 'invalid-email':
          return 'Email inválido';
        case 'too-many-requests':
          return 'Demasiados intentos. Intenta más tarde';
        default:
          return 'Error de autenticación: ${error.message}';
      }
    }
    return error.toString();
  }
}
