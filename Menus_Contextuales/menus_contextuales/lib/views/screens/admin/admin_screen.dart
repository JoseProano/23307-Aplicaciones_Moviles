import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/upload_sample_data.dart';
import '../../../utils/data_migration_helper.dart';
import '../../../utils/admin_helper.dart';
import '../../../viewmodels/auth_viewmodel.dart';
import '../../../utils/app_theme.dart';
import 'add_product_screen.dart';
import 'add_category_screen.dart';
import 'manage_products_screen.dart';
import 'manage_categories_screen.dart';
import 'invoices_screen.dart';
import 'manage_orders_screen.dart';
import 'create_admin_screen.dart';
import 'manage_suppliers_screen.dart';
import 'add_supplier_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  bool _isLoading = false;
  String _statusMessage = '';

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
          return _buildAccessDeniedScreen();
        }
        
        return _buildAdminScreen();
      },
    );
  }

  Widget _buildAccessDeniedScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acceso Denegado'),
        backgroundColor: AppColors.error,
      ),
      body: const Center(
        child: Text('No tienes permisos para acceder a esta sección'),
      ),
    );
  }

  Widget _buildAdminScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administración'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sección de gestión de productos y categorías
            const Text(
              'Gestión de Contenido',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            
            // Botones de gestión de productos
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const ManageProductsScreen()),
                    ),
                    icon: const Icon(Icons.inventory),
                    label: const Text('Gestionar Productos'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const AddProductScreen()),
                    ),
                    icon: const Icon(Icons.add_box),
                    label: const Text('Agregar Producto'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            // Botones de gestión de categorías
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const ManageCategoriesScreen()),
                    ),
                    icon: const Icon(Icons.category),
                    label: const Text('Gestionar Categorías'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const AddCategoryScreen()),
                    ),
                    icon: const Icon(Icons.add_circle),
                    label: const Text('Agregar Categoría'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            // Botones de gestión de proveedores
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const ManageSuppliersScreen()),
                    ),
                    icon: const Icon(Icons.local_shipping),
                    label: const Text('Gestionar Proveedores'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const AddSupplierScreen()),
                    ),
                    icon: const Icon(Icons.add_business),
                    label: const Text('Agregar Proveedor'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            // Botón de facturas
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const InvoicesScreen()),
              ),
              icon: const Icon(Icons.receipt_long),
              label: const Text('Gestionar Facturas'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              ),
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            // Botón para gestionar pedidos
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ManageOrdersScreen()),
              ),
              icon: const Icon(Icons.shopping_bag),
              label: const Text('Gestionar Pedidos'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              ),
            ),
            
            const SizedBox(height: AppSpacing.xl),
            
            // Separador
            const Divider(thickness: 2),
            
            const SizedBox(height: AppSpacing.md),
            
            // Sección de gestión de datos
            const Text(
              'Gestión de Datos de Ejemplo',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Usa estas opciones para gestionar los datos de ejemplo en Firestore:',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.md),
            
            // Botón para cargar datos
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _uploadSampleData,
              icon: const Icon(Icons.upload),
              label: const Text('Cargar Datos de Ejemplo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              ),
            ),
            
            const SizedBox(height: AppSpacing.sm),
            
            // Botón para verificar datos
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _checkDataExists,
              icon: const Icon(Icons.search),
              label: const Text('Verificar Datos Existentes'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              ),
            ),
            
            const SizedBox(height: AppSpacing.sm),
            
            // Botón para migrar datos
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _migrateData,
              icon: const Icon(Icons.autorenew),
              label: const Text('Migrar Datos (Corregir Formato)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              ),
            ),
            
            const SizedBox(height: AppSpacing.sm),
            
            // Botón para limpiar datos
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _clearSampleData,
              icon: const Icon(Icons.delete),
              label: const Text('Limpiar Todos los Datos'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              ),
            ),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Separador
            const Divider(thickness: 2),
            
            const SizedBox(height: AppSpacing.md),
            
            // Sección de creación de administradores
            const Text(
              'Gestión de Administradores',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: AppSpacing.sm),
            
            const Text(
              'Crea nuevos usuarios con permisos de administrador.',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            // Botón para crear administrador personalizado
            ElevatedButton.icon(
              onPressed: _isLoading ? null : () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const CreateAdminScreen()),
              ),
              icon: const Icon(Icons.admin_panel_settings),
              label: const Text('Crear Nuevo Administrador'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),
            
            // Indicador de carga
            if (_isLoading) ...[
              const Center(
                child: CircularProgressIndicator(),
              ),
            ],
            
            // Mensaje de estado
            if (_statusMessage.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                  border: Border.all(color: AppColors.greyLight),
                ),
                child: Text(
                  _statusMessage,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _uploadSampleData() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Cargando datos de ejemplo...';
    });

    try {
      await SampleDataUploader.uploadAllSampleData();
      setState(() {
        _statusMessage = '✅ Datos de ejemplo cargados exitosamente!';
      });
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Error al cargar datos: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkDataExists() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Verificando datos existentes...';
    });

    try {
      final exists = await SampleDataUploader.checkIfDataExists();
      setState(() {
        _statusMessage = exists 
          ? '✅ Existen datos en Firestore' 
          : '📭 No hay datos en Firestore';
      });
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Error al verificar datos: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _migrateData() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Migrando datos (corrigiendo formato)...';
    });

    try {
      await DataMigrationHelper.migrateTimestampData();
      setState(() {
        _statusMessage = '✅ Migración completada exitosamente! Los datos ahora tienen el formato correcto.';
      });
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Error durante la migración: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _clearSampleData() async {
    // Confirmar antes de eliminar
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar'),
        content: const Text(
          '¿Estás seguro de que quieres eliminar todos los datos? '
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
      _statusMessage = 'Eliminando todos los datos...';
    });

    try {
      await SampleDataUploader.clearAllSampleData();
      setState(() {
        _statusMessage = '✅ Todos los datos han sido eliminados!';
      });
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Error al eliminar datos: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
