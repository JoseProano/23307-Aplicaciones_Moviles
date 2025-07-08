import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/cart_viewmodel.dart';
import '../../utils/app_theme.dart';
import '../../utils/admin_helper.dart';
import 'home/home_screen.dart';
import 'products/products_screen.dart';
import 'categories/categories_screen.dart';
import 'cart/cart_screen.dart';
import 'orders/orders_screen.dart';
import 'invoices/customer_invoices_screen.dart';
import 'profile/profile_screen.dart';
import 'admin/admin_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentBottomIndex = 0;
  int _currentDrawerIndex = 0;

  // Páginas del BottomNavigationBar
  final List<Widget> _bottomPages = const [
    ProductsScreen(),
    CategoriesScreen(),
    CartScreen(),
  ];

  // Páginas del Drawer
  final List<Widget> _drawerPages = const [
    HomeScreen(),
    OrdersScreen(),
    CustomerInvoicesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        actions: [
          // Icono del carrito con badge
          Consumer<CartViewModel>(
            builder: (context, cartViewModel, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () {
                      setState(() {
                        _currentBottomIndex = 2; // Índice del carrito
                      });
                    },
                  ),
                  if (cartViewModel.itemCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${cartViewModel.itemCount}',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: _currentDrawerIndex == 0 
          ? _bottomPages[_currentBottomIndex]
          : _drawerPages[_currentDrawerIndex],
      bottomNavigationBar: _currentDrawerIndex == 0 
          ? _buildBottomNavigationBar()
          : null,
    );
  }

  String _getAppBarTitle() {
    if (_currentDrawerIndex == 0) {
      switch (_currentBottomIndex) {
        case 0:
          return 'Productos';
        case 1:
          return 'Categorías';
        case 2:
          return 'Carrito';
        default:
          return 'Tienda Local';
      }
    } else {
      switch (_currentDrawerIndex) {
        case 0:
          return 'Inicio';
        case 1:
          return 'Mis Pedidos';
        case 2:
          return 'Mis Facturas';
        case 3:
          return 'Perfil';
        default:
          return 'Tienda Local';
      }
    }
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Consumer<AuthViewModel>(
            builder: (context, authViewModel, child) {
              return UserAccountsDrawerHeader(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                accountName: Text(
                  authViewModel.currentUser?.name ?? 'Usuario',
                  style: AppTextStyles.h6.copyWith(color: AppColors.white),
                ),
                accountEmail: Text(
                  authViewModel.currentUser?.email ?? '',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: AppColors.white.withOpacity(0.3),
                  child: Text(
                    authViewModel.currentUser?.name.isNotEmpty == true
                        ? authViewModel.currentUser!.name[0].toUpperCase()
                        : 'U',
                    style: AppTextStyles.h4.copyWith(color: AppColors.white),
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Inicio'),
            selected: _currentDrawerIndex == 0,
            onTap: () {
              setState(() {
                _currentDrawerIndex = 0;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: const Text('Mis Pedidos'),
            selected: _currentDrawerIndex == 1,
            onTap: () {
              setState(() {
                _currentDrawerIndex = 1;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt),
            title: const Text('Mis Facturas'),
            selected: _currentDrawerIndex == 2,
            onTap: () {
              setState(() {
                _currentDrawerIndex = 2;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Perfil'),
            selected: _currentDrawerIndex == 3,
            onTap: () {
              setState(() {
                _currentDrawerIndex = 3;
              });
              Navigator.pop(context);
            },
          ),
          const Divider(),
          // Solo mostrar administración a usuarios administradores
          Consumer<AuthViewModel>(
            builder: (context, authViewModel, child) {
              final user = authViewModel.currentUser;
              if (user == null) return const SizedBox.shrink();
              
              return FutureBuilder<bool>(
                future: AdminHelper.isUserAdmin(user.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox.shrink();
                  }
                  
                  final isAdmin = snapshot.data ?? false;
                  if (!isAdmin) return const SizedBox.shrink();
                  
                  return ListTile(
                    leading: const Icon(Icons.admin_panel_settings),
                    title: const Text('Administración'),
                    onTap: () {
                      Navigator.pop(context);
                      _navigateToAdmin();
                    },
                  );
                },
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Ayuda'),
            onTap: () {
              Navigator.pop(context);
              _showHelpDialog();
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Acerca de'),
            onTap: () {
              Navigator.pop(context);
              _showAboutDialog();
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text('Cerrar Sesión', style: TextStyle(color: AppColors.error)),
            onTap: () {
              Navigator.pop(context);
              _showLogoutDialog();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentBottomIndex,
      onTap: (index) {
        setState(() {
          _currentBottomIndex = index;
        });
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory_2),
          label: 'Productos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.category),
          label: 'Categorías',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: 'Carrito',
        ),
      ],
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ayuda'),
        content: const Text(
          'Esta es una aplicación de tienda local donde puedes:\n\n'
          '• Explorar productos de emprendimientos locales\n'
          '• Navegar por categorías\n'
          '• Agregar productos al carrito\n'
          '• Realizar pedidos\n'
          '• Gestionar tu perfil\n\n'
          'Si necesitas más ayuda, contacta al soporte.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Tienda Local',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppBorderRadius.large),
        ),
        child: const Icon(
          Icons.store,
          color: AppColors.white,
          size: 32,
        ),
      ),
      children: const [
        Text(
          'Aplicación para promocionar y vender productos de emprendimientos locales.',
        ),
      ],
    );
  }

  void _navigateToAdmin() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AdminScreen(),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          Consumer<AuthViewModel>(
            builder: (context, authViewModel, child) {
              return TextButton(
                onPressed: authViewModel.isLoading
                    ? null
                    : () async {
                        await authViewModel.signOut();
                        if (mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                child: authViewModel.isLoading
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Cerrar Sesión',
                        style: TextStyle(color: AppColors.error),
                      ),
              );
            },
          ),
        ],
      ),
    );
  }
}
