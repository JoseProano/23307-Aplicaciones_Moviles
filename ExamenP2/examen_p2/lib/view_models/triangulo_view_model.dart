import 'package:flutter/material.dart';
import '../models/triangulo_model.dart';

class TrianguloViewModel extends ChangeNotifier {
  TrianguloModel? _triangulo;
  String _error = '';

  TrianguloModel? get triangulo => _triangulo;
  String get error => _error;

  void analizarTriangulo(String lado1Str, String lado2Str, String lado3Str) {
    try {
      // Validar que los campos no estén vacíos
      if (lado1Str.isEmpty || lado2Str.isEmpty || lado3Str.isEmpty) {
        _error = 'Todos los campos son obligatorios';
        _triangulo = null;
        notifyListeners();
        return;
      }

      final lado1 = double.parse(lado1Str);
      final lado2 = double.parse(lado2Str);
      final lado3 = double.parse(lado3Str);

      // Validar que los lados sean positivos
      if (lado1 <= 0 || lado2 <= 0 || lado3 <= 0) {
        _error = 'Los lados deben ser números positivos';
        _triangulo = null;
        notifyListeners();
        return;
      }

      // Validar desigualdad triangular
      if (!_esTrianguloValido(lado1, lado2, lado3)) {
        _triangulo = TrianguloModel(
          lado1: lado1,
          lado2: lado2,
          lado3: lado3,
          tipo: TipoTriangulo.invalido,
        );
        _error = 'Los lados no forman un triángulo válido';
        notifyListeners();
        return;
      }

      final tipo = _determinarTipoTriangulo(lado1, lado2, lado3);
      _triangulo = TrianguloModel(
        lado1: lado1,
        lado2: lado2,
        lado3: lado3,
        tipo: tipo,
      );
      _error = '';
      notifyListeners();
    } catch (e) {
      _error = 'Por favor ingrese números válidos';
      _triangulo = null;
      notifyListeners();
    }
  }

  bool _esTrianguloValido(double a, double b, double c) {
    return (a + b > c) && (a + c > b) && (b + c > a);
  }

  TipoTriangulo _determinarTipoTriangulo(double a, double b, double c) {
    if (a == b && b == c) {
      return TipoTriangulo.equilatero;
    } else if (a == b || b == c || a == c) {
      return TipoTriangulo.isosceles;
    } else {
      return TipoTriangulo.escaleno;
    }
  }

  String obtenerDescripcionTipo(TipoTriangulo tipo) {
    switch (tipo) {
      case TipoTriangulo.equilatero:
        return 'Equilátero (todos los lados iguales)';
      case TipoTriangulo.isosceles:
        return 'Isósceles (dos lados iguales)';
      case TipoTriangulo.escaleno:
        return 'Escaleno (todos los lados diferentes)';
      case TipoTriangulo.invalido:
        return 'No es un triángulo válido';
    }
  }

  void limpiar() {
    _triangulo = null;
    _error = '';
    notifyListeners();
  }
}
