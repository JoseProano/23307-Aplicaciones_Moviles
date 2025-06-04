import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeIOSView extends StatelessWidget {
  const HomeIOSView({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fondo con degradado y blur
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF74ebd5),
                Color(0xFFACB6E5),
                Color(0xFFf8ffae),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        // El contenido principal de la app
        CupertinoTabScaffold(
          backgroundColor: Colors.transparent,
          tabBar: CupertinoTabBar(
            backgroundColor: CupertinoColors.systemGrey6.withOpacity(0.85),
            activeColor: CupertinoColors.activeBlue,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.home),
                label: 'Inicio',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.settings),
                label: 'Ajustes',
              ),
            ],
          ),
          tabBuilder: (context, index) {
            if (index == 0) {
              return CupertinoPageScaffold(
                backgroundColor: Colors.transparent,
                navigationBar: const CupertinoNavigationBar(
                  middle: Text('Inicio'),
                  trailing: Icon(CupertinoIcons.ellipsis),
                  border: null,
                  backgroundColor: CupertinoColors.systemGrey6,
                ),
                child: SafeArea(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 0),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: CupertinoColors.white.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: CupertinoColors.systemGrey4.withOpacity(0.2),
                            ),
                          ),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: const [
                              Icon(CupertinoIcons.device_phone_portrait, size: 48, color: CupertinoColors.activeBlue),
                              SizedBox(height: 10),
                              Text(
                                '¡Bienvenido a iOS!',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: CupertinoColors.label,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Esta es una simulación de una app iOS.',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: CupertinoColors.systemGrey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: CupertinoButton(
                          color: CupertinoColors.white.withOpacity(0.85), // Fondo claro
                          borderRadius: BorderRadius.circular(10),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: const Text(
                            'Botón Cupertino',
                            style: TextStyle(
                              color: CupertinoColors.activeBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onPressed: () {},
                        ),
                      ),
                      const SizedBox(height: 24),
                      CupertinoListSection.insetGrouped(
                        header: const Text('Opciones'),
                        backgroundColor: Colors.transparent,
                        children: const [
                          CupertinoListTile(
                            leading: Icon(CupertinoIcons.person, color: CupertinoColors.activeBlue),
                            title: Text('Perfil', style: TextStyle(color: CupertinoColors.label)),
                            trailing: CupertinoListTileChevron(),
                            backgroundColor: CupertinoColors.white, // Fondo claro
                          ),
                          CupertinoListTile(
                            leading: Icon(CupertinoIcons.bell, color: CupertinoColors.activeBlue),
                            title: Text('Notificaciones', style: TextStyle(color: CupertinoColors.label)),
                            trailing: CupertinoListTileChevron(),
                            backgroundColor: CupertinoColors.white, // Fondo claro
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return CupertinoPageScaffold(
                backgroundColor: Colors.transparent,
                navigationBar: const CupertinoNavigationBar(
                  middle: Text('Ajustes'),
                  border: null,
                  backgroundColor: CupertinoColors.systemGrey6,
                ),
                child: SafeArea(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    children: [
                      CupertinoListSection.insetGrouped(
                        header: const Text('Configuración'),
                        backgroundColor: Colors.transparent,
                        children: const [
                          CupertinoListTile(
                            leading: Icon(CupertinoIcons.settings, color: CupertinoColors.activeBlue),
                            title: Text('General', style: TextStyle(color: CupertinoColors.label)),
                            trailing: CupertinoListTileChevron(),
                            backgroundColor: CupertinoColors.white, // Fondo claro
                          ),
                          CupertinoListTile(
                            leading: Icon(CupertinoIcons.lock, color: CupertinoColors.activeBlue),
                            title: Text('Privacidad', style: TextStyle(color: CupertinoColors.label)),
                            trailing: CupertinoListTileChevron(),
                            backgroundColor: CupertinoColors.white, // Fondo claro
                          ),
                          CupertinoListTile(
                            leading: Icon(CupertinoIcons.info, color: CupertinoColors.activeBlue),
                            title: Text('Acerca de', style: TextStyle(color: CupertinoColors.label)),
                            trailing: CupertinoListTileChevron(),
                            backgroundColor: CupertinoColors.white, // Fondo claro
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: CupertinoButton(
                          color: CupertinoColors.white.withOpacity(0.85), // Fondo claro
                          borderRadius: BorderRadius.circular(10),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: const Text(
                            'Cerrar sesión',
                            style: TextStyle(
                              color: CupertinoColors.systemRed,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ],
    );
  }
}