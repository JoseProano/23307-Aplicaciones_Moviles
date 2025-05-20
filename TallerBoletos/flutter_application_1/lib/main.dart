import 'package:flutter/material.dart';
import 'themes/app_theme.dart';
import 'views/inicio_view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Validador de Boletos',
      theme: appTheme,
      home: InicioView(),
    );
  }
}
