import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/cart_item_model.dart';
import '../../../viewmodels/auth_viewmodel.dart';
import '../../../viewmodels/order_viewmodel.dart';
import '../../../utils/app_theme.dart';
import '../../../utils/format_utils.dart';
import '../../../utils/ecuador_validation_helper.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartItemModel> cartItems;
  final double totalAmount;

  const CheckoutScreen({
    super.key,
    required this.cartItems,
    required this.totalAmount,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _notesController = TextEditingController();
  
  // Datos de facturación ecuatorianos
  final _cedulaController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _businessAddressController = TextEditingController();
  
  // Configuración de IVA Ecuador
  double _selectedIVA = 15.0; // IVA por defecto en Ecuador
  bool _needsInvoice = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _notesController.dispose();
    _cedulaController.dispose();
    _businessNameController.dispose();
    _businessAddressController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final user = authViewModel.currentUser;
    
    if (user != null) {
      _nameController.text = user.name;
      _phoneController.text = user.phone ?? '';
      _addressController.text = user.address ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finalizar Pedido'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOrderSummary(),
              const SizedBox(height: AppSpacing.lg),
              _buildDeliveryInfo(),
              const SizedBox(height: AppSpacing.lg),
              _buildIVASection(),
              const SizedBox(height: AppSpacing.lg),
              _buildInvoiceSection(),
              const SizedBox(height: AppSpacing.xl),
              _buildTotalSection(),
              const SizedBox(height: AppSpacing.lg),
              _buildPlaceOrderButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen del Pedido',
              style: AppTextStyles.h6,
            ),
            const SizedBox(height: AppSpacing.sm),
            ...widget.cartItems.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${item.quantity}x ${item.product.name}',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                  Text(
                    FormatUtils.formatPrice(item.totalPrice),
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información de Entrega',
              style: AppTextStyles.h6,
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre completo',
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa tu nombre';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Teléfono',
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa tu teléfono';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Dirección completa',
                prefixIcon: Icon(Icons.home),
              ),
              maxLines: 2,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa tu dirección';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _cityController,
              decoration: const InputDecoration(
                labelText: 'Ciudad',
                prefixIcon: Icon(Icons.location_city),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa tu ciudad';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notas adicionales (opcional)',
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIVASection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configuración de IVA Ecuador',
              style: AppTextStyles.h6,
            ),
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<double>(
              value: _selectedIVA,
              decoration: const InputDecoration(
                labelText: 'Tipo de IVA',
                prefixIcon: Icon(Icons.percent),
              ),
              items: const [
                DropdownMenuItem(value: 0.0, child: Text('Sin IVA (0%)')),
                DropdownMenuItem(value: 15.0, child: Text('IVA Ecuador (15%)')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedIVA = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  value: _needsInvoice,
                  onChanged: (value) {
                    setState(() {
                      _needsInvoice = value!;
                    });
                  },
                ),
                Text(
                  'Necesito factura (Ecuador)',
                  style: AppTextStyles.h6,
                ),
              ],
            ),
            if (_needsInvoice) ...[
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _cedulaController,
                decoration: const InputDecoration(
                  labelText: 'Cédula o RUC',
                  prefixIcon: Icon(Icons.credit_card),
                  hintText: 'Ej: 1234567890 o 1234567890001',
                  helperText: 'Ingresa tu cédula (10 dígitos) o RUC (13 dígitos)',
                ),
                keyboardType: TextInputType.number,
                validator: _needsInvoice ? (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa la cédula o RUC';
                  }
                  if (!EcuadorValidationHelper.isValidCedulaOrRUC(value)) {
                    return 'Cédula o RUC no válido';
                  }
                  return null;
                } : null,
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _businessNameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la empresa o persona',
                  prefixIcon: Icon(Icons.business),
                  hintText: 'Ej: Mi Empresa S.A. o Juan Pérez',
                ),
                validator: _needsInvoice ? (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el nombre para la factura';
                  }
                  return null;
                } : null,
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _businessAddressController,
                decoration: const InputDecoration(
                  labelText: 'Dirección de facturación',
                  prefixIcon: Icon(Icons.location_on),
                  hintText: 'Dirección completa para la factura',
                ),
                maxLines: 2,
                validator: _needsInvoice ? (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa la dirección de facturación';
                  }
                  return null;
                } : null,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTotalSection() {
    final subtotal = widget.totalAmount;
    final ivaAmount = subtotal * (_selectedIVA / 100);
    final total = subtotal + ivaAmount;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Subtotal:', style: AppTextStyles.bodyLarge),
                Text(FormatUtils.formatPrice(subtotal), style: AppTextStyles.bodyLarge),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('IVA ($_selectedIVA%):', style: AppTextStyles.bodyLarge),
                Text(FormatUtils.formatPrice(ivaAmount), style: AppTextStyles.bodyLarge),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total:', style: AppTextStyles.h5.copyWith(fontWeight: FontWeight.bold)),
                Text(FormatUtils.formatPrice(total), style: AppTextStyles.h5.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceOrderButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _placeOrder,
        child: _isLoading
            ? const CircularProgressIndicator(color: AppColors.white)
            : const Text('Confirmar Pedido'),
      ),
    );
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      final orderViewModel = Provider.of<OrderViewModel>(context, listen: false);
      
      final user = authViewModel.currentUser!;
      
      // Calcular totales
      final subtotal = widget.totalAmount;
      final ivaAmount = subtotal * (_selectedIVA / 100);
      final total = subtotal + ivaAmount;

      // Crear la orden
      final success = await orderViewModel.createOrderWithInvoice(
        userId: user.uid,
        userEmail: user.email,
        cartItems: widget.cartItems,
        deliveryAddress: _addressController.text,
        customerInfo: {
          'name': _nameController.text,
          'phone': _phoneController.text,
          'address': _addressController.text,
          'city': _cityController.text,
          'notes': _notesController.text,
        },
        invoiceInfo: _needsInvoice ? {
          'cedula': _cedulaController.text,
          'businessName': _businessNameController.text,
          'businessAddress': _businessAddressController.text,
        } : null,
        ivaPercentage: _selectedIVA,
        subtotal: subtotal,
        ivaAmount: ivaAmount,
        totalAmount: total,
      );

      if (success && mounted) {
        // Mostrar diálogo de éxito
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('¡Pedido Confirmado!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 64),
                const SizedBox(height: 16),
                Text('Tu pedido ha sido confirmado exitosamente.'),
                if (_needsInvoice) 
                  const Text('\nSe generará tu factura ecuatoriana en breve.'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Cerrar diálogo
                  Navigator.of(context).pop(true); // Volver al carrito con éxito
                },
                child: const Text('Aceptar'),
              ),
            ],
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear el pedido: ${orderViewModel.errorMessage}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error inesperado: $e'),
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
}
