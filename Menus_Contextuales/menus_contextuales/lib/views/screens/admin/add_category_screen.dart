import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/category_model.dart';
import '../../../viewmodels/product_viewmodel.dart';
import '../../../utils/app_theme.dart';

class AddCategoryScreen extends StatefulWidget {
  final CategoryModel? category; // Si se pasa, es para editar
  
  const AddCategoryScreen({super.key, this.category});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _iconUrlController = TextEditingController();
  
  String _selectedColor = '#2196F3';
  bool _isActive = true;
  bool _isLoading = false;
  
  // Colores predefinidos para elegir
  final List<Map<String, String>> _predefinedColors = [
    {'name': 'Azul', 'value': '#2196F3'},
    {'name': 'Verde', 'value': '#4CAF50'},
    {'name': 'Rojo', 'value': '#F44336'},
    {'name': 'Naranja', 'value': '#FF9800'},
    {'name': 'Púrpura', 'value': '#9C27B0'},
    {'name': 'Cian', 'value': '#00BCD4'},
    {'name': 'Rosa', 'value': '#E91E63'},
    {'name': 'Índigo', 'value': '#3F51B5'},
  ];
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    if (widget.category != null) {
      // Modo edición
      final category = widget.category!;
      _nameController.text = category.name;
      _descriptionController.text = category.description;
      _iconUrlController.text = category.iconUrl;
      _selectedColor = category.color;
      _isActive = category.isActive;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _iconUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category == null ? 'Agregar Categoría' : 'Editar Categoría'),
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
              // Nombre de la categoría
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la Categoría *',
                  hintText: 'Ej: Alimentos',
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
              
              // Descripción
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción *',
                  hintText: 'Describe el tipo de productos de esta categoría',
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
              
              // URL del ícono
              TextFormField(
                controller: _iconUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL del Ícono',
                  hintText: 'https://ejemplo.com/icono.png',
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
              
              // Selector de color
              const Text(
                'Color de la Categoría:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: _predefinedColors.map((colorData) {
                  final color = Color(int.parse(colorData['value']!.substring(1), radix: 16) + 0xFF000000);
                  final isSelected = _selectedColor == colorData['value'];
                  
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = colorData['value']!;
                      });
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: color,
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.greyLight,
                          width: isSelected ? 3 : 1,
                        ),
                        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: AppSpacing.md),
              
              // Previsualización del color seleccionado
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Color(int.parse(_selectedColor.substring(1), radix: 16) + 0xFF000000),
                  borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                ),
                child: Text(
                  _nameController.text.isEmpty ? 'Vista previa' : _nameController.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: AppSpacing.md),
              
              // Estado activo/inactivo
              SwitchListTile(
                title: const Text('Categoría activa'),
                subtitle: Text(_isActive ? 'Visible para los clientes' : 'Oculta para los clientes'),
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
                onPressed: _isLoading ? null : _saveCategory,
                child: _isLoading
                    ? const CircularProgressIndicator(color: AppColors.white)
                    : Text(widget.category == null ? 'Crear Categoría' : 'Guardar Cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final productViewModel = Provider.of<ProductViewModel>(context, listen: false);
      
      final categoryData = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'iconUrl': _iconUrlController.text.trim().isEmpty 
            ? 'https://via.placeholder.com/100x100?text=Cat'
            : _iconUrlController.text.trim(),
        'color': _selectedColor,
        'isActive': _isActive,
      };

      bool success;
      if (widget.category == null) {
        // Crear nueva categoría
        success = await productViewModel.createCategory(categoryData);
      } else {
        // Actualizar categoría existente
        success = await productViewModel.updateCategory(widget.category!.id, categoryData);
      }

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.category == null 
                  ? 'Categoría creada exitosamente'
                  : 'Categoría actualizada exitosamente'
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
