import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/product_model.dart';
import '../../../viewmodels/product_viewmodel.dart';
import '../../../viewmodels/supplier_viewmodel.dart';
import '../../../utils/app_theme.dart';

class AddProductScreen extends StatefulWidget {
  final ProductModel? product; // Si se pasa, es para editar
  
  const AddProductScreen({super.key, this.product});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _tagsController = TextEditingController();
  
  String? _selectedCategoryId;
  String? _selectedSupplierId;
  bool _isActive = true;
  bool _isLoading = false;
  List<String> _tags = [];
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    if (widget.product != null) {
      // Modo edición
      final product = widget.product!;
      _nameController.text = product.name;
      _descriptionController.text = product.description;
      _priceController.text = product.price.toString();
      _stockController.text = product.stock.toString();
      _imageUrlController.text = product.imageUrl;
      _selectedCategoryId = product.categoryId;
      _selectedSupplierId = product.supplierId;
      _isActive = product.isActive;
      _tags = List<String>.from(product.tags);
      _updateTagsInput();
    }
    
    // Cargar proveedores
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SupplierViewModel>(context, listen: false).loadActiveSuppliers();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _imageUrlController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _updateTagsFromInput(String value) {
    setState(() {
      _tags = value
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toSet() // Eliminar duplicados
          .toList();
    });
  }

  void _updateTagsInput() {
    _tagsController.text = _tags.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final productViewModel = Provider.of<ProductViewModel>(context);
    final supplierViewModel = Provider.of<SupplierViewModel>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Agregar Producto' : 'Editar Producto'),
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
              // Nombre del producto
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Producto *',
                  hintText: 'Ej: Camiseta de algodón',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El nombre es requerido';
                  }
                  if (value.trim().length < 3) {
                    return 'El nombre debe tener al menos 3 caracteres';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: AppSpacing.md),
              
              // Descripción
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción *',
                  hintText: 'Describe las características del producto',
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La descripción es requerida';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: AppSpacing.md),
              
              // Categoría
              DropdownButtonFormField<String>(
                value: _selectedCategoryId,
                decoration: const InputDecoration(
                  labelText: 'Categoría *',
                ),
                items: productViewModel.categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category.id,
                    child: Text(category.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryId = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Selecciona una categoría';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: AppSpacing.md),
              
              // Proveedor
              DropdownButtonFormField<String>(
                value: _selectedSupplierId,
                decoration: const InputDecoration(
                  labelText: 'Proveedor (Opcional)',
                  hintText: 'Selecciona un proveedor',
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Sin proveedor (Por Administrador)'),
                  ),
                  ...supplierViewModel.activeSuppliers.map((supplier) {
                    return DropdownMenuItem<String>(
                      value: supplier.id,
                      child: Text(supplier.name),
                    );
                  }).toList(),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedSupplierId = value;
                  });
                },
              ),
              
              const SizedBox(height: AppSpacing.md),
              
              // Precio
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Precio *',
                  hintText: '19.99',
                  prefixText: '\$ ',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El precio es requerido';
                  }
                  final price = double.tryParse(value.trim());
                  if (price == null || price <= 0) {
                    return 'Ingresa un precio válido mayor a 0';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: AppSpacing.md),
              
              // Stock
              TextFormField(
                controller: _stockController,
                decoration: const InputDecoration(
                  labelText: 'Stock *',
                  hintText: '10',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El stock es requerido';
                  }
                  final stock = int.tryParse(value.trim());
                  if (stock == null || stock < 0) {
                    return 'Ingresa un stock válido (0 o mayor)';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: AppSpacing.md),
                // URL de imagen
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL de Imagen',
                  hintText: 'https://ejemplo.com/imagen.jpg',
                ),
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    final uri = Uri.tryParse(value.trim());
                    if (uri == null || !uri.hasScheme) {
                      return 'Ingresa una URL válida';
                    }
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.md),

              // Etiquetas
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: 'Etiquetas',
                  hintText: 'Ej: ropa, algodón, casual (separadas por comas)',
                  helperText: 'Separa las etiquetas con comas',
                ),
                onChanged: (value) {
                  // Actualizar etiquetas en tiempo real
                  _updateTagsFromInput(value);
                },
              ),

              const SizedBox(height: AppSpacing.sm),

              // Mostrar etiquetas actuales
              if (_tags.isNotEmpty) ...[
                Text(
                  'Etiquetas actuales:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: _tags.map((tag) => Chip(
                    label: Text(
                      tag,
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: AppColors.secondary.withOpacity(0.1),
                    labelStyle: TextStyle(
                      color: AppColors.secondary,
                    ),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () {
                      setState(() {
                        _tags.remove(tag);
                        _updateTagsInput();
                      });
                    },
                  )).toList(),
                ),
              ],

              const SizedBox(height: AppSpacing.md),
              
              // Estado activo/inactivo
              SwitchListTile(
                title: const Text('Producto activo'),
                subtitle: Text(_isActive ? 'Visible para los clientes' : 'Oculto para los clientes'),
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
                onPressed: _isLoading ? null : _saveProduct,
                child: _isLoading
                    ? const CircularProgressIndicator(color: AppColors.white)
                    : Text(widget.product == null ? 'Crear Producto' : 'Guardar Cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final productViewModel = Provider.of<ProductViewModel>(context, listen: false);
      final supplierViewModel = Provider.of<SupplierViewModel>(context, listen: false);
      
      // Obtener información del proveedor si se seleccionó uno
      String? supplierName;
      if (_selectedSupplierId != null) {
        final supplier = supplierViewModel.activeSuppliers.firstWhere(
          (s) => s.id == _selectedSupplierId,
          orElse: () => supplierViewModel.activeSuppliers.first,
        );
        supplierName = supplier.name;
      }
      
      final productData = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': double.parse(_priceController.text.trim()),
        'stock': int.parse(_stockController.text.trim()),
        'categoryId': _selectedCategoryId!,
        'imageUrl': _imageUrlController.text.trim().isEmpty 
            ? 'https://via.placeholder.com/300x300?text=Producto'
            : _imageUrlController.text.trim(),
        'isActive': _isActive,
        'tags': _tags,
        'supplierId': _selectedSupplierId,
        'supplierName': supplierName,
      };

      bool success;
      if (widget.product == null) {
        // Crear nuevo producto
        success = await productViewModel.createProduct(productData);
      } else {
        // Actualizar producto existente
        success = await productViewModel.updateProduct(widget.product!.id, productData);
      }

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.product == null 
                  ? 'Producto creado exitosamente'
                  : 'Producto actualizado exitosamente'
            ),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop(true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${productViewModel.errorMessage}'),
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
