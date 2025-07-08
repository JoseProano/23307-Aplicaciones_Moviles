import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/product_viewmodel.dart';
import '../../../utils/app_theme.dart';
import 'add_category_screen.dart';

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  String _searchQuery = '';
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductViewModel>(context, listen: false).loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar Categorías'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToAddCategory(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar categorías...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          
          // Lista de categorías
          Expanded(
            child: Consumer<ProductViewModel>(
              builder: (context, productViewModel, child) {
                if (productViewModel.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final categories = _searchQuery.isEmpty
                    ? productViewModel.categories
                    : productViewModel.categories
                        .where((category) =>
                            category.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                            category.description.toLowerCase().contains(_searchQuery.toLowerCase()))
                        .toList();
                
                if (categories.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.category_outlined,
                          size: 64,
                          color: AppColors.grey,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          _searchQuery.isEmpty 
                              ? 'No hay categorías registradas'
                              : 'No se encontraron categorías',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.grey,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        ElevatedButton.icon(
                          onPressed: () => _navigateToAddCategory(),
                          icon: const Icon(Icons.add),
                          label: const Text('Agregar Primera Categoría'),
                        ),
                      ],
                    ),
                  );
                }
                
                return RefreshIndicator(
                  onRefresh: () => productViewModel.loadCategories(),
                  child: ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final categoryColor = Color(
                        int.parse(category.color.substring(1), radix: 16) + 0xFF000000
                      );
                      
                      // Contar productos en esta categoría
                      final productCount = productViewModel.products
                          .where((product) => product.categoryId == category.id)
                          .length;
                      
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        child: ListTile(
                          leading: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: categoryColor,
                              borderRadius: BorderRadius.circular(AppBorderRadius.small),
                            ),
                            child: category.iconUrl.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(AppBorderRadius.small),
                                    child: Image.network(
                                      category.iconUrl,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Icon(
                                          Icons.category,
                                          color: Colors.white,
                                          size: 30,
                                        );
                                      },
                                    ),
                                  )
                                : const Icon(
                                    Icons.category,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                          ),
                          title: Text(
                            category.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                category.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text('$productCount productos'),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.sm,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: category.isActive ? AppColors.success : AppColors.error,
                                      borderRadius: BorderRadius.circular(AppBorderRadius.small),
                                    ),
                                    child: Text(
                                      category.isActive ? 'Activa' : 'Inactiva',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) => _handleMenuAction(value, category),
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: ListTile(
                                  leading: Icon(Icons.edit),
                                  title: Text('Editar'),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                              PopupMenuItem(
                                value: category.isActive ? 'deactivate' : 'activate',
                                child: ListTile(
                                  leading: Icon(
                                    category.isActive ? Icons.visibility_off : Icons.visibility,
                                  ),
                                  title: Text(category.isActive ? 'Desactivar' : 'Activar'),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                enabled: productCount == 0, // Solo se puede eliminar si no tiene productos
                                child: ListTile(
                                  leading: Icon(
                                    Icons.delete, 
                                    color: productCount == 0 ? Colors.red : AppColors.grey,
                                  ),
                                  title: Text(
                                    'Eliminar',
                                    style: TextStyle(
                                      color: productCount == 0 ? Colors.red : AppColors.grey,
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddCategory(),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }

  Future<void> _navigateToAddCategory([category]) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddCategoryScreen(category: category),
      ),
    );
    
    if (result == true && mounted) {
      // Recargar categorías si se hizo algún cambio
      Provider.of<ProductViewModel>(context, listen: false).loadCategories();
    }
  }

  void _handleMenuAction(String action, category) {
    switch (action) {
      case 'edit':
        _navigateToAddCategory(category);
        break;
      case 'activate':
      case 'deactivate':
        _toggleCategoryStatus(category);
        break;
      case 'delete':
        _confirmDeleteCategory(category);
        break;
    }
  }

  Future<void> _toggleCategoryStatus(category) async {
    final productViewModel = Provider.of<ProductViewModel>(context, listen: false);
    
    final success = await productViewModel.updateCategory(category.id, {
      'isActive': !category.isActive,
    });
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            category.isActive 
                ? 'Categoría desactivada' 
                : 'Categoría activada'
          ),
          backgroundColor: AppColors.success,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${productViewModel.errorMessage}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _confirmDeleteCategory(category) async {
    final productCount = Provider.of<ProductViewModel>(context, listen: false)
        .products
        .where((product) => product.categoryId == category.id)
        .length;
    
    if (productCount > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se puede eliminar una categoría que tiene productos'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
          '¿Estás seguro de que quieres eliminar "${category.name}"? '
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final productViewModel = Provider.of<ProductViewModel>(context, listen: false);
      
      final success = await productViewModel.deleteCategory(category.id);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Categoría eliminada exitosamente'),
            backgroundColor: AppColors.success,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${productViewModel.errorMessage}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
