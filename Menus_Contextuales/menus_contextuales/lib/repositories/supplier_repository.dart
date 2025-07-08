import '../models/supplier_model.dart';
import '../services/firestore_service.dart';

class SupplierRepository {
  final FirestoreService _firestoreService = FirestoreService();

  // Crear un nuevo proveedor
  Future<bool> createSupplier(Map<String, dynamic> supplierData) async {
    try {
      final supplierId = await _firestoreService.addSupplier(supplierData);
      return supplierId != null;
    } catch (e) {
      print('Error en SupplierRepository.createSupplier: $e');
      return false;
    }
  }

  // Obtener todos los proveedores
  Future<List<SupplierModel>> getAllSuppliers() async {
    try {
      return await _firestoreService.getSuppliers();
    } catch (e) {
      print('Error en SupplierRepository.getAllSuppliers: $e');
      return [];
    }
  }

  // Obtener proveedores activos
  Future<List<SupplierModel>> getActiveSuppliers() async {
    try {
      return await _firestoreService.getActiveSuppliers();
    } catch (e) {
      print('Error en SupplierRepository.getActiveSuppliers: $e');
      return [];
    }
  }

  // Obtener un proveedor por ID
  Future<SupplierModel?> getSupplierById(String supplierId) async {
    try {
      return await _firestoreService.getSupplierById(supplierId);
    } catch (e) {
      print('Error en SupplierRepository.getSupplierById: $e');
      return null;
    }
  }

  // Actualizar un proveedor
  Future<bool> updateSupplier(String supplierId, Map<String, dynamic> updateData) async {
    try {
      return await _firestoreService.updateSupplier(supplierId, updateData);
    } catch (e) {
      print('Error en SupplierRepository.updateSupplier: $e');
      return false;
    }
  }

  // Eliminar un proveedor (soft delete)
  Future<bool> deleteSupplier(String supplierId) async {
    try {
      return await _firestoreService.updateSupplier(supplierId, {
        'isActive': false,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error en SupplierRepository.deleteSupplier: $e');
      return false;
    }
  }
}
