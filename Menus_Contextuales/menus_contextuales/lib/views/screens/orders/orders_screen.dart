import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/order_viewmodel.dart';
import '../../../viewmodels/auth_viewmodel.dart';
import '../../../utils/app_theme.dart';
import '../../../utils/format_utils.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      if (authViewModel.currentUser != null) {
        Provider.of<OrderViewModel>(context, listen: false)
            .loadUserOrders(authViewModel.currentUser!.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer2<OrderViewModel, AuthViewModel>(
        builder: (context, orderViewModel, authViewModel, child) {
          if (orderViewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (orderViewModel.orders.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: AppConstants.iconXLarge,
                    color: AppColors.grey,
                  ),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    'No tienes pedidos aún',
                    style: AppTextStyles.h6,
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    'Tus pedidos aparecerán aquí',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => orderViewModel.refresh(authViewModel.currentUser!.uid),
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: orderViewModel.orders.length,
              itemBuilder: (context, index) {
                final order = orderViewModel.orders[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: ExpansionTile(
                    title: Text(
                      'Pedido #${order.id.length > 8 ? order.id.substring(0, 8) : order.id}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          FormatUtils.formatDateTime(order.createdAt),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: AppSpacing.xs,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(order.status).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(AppBorderRadius.small),
                              ),
                              child: Text(
                                order.statusText,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: _getStatusColor(order.status),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              FormatUtils.formatPrice(order.totalAmount),
                              style: AppTextStyles.priceText,
                            ),
                          ],
                        ),
                      ],
                    ),
                    children: [
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Productos (${order.items.length}):',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            ...order.items.map((item) => Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${item.quantity}x ${item.product.name}',
                                      style: AppTextStyles.bodyMedium,
                                    ),
                                  ),
                                  Text(
                                    FormatUtils.formatPrice(item.totalPrice),
                                    style: AppTextStyles.bodyMedium,
                                  ),
                                ],
                              ),
                            )).toList(),
                            
                            if (order.deliveryAddress != null) ...[
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                'Dirección de entrega:',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                order.deliveryAddress!,
                                style: AppTextStyles.bodyMedium,
                              ),
                            ],
                            
                            if (order.notes != null) ...[
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                'Notas:',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                order.notes!,
                                style: AppTextStyles.bodyMedium,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(status) {
    switch (status.toString().split('.').last) {
      case 'pending':
        return AppColors.warning;
      case 'confirmed':
        return AppColors.info;
      case 'preparing':
        return AppColors.accent;
      case 'ready':
        return AppColors.secondary;
      case 'delivered':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.grey;
    }
  }
}
