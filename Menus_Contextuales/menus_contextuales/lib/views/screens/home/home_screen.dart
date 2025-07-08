import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/auth_viewmodel.dart';
import '../../../viewmodels/product_viewmodel.dart';
import '../../../viewmodels/cart_viewmodel.dart';
import '../../../models/product_model.dart';
import '../../../utils/app_theme.dart';
import '../../../utils/format_utils.dart';
import '../../widgets/product_card.dart';
import '../../widgets/home_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await Provider.of<ProductViewModel>(context, listen: false).refresh();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Saludo al usuario
              Consumer<AuthViewModel>(
                builder: (context, authViewModel, child) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.primary,
                            radius: 30,
                            child: Text(
                              authViewModel.currentUser?.name.isNotEmpty == true
                                  ? authViewModel.currentUser!.name[0].toUpperCase()
                                  : 'U',
                              style: AppTextStyles.h5.copyWith(color: AppColors.white),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '¡Hola, ${authViewModel.currentUser?.name ?? 'Usuario'}!',
                                  style: AppTextStyles.h5,
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  'Descubre productos locales increíbles',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: AppSpacing.lg),
              
              // Accesos rápidos
              Text(
                'Accesos Rápidos',
                style: AppTextStyles.h4,
              ),
              
              const SizedBox(height: AppSpacing.md),
              
              Row(
                children: [
                  Expanded(
                    child: QuickAccessCard(
                      title: 'Productos',
                      subtitle: 'Ver catálogo',
                      icon: Icons.inventory_2,
                      color: AppColors.primary,
                      onTap: () {
                        DefaultTabController.of(context).animateTo(0);
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: QuickAccessCard(
                      title: 'Categorías',
                      subtitle: 'Explorar',
                      icon: Icons.category,
                      color: AppColors.secondary,
                      onTap: () {
                        DefaultTabController.of(context).animateTo(1);
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppSpacing.md),
              
              Row(
                children: [
                  Expanded(
                    child: QuickAccessCard(
                      title: 'Mi Carrito',
                      subtitle: 'Ver productos',
                      icon: Icons.shopping_cart,
                      color: AppColors.accent,
                      onTap: () {
                        DefaultTabController.of(context).animateTo(2);
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: QuickAccessCard(
                      title: 'Mis Pedidos',
                      subtitle: 'Historial',
                      icon: Icons.receipt_long,
                      color: AppColors.info,
                      onTap: () {
                        Scaffold.of(context).openDrawer();
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppSpacing.lg),
              
              // Estadísticas del carrito
              Consumer<CartViewModel>(
                builder: (context, cartViewModel, child) {
                  if (cartViewModel.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  
                  return Card(
                    color: AppColors.primaryLight.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.shopping_cart,
                            color: AppColors.primary,
                            size: AppConstants.iconLarge,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tienes ${cartViewModel.itemCount} producto${cartViewModel.itemCount > 1 ? 's' : ''} en tu carrito',
                                  style: AppTextStyles.bodyMedium,
                                ),
                                Text(
                                  'Total: ${FormatUtils.formatPrice(cartViewModel.totalAmount)}',
                                  style: AppTextStyles.priceText,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              // Navegar al carrito (implementar navegación)
                            },
                            icon: const Icon(Icons.arrow_forward_ios),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: AppSpacing.lg),
              
              // Sección de productos destacados
              Text(
                'Productos Destacados',
                style: AppTextStyles.h4,
              ),
              
              const SizedBox(height: AppSpacing.md),
              
              Consumer<ProductViewModel>(
                builder: (context, productViewModel, child) {
                  if (productViewModel.isLoading) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.xl),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  
                  if (productViewModel.state == ProductState.error) {
                    return Card(
                      color: AppColors.error.withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: AppColors.error,
                              size: AppConstants.iconLarge,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'Error al cargar productos',
                              style: AppTextStyles.bodyMedium,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            ElevatedButton(
                              onPressed: () => productViewModel.refresh(),
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  
                  if (productViewModel.featuredProducts.isEmpty) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.inventory_2_outlined,
                              size: AppConstants.iconXLarge,
                              color: AppColors.grey,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              'No hay productos disponibles',
                              style: AppTextStyles.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  
                  return SizedBox(
                    height: 280,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: productViewModel.featuredProducts.length,
                      itemBuilder: (context, index) {
                        final product = productViewModel.featuredProducts[index];
                        return Container(
                          width: 200,
                          margin: const EdgeInsets.only(right: AppSpacing.md),
                          child: ProductCard(
                            product: product,
                            onTap: () => _navigateToProductDetail(product),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              
              const SizedBox(height: AppSpacing.lg),
              
              // Sección de accesos rápidos
              Text(
                'Accesos Rápidos',
                style: AppTextStyles.h4,
              ),
              
              const SizedBox(height: AppSpacing.md),
              
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.md,
                childAspectRatio: 1.5,
                children: [
                  _buildQuickAccessCard(
                    icon: Icons.inventory_2,
                    title: 'Ver Productos',
                    subtitle: 'Explorar catálogo',
                    color: AppColors.primary,
                    onTap: () {
                      // Navegar a productos
                    },
                  ),
                  _buildQuickAccessCard(
                    icon: Icons.category,
                    title: 'Categorías',
                    subtitle: 'Por tipo',
                    color: AppColors.secondary,
                    onTap: () {
                      // Navegar a categorías
                    },
                  ),
                  _buildQuickAccessCard(
                    icon: Icons.receipt_long,
                    title: 'Mis Pedidos',
                    subtitle: 'Historial',
                    color: AppColors.accent,
                    onTap: () {
                      // Navegar a pedidos
                    },
                  ),
                  _buildQuickAccessCard(
                    icon: Icons.person,
                    title: 'Mi Perfil',
                    subtitle: 'Configuración',
                    color: AppColors.info,
                    onTap: () {
                      // Navegar a perfil
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAccessCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: AppConstants.iconLarge,
                color: color,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToProductDetail(ProductModel product) {
    // Implementar navegación al detalle del producto
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ver detalles de ${product.name}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
