import 'package:flutter/material.dart';
import '../controllers/platform_controller.dart';
import 'home_android_view.dart';
import 'home_ios_view.dart';

enum PlatformType { android, ios, detected }

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late PlatformType _selectedPlatform;

  @override
  void initState() {
    super.initState();
    final detected = PlatformController.getPlatform().name;
    if (detected == 'Android') {
      _selectedPlatform = PlatformType.android;
    } else if (detected == 'iOS') {
      _selectedPlatform = PlatformType.ios;
    } else {
      _selectedPlatform = PlatformType.android; // Default
    }
  }

  void _onPlatformChanged(PlatformType? value) {
    if (value != null) {
      setState(() {
        _selectedPlatform = value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    Color appBarColor;
    Color iconColor;
    Color textColor;

    if (_selectedPlatform == PlatformType.android) {
      content = const HomeAndroidView();
      appBarColor = Colors.green[700]!;
      iconColor = Colors.white;
      textColor = Colors.white;
    } else if (_selectedPlatform == PlatformType.ios) {
      content = const HomeIOSView();
      appBarColor = Colors.grey[100]!;
      iconColor = Colors.blue;
      textColor = Colors.black87;
    } else {
      content = Scaffold(
        appBar: AppBar(title: const Text('Plataforma no soportada')),
        body: const Center(child: Text('Esta plataforma no es Android ni iOS')),
      );
      appBarColor = Theme.of(context).appBarTheme.backgroundColor ?? Colors.blue;
      iconColor = Colors.white;
      textColor = Colors.white;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        title: Text(
          'Demo Plataforma',
          style: TextStyle(color: textColor),
        ),
        iconTheme: IconThemeData(color: iconColor),
        actions: [
          PopupMenuButton<PlatformType>(
            icon: Icon(
              _selectedPlatform == PlatformType.ios
                  ? Icons.phone_iphone
                  : Icons.phone_android,
              color: iconColor,
            ),
            onSelected: _onPlatformChanged,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: PlatformType.android,
                child: Text('Vista Android'),
              ),
              const PopupMenuItem(
                value: PlatformType.ios,
                child: Text('Vista iOS'),
              ),
            ],
          ),
        ],
      ),
      body: content,
    );
  }
}