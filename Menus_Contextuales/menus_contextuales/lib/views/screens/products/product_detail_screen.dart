import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/product_model.dart';
import '../../../viewmodels/cart_viewmodel.dart';
import '../../../viewmodels/product_viewmodel.dart';
import '../../../utils/app_theme.dart';
import '../../../utils/format_utils.dart';

class ProductDetailScreen extends StatelessWidget {
  final ProductModel product;

  const ProductDetailScreen({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del producto
            Container(
              height: 300,
              width: double.infinity,
              color: Colors.grey[100],
              child: product.imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: product.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.image_not_supported,
                          size: 80,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.image_not_supported,
                        size: 80,
                        color: Colors.grey,
                      ),
                    ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre y precio
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child:                        Text(
                          product.name,
                          style: AppTextStyles.h1,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          FormatUtils.formatPrice(product.price),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Disponibilidad
                  Row(
                    children: [
                      Icon(
                        product.isActive 
                          ? Icons.check_circle 
                          : Icons.cancel,
                        color: product.isActive 
                          ? Colors.green 
                          : Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        product.isActive 
                          ? 'Disponible' 
                          : 'No disponible',
                        style: TextStyle(
                          color: product.isActive 
                            ? Colors.green 
                            : Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      if (product.stock > 0)
                        Text(
                          'Stock: ${product.stock}',
                          style: AppTextStyles.bodyMedium,
                        ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Descripción
                  Text(
                    'Descripción',
                    style: AppTextStyles.h3,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Text(
                      product.description.isNotEmpty 
                          ? product.description 
                          : 'Este producto no tiene descripción disponible.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Información adicional
                  if (product.supplierName != null) ...[
                    _buildInfoRow(
                      'Proveedor',
                      product.supplierName!,
                      Icons.local_shipping,
                    ),
                    const SizedBox(height: 8),
                  ] else if (product.sellerName.isNotEmpty) ...[
                    _buildInfoRow(
                      'Vendedor',
                      product.sellerName,
                      Icons.store,
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Remove origin section since it's not in the model

                  if (product.tags.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Etiquetas',
                      style: AppTextStyles.h3,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: product.tags.map((tag) => GestureDetector(
                        onTap: () {
                          _searchByTag(context, tag);
                        },
                        child: Chip(
                          label: Text(
                            tag,
                            style: const TextStyle(fontSize: 12),
                          ),
                          backgroundColor: AppColors.secondary.withOpacity(0.1),
                          labelStyle: TextStyle(
                            color: AppColors.secondary,
                          ),
                        ),
                      )).toList(),
                    ),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Precio
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Precio',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                Text(
                  FormatUtils.formatPrice(product.price),
                  style: AppTextStyles.priceText,
                ),
              ],
            ),

            const SizedBox(width: 16),

            // Botón agregar al carrito
            Expanded(
              child: Consumer<CartViewModel>(
                builder: (context, cartViewModel, child) {
                  bool isInCart = cartViewModel.isProductInCart(product.id);
                  
                  return ElevatedButton.icon(
                    onPressed: product.isActive && product.stock > 0
                        ? () => _addToCart(context, cartViewModel)
                        : null,
                    icon: Icon(
                      isInCart ? Icons.check : Icons.add_shopping_cart,
                    ),
                    label: Text(
                      isInCart ? 'En el carrito' : 'Agregar al carrito',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isInCart 
                          ? Colors.green 
                          : AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _searchByTag(BuildContext context, String tag) {
    final productViewModel = Provider.of<ProductViewModel>(context, listen: false);
    productViewModel.searchProducts(tag);
    
    // Navegar de vuelta a la pantalla de productos con la búsqueda aplicada
    Navigator.of(context).pop();
  }

  void _addToCart(BuildContext context, CartViewModel cartViewModel) {
    cartViewModel.addToCart(product);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} agregado al carrito'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Ver carrito',
          textColor: Colors.white,
          onPressed: () {
            // Navegar al carrito
            DefaultTabController.of(context).animateTo(2); // Index del carrito
            Navigator.of(context).pop(); // Cerrar la pantalla de detalle
          },
        ),
      ),
    );
  }
}
