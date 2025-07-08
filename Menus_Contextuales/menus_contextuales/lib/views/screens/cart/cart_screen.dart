import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/cart_viewmodel.dart';
import '../../../viewmodels/auth_viewmodel.dart';
import '../../../viewmodels/order_viewmodel.dart';
import '../../../utils/app_theme.dart';
import '../../../utils/format_utils.dart';
import '../checkout/checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<CartViewModel>(
        builder: (context, cartViewModel, child) {
          if (cartViewModel.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: AppConstants.iconXLarge,
                    color: AppColors.grey,
                  ),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    'Tu carrito está vacío',
                    style: AppTextStyles.h6,
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    'Agrega productos para comenzar',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Lista de productos
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: cartViewModel.cartItems.length,
                  itemBuilder: (context, index) {
                    final cartItem = cartViewModel.cartItems[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Row(
                          children: [
                            // Imagen del producto
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: AppColors.greyLight,
                                borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                              ),
                              child: const Icon(
                                Icons.image,
                                size: AppConstants.iconLarge,
                                color: AppColors.grey,
                              ),
                            ),
                            
                            const SizedBox(width: AppSpacing.md),
                            
                            // Información del producto
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cartItem.product.name,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    'Por ${cartItem.product.sellerName}',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Row(
                                    children: [
                                      Text(
                                        FormatUtils.formatPrice(cartItem.product.price),
                                        style: AppTextStyles.priceText,
                                      ),
                                      const Spacer(),
                                      Text(
                                        'Total: ${FormatUtils.formatPrice(cartItem.totalPrice)}',
                                        style: AppTextStyles.bodyMedium.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(width: AppSpacing.md),
                            
                            // Controles de cantidad
                            Column(
                              children: [
                                // Botones de cantidad
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.greyLight),
                                    borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                                  ),
                                  child: Column(
                                    children: [
                                      InkWell(
                                        onTap: () => cartViewModel.incrementQuantity(cartItem.id),
                                        child: Container(
                                          padding: const EdgeInsets.all(AppSpacing.xs),
                                          child: const Icon(
                                            Icons.add,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppSpacing.sm,
                                          vertical: AppSpacing.xs,
                                        ),
                                        child: Text(
                                          '${cartItem.quantity}',
                                          style: AppTextStyles.bodyMedium.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () => cartViewModel.decrementQuantity(cartItem.id),
                                        child: Container(
                                          padding: const EdgeInsets.all(AppSpacing.xs),
                                          child: const Icon(
                                            Icons.remove,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                const SizedBox(height: AppSpacing.sm),
                                
                                // Botón eliminar
                                IconButton(
                                  onPressed: () => _showRemoveDialog(cartViewModel, cartItem.id),
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: AppColors.error,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Resumen y botón de checkout
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  boxShadow: [AppShadows.medium],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          'Subtotal (${cartViewModel.totalQuantity} productos):',
                          style: AppTextStyles.bodyMedium,
                        ),
                        const Spacer(),
                        Text(
                          FormatUtils.formatPrice(cartViewModel.totalAmount),
                          style: AppTextStyles.h6.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: AppSpacing.md),
                    
                    SizedBox(
                      width: double.infinity,
                      child: Consumer<OrderViewModel>(
                        builder: (context, orderViewModel, child) {
                          return ElevatedButton(
                            onPressed: orderViewModel.isCreatingOrder
                                ? null
                                : () => _proceedToCheckout(cartViewModel),
                            child: orderViewModel.isCreatingOrder
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.white,
                                      ),
                                    ),
                                  )
                                : const Text('Proceder al Pago'),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showRemoveDialog(CartViewModel cartViewModel, String cartItemId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: const Text('¿Estás seguro de que quieres eliminar este producto del carrito?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              cartViewModel.removeFromCart(cartItemId);
              Navigator.of(context).pop();
              _showSnackBar('Producto eliminado del carrito');
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _proceedToCheckout(CartViewModel cartViewModel) async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    // Verificar que el usuario esté autenticado
    if (authViewModel.currentUser == null) {
      _showSnackBar('Error: Usuario no autenticado');
      return;
    }

    // Verificar que hay items en el carrito
    if (cartViewModel.cartItems.isEmpty) {
      _showSnackBar('El carrito está vacío');
      return;
    }

    // Validar que todos los items del carrito tienen datos válidos
    bool hasValidItems = cartViewModel.cartItems.every((item) => 
        item.product.id.isNotEmpty && 
        item.product.name.isNotEmpty &&
        item.quantity > 0
    );

    if (!hasValidItems) {
      _showSnackBar('Hay productos con datos incorrectos en el carrito');
      return;
    }

    try {
      if (!cartViewModel.validateStock()) {
        _showSnackBar('Algunos productos no tienen stock suficiente');
        return;
      }
    } catch (e) {
      _showSnackBar('Error validando stock: $e');
      return;
    }

    // Navegar a la pantalla de checkout
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(
          cartItems: cartViewModel.cartItems,
          totalAmount: cartViewModel.totalAmount,
        ),
      ),
    );

    // Si el checkout fue exitoso, limpiar el carrito
    if (result == true && mounted) {
      await cartViewModel.clearCart();
      _showSnackBar('¡Pedido realizado exitosamente!');
    }
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
