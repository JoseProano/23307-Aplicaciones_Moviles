import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';

class HomeAndroidView extends StatefulWidget {
  const HomeAndroidView({super.key});

  @override
  State<HomeAndroidView> createState() => _HomeAndroidViewState();
}

class _HomeAndroidViewState extends State<HomeAndroidView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0; // 0: Inicio, 1: Configuración

  void _showAndroidNotification(String message, {IconData? icon}) {
    Flushbar(
      margin: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(12),
      backgroundColor: Colors.green[700]!,
      icon: Icon(icon ?? Icons.notifications, color: Colors.white),
      messageText: Text(
        message,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      duration: const Duration(seconds: 2),
      flushbarPosition: FlushbarPosition.TOP,
      animationDuration: const Duration(milliseconds: 400),
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ).show(context);
  }

  void _onDrawerTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context);
    if (index == 0) {
      _showAndroidNotification('Inicio seleccionado', icon: Icons.home);
    } else {
      _showAndroidNotification('Configuración seleccionada', icon: Icons.settings);
    }
  }

  Widget _buildHomeContent() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: Icon(Icons.android, color: Colors.green[700], size: 40),
            title: const Text('¡Bienvenido a Android!'),
            subtitle: const Text('Esta es una simulación de Material Design.'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _showAndroidNotification('¡Bienvenido a Android!', icon: Icons.android),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notificación'),
            subtitle: const Text('Ejemplo de notificación en Android.'),
            onTap: () => _showAndroidNotification('Notificación tocada', icon: Icons.notifications),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          icon: const Icon(Icons.touch_app),
          label: const Text('Botón Material'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 2,
          ),
          onPressed: () => _showAndroidNotification('Botón Material presionado', icon: Icons.touch_app),
        ),
      ],
    );
  }

  Widget _buildSettingsContent() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: Text(
            'Configuración',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: SwitchListTile(
            activeColor: Colors.green,
            title: const Text('Notificaciones'),
            subtitle: const Text('Recibir notificaciones de la app'),
            value: true,
            onChanged: (value) {
              _showAndroidNotification('Notificaciones ${value ? "activadas" : "desactivadas"}', icon: Icons.notifications_active);
            },
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Privacidad'),
            subtitle: const Text('Opciones de privacidad'),
            onTap: () => _showAndroidNotification('Privacidad', icon: Icons.lock),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Acerca de'),
            subtitle: const Text('Información de la aplicación'),
            onTap: () => _showAndroidNotification('Acerca de', icon: Icons.info),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? 'Material App' : 'Configuración'),
        backgroundColor: Colors.green[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showAndroidNotification('Buscar presionado', icon: Icons.search),
            tooltip: 'Buscar',
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showAndroidNotification('Más opciones', icon: Icons.more_vert),
            tooltip: 'Más',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.green),
              child: Center(
                child: Text(
                  'Menú Android',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Inicio'),
              selected: _selectedIndex == 0,
              selectedTileColor: Colors.green[50],
              onTap: () => _onDrawerTap(0),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configuración'),
              selected: _selectedIndex == 1,
              selectedTileColor: Colors.green[50],
              onTap: () => _onDrawerTap(1),
            ),
          ],
        ),
      ),
      body: _selectedIndex == 0 ? _buildHomeContent() : _buildSettingsContent(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
        onPressed: () => _showAndroidNotification('FAB presionado', icon: Icons.add),
        tooltip: 'Agregar',
        elevation: 4,
      ),
    );
  }
}