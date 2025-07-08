import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/order_model.dart';
import '../../../repositories/order_repository.dart';
import '../../../viewmodels/auth_viewmodel.dart';
import '../../../utils/app_theme.dart';
import '../../../utils/format_utils.dart';
import '../../../utils/admin_helper.dart';

class ManageOrdersScreen extends StatefulWidget {
  const ManageOrdersScreen({super.key});

  @override
  State<ManageOrdersScreen> createState() => _ManageOrdersScreenState();
}

class _ManageOrdersScreenState extends State<ManageOrdersScreen> {
  final OrderRepository _orderRepository = OrderRepository();
  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String _selectedFilter = 'all';
  
  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (_selectedFilter == 'all') {
        _orders = await _orderRepository.getAllOrders();
      } else {
        final status = OrderStatus.values.firstWhere(
          (s) => s.toString().split('.').last == _selectedFilter,
        );
        _orders = await _orderRepository.getOrdersByStatusAdmin(status);
      }
      
      // Filtrar pedidos que no tengan ID válido
      _orders = _orders.where((order) => order.id.isNotEmpty).toList();
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar pedidos: $e'),
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

  Future<void> _updateOrderStatus(OrderModel order, OrderStatus newStatus) async {
    try {
      final success = await _orderRepository.updateOrderStatus(order.id, newStatus);
      if (success) {
        // Si el pedido se marca como entregado, reducir el stock de los productos
        if (newStatus == OrderStatus.delivered && order.status != OrderStatus.delivered) {
          await _reduceProductStock(order);
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Estado del pedido actualizado correctamente'),
            backgroundColor: AppColors.success,
          ),
        );
        _loadOrders(); // Recargar la lista
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al actualizar el estado del pedido'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _reduceProductStock(OrderModel order) async {
    try {
      for (final item in order.items) {
        // Obtener el producto actual y reducir su stock
        await _orderRepository.updateProductStock(item.product.id, item.quantity);
      }
    } catch (e) {
      print('Error al reducir stock: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Advertencia: El pedido fue entregado pero hubo un error al actualizar el stock: $e'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final user = authViewModel.currentUser;
    
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Acceso Denegado'),
          backgroundColor: AppColors.error,
        ),
        body: const Center(
          child: Text('Debes estar autenticado para acceder a esta sección'),
        ),
      );
    }

    return FutureBuilder<bool>(
      future: AdminHelper.isUserAdmin(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Verificando permisos...'),
              backgroundColor: AppColors.primary,
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        final isAdmin = snapshot.data ?? false;
        
        if (!isAdmin) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Acceso Denegado'),
              backgroundColor: AppColors.error,
            ),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.access_time, size: 64, color: AppColors.error),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    'Solo los administradores pueden acceder a esta sección',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        }

        return _buildManageOrdersScreen();
      },
    );
  }

  Widget _buildManageOrdersScreen() {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar Pedidos'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrders,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtros
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                const Text('Filtrar por: '),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedFilter,
                    isExpanded: true,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedFilter = newValue;
                        });
                        _loadOrders();
                      }
                    },
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('Todos')),
                      DropdownMenuItem(value: 'pending', child: Text('Pendientes')),
                      DropdownMenuItem(value: 'confirmed', child: Text('Confirmados')),
                      DropdownMenuItem(value: 'preparing', child: Text('Preparando')),
                      DropdownMenuItem(value: 'ready', child: Text('Listos')),
                      DropdownMenuItem(value: 'delivered', child: Text('Entregados')),
                      DropdownMenuItem(value: 'cancelled', child: Text('Cancelados')),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Lista de pedidos
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _orders.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_bag_outlined, size: 64, color: AppColors.grey),
                            SizedBox(height: AppSpacing.md),
                            Text(
                              'No hay pedidos para mostrar',
                              style: TextStyle(fontSize: 16, color: AppColors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        itemCount: _orders.length,
                        itemBuilder: (context, index) {
                          final order = _orders[index];
                          return _buildOrderCard(order);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado del pedido
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pedido #${order.orderNumber}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildStatusChip(order.status),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            
            // Información del cliente
            Text(
              'Cliente: ${order.userName}',
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            Text(
              'Email: ${order.userEmail}',
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            Text(
              'Teléfono: ${order.userPhone}',
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            Text(
              'Dirección: ${order.userAddress}',
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.sm),
            
            // Fecha del pedido
            Text(
              'Fecha: ${FormatUtils.formatDate(order.createdAt)}',
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.sm),
            
            // Total del pedido
            Text(
              'Total: ${FormatUtils.formatCurrency(order.totalAmount)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            
            // Productos del pedido
            ExpansionTile(
              title: Text('Productos (${order.items.length})'),
              tilePadding: EdgeInsets.zero,
              children: order.items.map((item) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(item.productName),
                  subtitle: Text('${item.quantity} x ${FormatUtils.formatCurrency(item.price)}'),
                  trailing: Text(
                    FormatUtils.formatCurrency(item.quantity * item.price),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.sm),
            
            // Botones de acción
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                if (order.status == OrderStatus.pending)
                  ElevatedButton.icon(
                    onPressed: () => _updateOrderStatus(order, OrderStatus.confirmed),
                    icon: const Icon(Icons.check_circle, size: 16),
                    label: const Text('Confirmar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                if (order.status == OrderStatus.confirmed)
                  ElevatedButton.icon(
                    onPressed: () => _updateOrderStatus(order, OrderStatus.preparing),
                    icon: const Icon(Icons.restaurant, size: 16),
                    label: const Text('Preparar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                if (order.status == OrderStatus.preparing)
                  ElevatedButton.icon(
                    onPressed: () => _updateOrderStatus(order, OrderStatus.ready),
                    icon: const Icon(Icons.done_all, size: 16),
                    label: const Text('Listo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                if (order.status == OrderStatus.ready)
                  ElevatedButton.icon(
                    onPressed: () => _updateOrderStatus(order, OrderStatus.delivered),
                    icon: const Icon(Icons.local_shipping, size: 16),
                    label: const Text('Entregar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                if (order.status != OrderStatus.cancelled && order.status != OrderStatus.delivered)
                  ElevatedButton.icon(
                    onPressed: () => _updateOrderStatus(order, OrderStatus.cancelled),
                    icon: const Icon(Icons.cancel, size: 16),
                    label: const Text('Cancelar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(OrderStatus status) {
    Color color;
    String label;
    
    switch (status) {
      case OrderStatus.pending:
        color = Colors.orange;
        label = 'Pendiente';
        break;
      case OrderStatus.confirmed:
        color = Colors.blue;
        label = 'Confirmado';
        break;
      case OrderStatus.preparing:
        color = Colors.amber;
        label = 'Preparando';
        break;
      case OrderStatus.ready:
        color = Colors.green;
        label = 'Listo';
        break;
      case OrderStatus.delivered:
        color = Colors.teal;
        label = 'Entregado';
        break;
      case OrderStatus.cancelled:
        color = Colors.red;
        label = 'Cancelado';
        break;
    }
    
    return Chip(
      label: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
    );
  }
}
