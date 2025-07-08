import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'views/edad_view.dart';
import 'views/triangulo_view.dart';
import 'views/api_view.dart';
import 'view_models/edad_view_model.dart';
import 'view_models/triangulo_view_model.dart';
import 'view_models/api_view_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Examen P2',
      debugShowCheckedModeBanner: false,
      locale: const Locale('es', 'ES'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'),
        Locale('en', 'US'),
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  
  // ViewModels
  final EdadViewModel _edadViewModel = EdadViewModel();
  final TrianguloViewModel _trianguloViewModel = TrianguloViewModel();
  final ApiViewModel _apiViewModel = ApiViewModel();

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      EdadView(viewModel: _edadViewModel),
      TrianguloView(viewModel: _trianguloViewModel),
      ApiView(viewModel: _apiViewModel),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.cake),
            label: 'Edad',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.change_history),
            label: 'Triángulo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cloud),
            label: 'API',
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _edadViewModel.dispose();
    _trianguloViewModel.dispose();
    _apiViewModel.dispose();
    super.dispose();
  }
}
