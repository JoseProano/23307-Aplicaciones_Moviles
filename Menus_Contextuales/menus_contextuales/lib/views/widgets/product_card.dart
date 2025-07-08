import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/product_model.dart';
import '../../viewmodels/cart_viewmodel.dart';
import '../../utils/app_theme.dart';
import '../../utils/format_utils.dart';
import '../screens/products/product_detail_screen.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;
  final bool showAddToCart;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.showAddToCart = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap ?? () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(product: product),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del producto
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.greyLight,
                ),
                child: product.imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: product.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) => const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: AppConstants.iconLarge,
                            color: AppColors.grey,
                          ),
                        ),
                      )
                    : const Center(
                        child: Icon(
                          Icons.image,
                          size: AppConstants.iconLarge,
                          color: AppColors.grey,
                        ),
                      ),
              ),
            ),
            
            // Información del producto
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre del producto
                    Flexible(
                      child: Text(
                        product.name,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    
                    const SizedBox(height: AppSpacing.xs),
                    
                    // Vendedor/Proveedor
                    Text(
                      product.supplierName != null 
                          ? 'Por ${product.supplierName}' 
                          : 'Por ${product.sellerName}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: AppSpacing.xs),
                    
                    // Precio y botón de agregar - siempre visible
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            FormatUtils.formatPrice(product.price),
                            style: AppTextStyles.priceText,
                          ),
                        ),
                        if (showAddToCart)
                          _buildAddToCartButton(context),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddToCartButton(BuildContext context) {
    return Consumer<CartViewModel>(
      builder: (context, cartViewModel, child) {
        final isInCart = cartViewModel.isProductInCart(product.id);
        final quantity = cartViewModel.getProductQuantity(product.id);
        
        if (isInCart) {
          return Container(
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppBorderRadius.medium),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 28,
                  height: 28,
                  child: IconButton(
                    onPressed: () => _decrementQuantity(context, cartViewModel),
                    icon: const Icon(
                      Icons.remove,
                      size: 14,
                      color: AppColors.secondary,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    '$quantity',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
                SizedBox(
                  width: 28,
                  height: 28,
                  child: IconButton(
                    onPressed: () => _incrementQuantity(context, cartViewModel),
                    icon: const Icon(
                      Icons.add,
                      size: 14,
                      color: AppColors.secondary,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
              ],
            ),
          );
        }
        
        return Container(
          width: 32,
          height: 32,
          child: IconButton(
            onPressed: () => _addToCart(context, cartViewModel),
            icon: const Icon(
              Icons.add_shopping_cart,
              size: 18,
              color: AppColors.primary,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        );
      },
    );
  }

  void _addToCart(BuildContext context, CartViewModel cartViewModel) {
    cartViewModel.addToCart(product);
    _showSnackBar(context, 'Producto agregado al carrito');
  }

  void _incrementQuantity(BuildContext context, CartViewModel cartViewModel) {
    cartViewModel.addToCart(product, quantity: 1);
  }

  void _decrementQuantity(BuildContext context, CartViewModel cartViewModel) {
    final cartItem = cartViewModel.cartItems
        .firstWhere((item) => item.product.id == product.id);
    cartViewModel.decrementQuantity(cartItem.id);
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppSpacing.md),
      ),
    );
  }
}
