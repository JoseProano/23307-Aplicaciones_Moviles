import 'package:flutter/material.dart';
import '../models/edad_model.dart';

class EdadViewModel extends ChangeNotifier {
  EdadModel? _edad;
  String _error = '';

  EdadModel? get edad => _edad;
  String get error => _error;

  void calcularEdad(DateTime fechaNacimiento) {
    try {
      final hoy = DateTime.now();
      
      if (fechaNacimiento.isAfter(hoy)) {
        _error = 'La fecha de nacimiento no puede ser futura';
        _edad = null;
        notifyListeners();
        return;
      }

      int anios = hoy.year - fechaNacimiento.year;
      int meses = hoy.month - fechaNacimiento.month;
      int dias = hoy.day - fechaNacimiento.day;

      if (dias < 0) {
        meses--;
        final ultimoDiaMesAnterior = DateTime(hoy.year, hoy.month, 0).day;
        dias += ultimoDiaMesAnterior;
      }

      if (meses < 0) {
        anios--;
        meses += 12;
      }

      _edad = EdadModel(anios: anios, meses: meses, dias: dias);
      _error = '';
      notifyListeners();
    } catch (e) {
      _error = 'Error al calcular la edad';
      _edad = null;
      notifyListeners();
    }
  }

  void limpiar() {
    _edad = null;
    _error = '';
    notifyListeners();
  }
}
