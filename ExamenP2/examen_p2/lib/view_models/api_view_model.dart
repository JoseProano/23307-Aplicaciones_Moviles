import 'package:flutter/material.dart';
import '../models/usuario_model.dart';
import '../services/api_service.dart';

class ApiViewModel extends ChangeNotifier {
  List<Usuario> _usuarios = [];
  bool _isLoading = false;
  String _error = '';

  List<Usuario> get usuarios => _usuarios;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> cargarUsuarios() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _usuarios = await ApiService.getUsuarios();
      _error = '';
    } catch (e) {
      _error = e.toString();
      _usuarios = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void limpiar() {
    _usuarios = [];
    _error = '';
    _isLoading = false;
    notifyListeners();
  }
}
