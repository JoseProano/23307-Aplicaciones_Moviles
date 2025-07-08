import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/supplier_model.dart';
import '../../../viewmodels/supplier_viewmodel.dart';
import '../../../utils/app_theme.dart';

class AddSupplierScreen extends StatefulWidget {
  final SupplierModel? supplier; // Si se pasa, es para editar
  
  const AddSupplierScreen({super.key, this.supplier});

  @override
  State<AddSupplierScreen> createState() => _AddSupplierScreenState();
}

class _AddSupplierScreenState extends State<AddSupplierScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  bool _isActive = true;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    if (widget.supplier != null) {
      // Modo edición
      final supplier = widget.supplier!;
      _nameController.text = supplier.name;
      _emailController.text = supplier.email;
      _phoneController.text = supplier.phone;
      _addressController.text = supplier.address;
      _cityController.text = supplier.city;
      _descriptionController.text = supplier.description;
      _isActive = supplier.isActive;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.supplier == null ? 'Agregar Proveedor' : 'Editar Proveedor'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Nombre del proveedor
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Proveedor *',
                  hintText: 'Ej: Proveedor ABC',
                  prefixIcon: Icon(Icons.business),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El nombre es requerido';
                  }
                  if (value.trim().length < 2) {
                    return 'El nombre debe tener al menos 2 caracteres';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: AppSpacing.md),
              
              // Email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email *',
                  hintText: 'proveedor@ejemplo.com',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El email es requerido';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value.trim())) {
                    return 'Ingresa un email válido';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: AppSpacing.md),
              
              // Teléfono
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Teléfono *',
                  hintText: '+593 99 999 9999',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El teléfono es requerido';
                  }
                  if (value.trim().length < 10) {
                    return 'El teléfono debe tener al menos 10 dígitos';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: AppSpacing.md),
              
              // Dirección
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Dirección *',
                  hintText: 'Ej: Av. Principal 123',
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La dirección es requerida';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: AppSpacing.md),
              
              // Ciudad
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'Ciudad *',
                  hintText: 'Ej: Quito',
                  prefixIcon: Icon(Icons.location_city),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La ciudad es requerida';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: AppSpacing.md),
              
              // Descripción
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  hintText: 'Describe el tipo de productos que ofrece',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              
              const SizedBox(height: AppSpacing.md),
              
              // Estado activo/inactivo
              SwitchListTile(
                title: const Text('Proveedor activo'),
                subtitle: Text(_isActive ? 'Puede agregar productos' : 'No puede agregar productos'),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
              ),
              
              const SizedBox(height: AppSpacing.xl),
              
              // Botón de guardar
              ElevatedButton(
                onPressed: _isLoading ? null : _saveSupplier,
                child: _isLoading
                    ? const CircularProgressIndicator(color: AppColors.white)
                    : Text(widget.supplier == null ? 'Crear Proveedor' : 'Guardar Cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveSupplier() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final supplierViewModel = Provider.of<SupplierViewModel>(context, listen: false);
      
      final supplierData = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'city': _cityController.text.trim(),
        'description': _descriptionController.text.trim(),
        'isActive': _isActive,
      };

      bool success;
      if (widget.supplier == null) {
        // Crear nuevo proveedor
        success = await supplierViewModel.createSupplier(supplierData);
      } else {
        // Actualizar proveedor existente
        success = await supplierViewModel.updateSupplier(widget.supplier!.id, supplierData);
      }

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.supplier == null 
                  ? 'Proveedor creado exitosamente'
                  : 'Proveedor actualizado exitosamente'
            ),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop(true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${supplierViewModel.errorMessage}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error inesperado: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
