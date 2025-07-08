import 'package:flutter/foundation.dart';
import '../models/supplier_model.dart';
import '../repositories/supplier_repository.dart';

enum SupplierState {
  initial,
  loading,
  loaded,
  error,
}

class SupplierViewModel extends ChangeNotifier {
  final SupplierRepository _supplierRepository;

  SupplierViewModel({SupplierRepository? supplierRepository})
      : _supplierRepository = supplierRepository ?? SupplierRepository();

  // Estado
  SupplierState _state = SupplierState.initial;
  List<SupplierModel> _suppliers = [];
  List<SupplierModel> _activeSuppliers = [];
  String _errorMessage = '';
  bool _isLoading = false;

  // Getters
  SupplierState get state => _state;
  List<SupplierModel> get suppliers => _suppliers;
  List<SupplierModel> get activeSuppliers => _activeSuppliers;
  String get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  // Inicializar datos
  Future<void> initialize() async {
    await loadSuppliers();
  }

  // Cargar todos los proveedores
  Future<void> loadSuppliers() async {
    _setLoading(true);
    try {
      _suppliers = await _supplierRepository.getAllSuppliers();
      _activeSuppliers = _suppliers.where((supplier) => supplier.isActive).toList();
      _setState(SupplierState.loaded);
    } catch (e) {
      _setError('Error al cargar proveedores: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Cargar solo proveedores activos
  Future<void> loadActiveSuppliers() async {
    _setLoading(true);
    try {
      _activeSuppliers = await _supplierRepository.getActiveSuppliers();
      _setState(SupplierState.loaded);
    } catch (e) {
      _setError('Error al cargar proveedores activos: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Crear proveedor
  Future<bool> createSupplier(Map<String, dynamic> supplierData) async {
    _setLoading(true);
    try {
      final success = await _supplierRepository.createSupplier(supplierData);
      if (success) {
        await loadSuppliers(); // Recargar la lista
        return true;
      } else {
        _setError('Error al crear proveedor');
        return false;
      }
    } catch (e) {
      _setError('Error al crear proveedor: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Actualizar proveedor
  Future<bool> updateSupplier(String supplierId, Map<String, dynamic> updateData) async {
    _setLoading(true);
    try {
      final success = await _supplierRepository.updateSupplier(supplierId, updateData);
      if (success) {
        await loadSuppliers(); // Recargar la lista
        return true;
      } else {
        _setError('Error al actualizar proveedor');
        return false;
      }
    } catch (e) {
      _setError('Error al actualizar proveedor: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Eliminar proveedor (soft delete)
  Future<bool> deleteSupplier(String supplierId) async {
    _setLoading(true);
    try {
      final success = await _supplierRepository.deleteSupplier(supplierId);
      if (success) {
        await loadSuppliers(); // Recargar la lista
        return true;
      } else {
        _setError('Error al eliminar proveedor');
        return false;
      }
    } catch (e) {
      _setError('Error al eliminar proveedor: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Obtener proveedor por ID
  Future<SupplierModel?> getSupplierById(String supplierId) async {
    try {
      return await _supplierRepository.getSupplierById(supplierId);
    } catch (e) {
      _setError('Error al obtener proveedor: $e');
      return null;
    }
  }

  // Métodos privados
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setState(SupplierState state) {
    _state = state;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _setState(SupplierState.error);
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    if (_state == SupplierState.error) {
      _setState(SupplierState.loaded);
    }
  }
}
