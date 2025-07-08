import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/supplier_model.dart';
import '../../../viewmodels/supplier_viewmodel.dart';
import '../../../utils/app_theme.dart';
import '../../../utils/format_utils.dart';
import 'add_supplier_screen.dart';

class ManageSuppliersScreen extends StatefulWidget {
  const ManageSuppliersScreen({super.key});

  @override
  State<ManageSuppliersScreen> createState() => _ManageSuppliersScreenState();
}

class _ManageSuppliersScreenState extends State<ManageSuppliersScreen> {
  @override
  void initState() {
    super.initState();
    _loadSuppliers();
  }

  Future<void> _loadSuppliers() async {
    final supplierViewModel = Provider.of<SupplierViewModel>(context, listen: false);
    await supplierViewModel.loadSuppliers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar Proveedores'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSuppliers,
          ),
        ],
      ),
      body: Consumer<SupplierViewModel>(
        builder: (context, supplierViewModel, child) {
          if (supplierViewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (supplierViewModel.suppliers.isEmpty) {
            return _buildEmptyState();
          }

          return _buildSuppliersList(supplierViewModel.suppliers);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSupplier,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.store_outlined,
            size: 64,
            color: AppColors.grey,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No hay proveedores registrados',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.grey,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton.icon(
            onPressed: _addSupplier,
            icon: const Icon(Icons.add),
            label: const Text('Agregar Proveedor'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuppliersList(List<SupplierModel> suppliers) {
    return RefreshIndicator(
      onRefresh: _loadSuppliers,
      child: ListView.builder(
        itemCount: suppliers.length,
        itemBuilder: (context, index) {
          final supplier = suppliers[index];
          return _buildSupplierCard(supplier);
        },
      ),
    );
  }

  Widget _buildSupplierCard(SupplierModel supplier) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: supplier.isActive ? AppColors.success : AppColors.error,
            borderRadius: BorderRadius.circular(AppBorderRadius.small),
          ),
          child: Icon(
            Icons.store,
            color: AppColors.white,
            size: 20,
          ),
        ),
        title: Text(
          supplier.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Email: ${supplier.email}'),
              Text('Teléfono: ${supplier.phone}'),
              Text('Estado: ${supplier.isActive ? "Activo" : "Inactivo"}'),
              Text('Creado: ${FormatUtils.formatDate(supplier.createdAt)}'),
            ],
          ),
        ),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Información detallada
                _buildSection('Información de Contacto', [
                  'Email: ${supplier.email}',
                  'Teléfono: ${supplier.phone}',
                  'Dirección: ${supplier.address}',
                  'Ciudad: ${supplier.city}',
                ]),
                
                if (supplier.description.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  _buildSection('Descripción', [supplier.description]),
                ],
                
                const SizedBox(height: AppSpacing.md),
                
                // Información de fechas
                _buildSection('Información del Sistema', [
                  'Estado: ${supplier.isActive ? "Activo" : "Inactivo"}',
                  'Creado: ${FormatUtils.formatDate(supplier.createdAt)}',
                  'Actualizado: ${FormatUtils.formatDate(supplier.updatedAt)}',
                ]),
                
                const SizedBox(height: AppSpacing.md),
                
                // Botones de acción
                Wrap(
                  spacing: AppSpacing.sm,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _editSupplier(supplier),
                      icon: const Icon(Icons.edit),
                      label: const Text('Editar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: supplier.isActive
                          ? () => _toggleSupplierStatus(supplier)
                          : null,
                      icon: const Icon(Icons.block),
                      label: const Text('Desactivar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: AppColors.white,
                      ),
                    ),
                    if (!supplier.isActive)
                      ElevatedButton.icon(
                        onPressed: () => _toggleSupplierStatus(supplier),
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Activar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: AppColors.white,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(left: AppSpacing.md, bottom: 4),
          child: Text(item),
        )),
      ],
    );
  }

  Future<void> _addSupplier() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddSupplierScreen(),
      ),
    );

    if (result == true) {
      await _loadSuppliers();
    }
  }

  Future<void> _editSupplier(SupplierModel supplier) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddSupplierScreen(supplier: supplier),
      ),
    );

    if (result == true) {
      await _loadSuppliers();
    }
  }

  Future<void> _toggleSupplierStatus(SupplierModel supplier) async {
    final action = supplier.isActive ? 'desactivar' : 'activar';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar acción'),
        content: Text('¿Estás seguro de que deseas $action el proveedor "${supplier.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final supplierViewModel = Provider.of<SupplierViewModel>(context, listen: false);
      final success = await supplierViewModel.updateSupplier(supplier.id, {
        'isActive': !supplier.isActive,
      });

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Proveedor ${supplier.isActive ? "desactivado" : "activado"} exitosamente'),
            backgroundColor: AppColors.success,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${supplierViewModel.errorMessage}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
