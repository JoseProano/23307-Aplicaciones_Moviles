import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/product_viewmodel.dart';
import '../../../utils/app_theme.dart';
import '../../widgets/product_card.dart';
import '../../widgets/product_filters.dart';
import 'product_detail_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Barra de búsqueda
          ProductSearchBar(
            onSearch: (query) {
              Provider.of<ProductViewModel>(context, listen: false)
                  .filterProductsLocally(query);
            },
            onClear: () {
              Provider.of<ProductViewModel>(context, listen: false)
                  .clearFilters();
            },
          ),
          
          const SizedBox(height: AppSpacing.sm),
          
          // Filtros
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: Consumer<ProductViewModel>(
                    builder: (context, productViewModel, child) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            FilterChip(
                              label: const Text('Todos'),
                              selected: productViewModel.selectedCategoryId == null,
                              onSelected: (selected) {
                                if (selected) {
                                  productViewModel.clearFilters();
                                  productViewModel.loadProducts();
                                }
                              },
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            ...productViewModel.categories.map((category) {
                              return Padding(
                                padding: const EdgeInsets.only(right: AppSpacing.sm),
                                child: FilterChip(
                                  label: Text(category.name),
                                  selected: productViewModel.selectedCategoryId == category.id,
                                  onSelected: (selected) {
                                    if (selected) {
                                      productViewModel.loadProductsByCategory(category.id);
                                    }
                                  },
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.sort),
                  onPressed: _showSortOptions,
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Lista de productos
          Expanded(
            child: Consumer<ProductViewModel>(
              builder: (context, productViewModel, child) {
                if (productViewModel.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                
                if (productViewModel.state == ProductState.error) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: AppConstants.iconXLarge,
                            color: AppColors.error,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'Error al cargar productos',
                            style: AppTextStyles.h6,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            productViewModel.errorMessage,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          ElevatedButton(
                            onPressed: () => productViewModel.refresh(),
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                
                if (productViewModel.filteredProducts.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.inventory_2_outlined,
                            size: AppConstants.iconXLarge,
                            color: AppColors.grey,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'No se encontraron productos',
                            style: AppTextStyles.h6,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            productViewModel.searchQuery.isNotEmpty
                                ? 'Intenta con otra búsqueda'
                                : 'No hay productos disponibles',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }
                
                return RefreshIndicator(
                  onRefresh: () => productViewModel.refresh(),
                  child: CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        sliver: SliverGrid(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: AppSpacing.md,
                            mainAxisSpacing: AppSpacing.md,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final product = productViewModel.filteredProducts[index];
                              return ProductCard(
                                product: product,
                                onTap: () => _navigateToProductDetail(product),
                              );
                            },
                            childCount: productViewModel.filteredProducts.length,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ordenar por:',
              style: AppTextStyles.h6,
            ),
            const SizedBox(height: AppSpacing.md),
            ListTile(
              title: const Text('Nombre (A-Z)'),
              onTap: () {
                Provider.of<ProductViewModel>(context, listen: false)
                    .sortProducts('name_asc');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Nombre (Z-A)'),
              onTap: () {
                Provider.of<ProductViewModel>(context, listen: false)
                    .sortProducts('name_desc');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Precio (Menor a Mayor)'),
              onTap: () {
                Provider.of<ProductViewModel>(context, listen: false)
                    .sortProducts('price_asc');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Precio (Mayor a Menor)'),
              onTap: () {
                Provider.of<ProductViewModel>(context, listen: false)
                    .sortProducts('price_desc');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Más Recientes'),
              onTap: () {
                Provider.of<ProductViewModel>(context, listen: false)
                    .sortProducts('newest');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToProductDetail(product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(product: product),
      ),
    );
  }
}
