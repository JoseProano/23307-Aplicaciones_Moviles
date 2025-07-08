import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/invoice_model.dart';
import '../../../repositories/invoice_repository.dart';
import '../../../viewmodels/auth_viewmodel.dart';
import '../../../utils/app_theme.dart';
import '../../../utils/format_utils.dart';

class CustomerInvoicesScreen extends StatefulWidget {
  const CustomerInvoicesScreen({super.key});

  @override
  State<CustomerInvoicesScreen> createState() => _CustomerInvoicesScreenState();
}

class _CustomerInvoicesScreenState extends State<CustomerInvoicesScreen> {
  final InvoiceRepository _invoiceRepository = InvoiceRepository();
  List<InvoiceModel> _invoices = [];
  bool _isLoading = false;
  String _selectedFilter = 'all';
  
  @override
  void initState() {
    super.initState();
    _loadInvoices();
  }

  Future<void> _loadInvoices() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      final user = authViewModel.currentUser;
      
      if (user != null) {
        // Cargar solo las facturas del usuario actual
        _invoices = await _invoiceRepository.getUserInvoices(user.uid);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar facturas: $e'),
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

  List<InvoiceModel> get _filteredInvoices {
    switch (_selectedFilter) {
      case 'pending':
        return _invoices.where((invoice) => invoice.status == InvoiceStatus.pending).toList();
      case 'paid':
        return _invoices.where((invoice) => invoice.status == InvoiceStatus.paid).toList();
      case 'cancelled':
        return _invoices.where((invoice) => invoice.status == InvoiceStatus.cancelled).toList();
      default:
        return _invoices;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Facturas'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInvoices,
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
                const Text('Filtrar: ', style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('Todas', 'all'),
                        const SizedBox(width: AppSpacing.sm),
                        _buildFilterChip('Pendientes', 'pending'),
                        const SizedBox(width: AppSpacing.sm),
                        _buildFilterChip('Pagadas', 'paid'),
                        const SizedBox(width: AppSpacing.sm),
                        _buildFilterChip('Canceladas', 'cancelled'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Lista de facturas
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildInvoicesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      backgroundColor: isSelected ? AppColors.primary : AppColors.greyLight,
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.white : AppColors.textPrimary,
      ),
    );
  }

  Widget _buildInvoicesList() {
    final filteredInvoices = _filteredInvoices;
    
    if (filteredInvoices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: AppColors.grey,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              _selectedFilter == 'all' ? 'No tienes facturas' : 'No hay facturas con ese estado',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadInvoices,
      child: ListView.builder(
        itemCount: filteredInvoices.length,
        itemBuilder: (context, index) {
          final invoice = filteredInvoices[index];
          return _buildInvoiceCard(invoice);
        },
      ),
    );
  }

  Widget _buildInvoiceCard(InvoiceModel invoice) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: _getStatusColor(invoice.status),
            borderRadius: BorderRadius.circular(AppBorderRadius.small),
          ),
          child: Icon(
            Icons.receipt,
            color: AppColors.white,
            size: 20,
          ),
        ),
        title: Text(
          'Factura ${invoice.invoiceNumber}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Total: ${FormatUtils.formatCurrency(invoice.totalAmount)}'),
              Text('Estado: ${invoice.statusDisplayName}'),
              Text('Fecha: ${FormatUtils.formatDate(invoice.createdAt)}'),
              if (invoice.status == InvoiceStatus.paid && invoice.paidAt != null)
                Text('Pagado: ${FormatUtils.formatDate(invoice.paidAt!)}'),
            ],
          ),
        ),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Información de facturación
                _buildSection('Información de Facturación', [
                  'Nombre: ${invoice.customerName}',
                  'Teléfono: ${invoice.customerPhone}',
                  'Dirección: ${invoice.customerAddress}',
                  'Ciudad: ${invoice.customerCity}',
                  if (invoice.cedula.isNotEmpty) ...[
                    'Cédula/RUC: ${invoice.cedula}',
                    'Empresa: ${invoice.businessName}',
                    'Dirección de facturación: ${invoice.businessAddress}',
                  ],
                ]),
                
                const SizedBox(height: AppSpacing.md),
                
                // Items de la factura
                _buildSection('Productos Comprados', 
                  invoice.items.map((item) => 
                    '${item.quantity}x ${item.productName} - ${FormatUtils.formatCurrency(item.totalPrice)}'
                  ).toList()
                ),
                
                const SizedBox(height: AppSpacing.md),
                
                // Totales
                _buildSection('Resumen de Pago', [
                  'Subtotal: ${FormatUtils.formatCurrency(invoice.subtotal)}',
                  'IVA (${invoice.ivaPercentage.toStringAsFixed(1)}%): ${FormatUtils.formatCurrency(invoice.ivaAmount)}',
                  'Total: ${FormatUtils.formatCurrency(invoice.totalAmount)}',
                ]),
                
                // Estado de pago
                const SizedBox(height: AppSpacing.md),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: _getStatusColor(invoice.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                    border: Border.all(color: _getStatusColor(invoice.status)),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _getStatusIcon(invoice.status),
                        color: _getStatusColor(invoice.status),
                        size: 32,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        _getStatusDescription(invoice.status),
                        style: TextStyle(
                          color: _getStatusColor(invoice.status),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (invoice.status == InvoiceStatus.pending) ...[
                        const SizedBox(height: AppSpacing.sm),
                        const Text(
                          'Tu pedido está siendo procesado. Te notificaremos cuando el pago sea confirmado.',
                          style: TextStyle(fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(left: AppSpacing.md, bottom: 4),
          child: Text(item),
        )),
      ],
    );
  }

  Color _getStatusColor(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.pending:
        return AppColors.warning;
      case InvoiceStatus.paid:
        return AppColors.success;
      case InvoiceStatus.cancelled:
        return AppColors.error;
    }
  }

  IconData _getStatusIcon(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.pending:
        return Icons.access_time;
      case InvoiceStatus.paid:
        return Icons.check_circle;
      case InvoiceStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _getStatusDescription(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.pending:
        return 'Pago Pendiente';
      case InvoiceStatus.paid:
        return 'Pagado';
      case InvoiceStatus.cancelled:
        return 'Cancelado';
    }
  }
}
