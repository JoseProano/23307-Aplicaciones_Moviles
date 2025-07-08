import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/product_viewmodel.dart';
import '../../../utils/app_theme.dart';
import 'add_product_screen.dart';

class ManageProductsScreen extends StatefulWidget {
  const ManageProductsScreen({super.key});

  @override
  State<ManageProductsScreen> createState() => _ManageProductsScreenState();
}

class _ManageProductsScreenState extends State<ManageProductsScreen> {
  String _searchQuery = '';
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Cargar TODOS los productos (activos e inactivos) para administración
      Provider.of<ProductViewModel>(context, listen: false).loadAllProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar Productos'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToAddProduct(),
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
                hintText: 'Buscar productos...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          
          // Lista de productos
          Expanded(
            child: Consumer<ProductViewModel>(
              builder: (context, productViewModel, child) {
                if (productViewModel.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final products = _searchQuery.isEmpty
                    ? productViewModel.products
                    : productViewModel.products
                        .where((product) =>
                            product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                            product.description.toLowerCase().contains(_searchQuery.toLowerCase()))
                        .toList();
                
                if (products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 64,
                          color: AppColors.grey,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          _searchQuery.isEmpty 
                              ? 'No hay productos registrados'
                              : 'No se encontraron productos',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.grey,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        ElevatedButton.icon(
                          onPressed: () => _navigateToAddProduct(),
                          icon: const Icon(Icons.add),
                          label: const Text('Agregar Primer Producto'),
                        ),
                      ],
                    ),
                  );
                }
                
                return RefreshIndicator(
                  onRefresh: () => productViewModel.loadAllProducts(),
                  child: ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      final category = productViewModel.getCategoryById(product.categoryId);
                      
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(AppBorderRadius.small),
                            child: Image.network(
                              product.imageUrl,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 60,
                                  height: 60,
                                  color: AppColors.greyLight,
                                  child: const Icon(Icons.image_not_supported),
                                );
                              },
                            ),
                          ),
                          title: Text(
                            product.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('\$${product.price.toStringAsFixed(2)}'),
                              Text('Stock: ${product.stock}'),
                              Text('Categoría: ${category?.name ?? 'Sin categoría'}'),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.sm,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: product.isActive ? AppColors.success : AppColors.error,
                                      borderRadius: BorderRadius.circular(AppBorderRadius.small),
                                    ),
                                    child: Text(
                                      product.isActive ? 'Activo' : 'Inactivo',
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
                            onSelected: (value) => _handleMenuAction(value, product),
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
                                value: product.isActive ? 'deactivate' : 'activate',
                                child: ListTile(
                                  leading: Icon(
                                    product.isActive ? Icons.visibility_off : Icons.visibility,
                                  ),
                                  title: Text(product.isActive ? 'Desactivar' : 'Activar'),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: ListTile(
                                  leading: Icon(Icons.delete, color: Colors.red),
                                  title: Text('Eliminar', style: TextStyle(color: Colors.red)),
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
        onPressed: () => _navigateToAddProduct(),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }

  Future<void> _navigateToAddProduct([product]) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddProductScreen(product: product),
      ),
    );
    
    if (result == true && mounted) {
      // Recargar productos si se hizo algún cambio
      Provider.of<ProductViewModel>(context, listen: false).loadAllProducts();
    }
  }

  void _handleMenuAction(String action, product) {
    switch (action) {
      case 'edit':
        _navigateToAddProduct(product);
        break;
      case 'activate':
      case 'deactivate':
        _toggleProductStatus(product);
        break;
      case 'delete':
        _confirmDeleteProduct(product);
        break;
    }
  }

  Future<void> _toggleProductStatus(product) async {
    final productViewModel = Provider.of<ProductViewModel>(context, listen: false);
    
    final success = await productViewModel.updateProduct(product.id, {
      'isActive': !product.isActive,
    });
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            product.isActive 
                ? 'Producto desactivado' 
                : 'Producto activado'
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

  Future<void> _confirmDeleteProduct(product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
          '¿Estás seguro de que quieres eliminar "${product.name}"? '
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
      
      final success = await productViewModel.deleteProduct(product.id);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Producto eliminado exitosamente'),
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
