import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/product_viewmodel.dart';
import '../../../utils/app_theme.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ProductViewModel>(
        builder: (context, productViewModel, child) {
          if (productViewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (productViewModel.categories.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.category_outlined,
                    size: AppConstants.iconXLarge,
                    color: AppColors.grey,
                  ),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    'No hay categorías disponibles',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => productViewModel.loadCategories(),
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: productViewModel.categories.length,
              itemBuilder: (context, index) {
                final category = productViewModel.categories[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Color(int.parse(category.color.substring(1), radix: 16) + 0xFF000000),
                        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                      ),
                      child: const Icon(
                        Icons.category,
                        color: AppColors.white,
                      ),
                    ),
                    title: Text(
                      category.name,
                      style: AppTextStyles.h6,
                    ),
                    subtitle: Text(
                      category.description,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // Navegar a productos de esta categoría
                      productViewModel.loadProductsByCategory(category.id);
                      _showSnackBar('Filtrando productos de ${category.name}');
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
