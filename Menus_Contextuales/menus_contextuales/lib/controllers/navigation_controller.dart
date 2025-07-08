import 'package:flutter/material.dart';

/// Controlador para manejar la navegación entre pantallas
class NavigationController {
  static final NavigationController _instance = NavigationController._internal();
  factory NavigationController() => _instance;
  NavigationController._internal();

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Obtener el contexto actual
  BuildContext? get currentContext => navigatorKey.currentContext;

  /// Navegar a una nueva pantalla
  Future<T?> navigateTo<T>(Widget screen) async {
    if (currentContext != null) {
      return await Navigator.of(currentContext!).push<T>(
        MaterialPageRoute(builder: (context) => screen),
      );
    }
    return null;
  }

  /// Navegar y reemplazar la pantalla actual
  Future<T?> navigateAndReplace<T>(Widget screen) async {
    if (currentContext != null) {
      return await Navigator.of(currentContext!).pushReplacement<T, dynamic>(
        MaterialPageRoute(builder: (context) => screen),
      );
    }
    return null;
  }

  /// Navegar y limpiar el stack
  Future<T?> navigateAndClearStack<T>(Widget screen) async {
    if (currentContext != null) {
      return await Navigator.of(currentContext!).pushAndRemoveUntil<T>(
        MaterialPageRoute(builder: (context) => screen),
        (route) => false,
      );
    }
    return null;
  }

  /// Regresar a la pantalla anterior
  void goBack<T>([T? result]) {
    if (currentContext != null && Navigator.of(currentContext!).canPop()) {
      Navigator.of(currentContext!).pop(result);
    }
  }

  /// Mostrar un diálogo
  Future<T?> showCustomDialog<T>(Widget dialog) async {
    if (currentContext != null) {
      return await showDialog<T>(
        context: currentContext!,
        builder: (context) => dialog,
      );
    }
    return null;
  }

  /// Mostrar un SnackBar
  void showSnackBar(String message, {Color? backgroundColor, Duration? duration}) {
    if (currentContext != null) {
      ScaffoldMessenger.of(currentContext!).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          duration: duration ?? const Duration(seconds: 3),
        ),
      );
    }
  }

  /// Mostrar un diálogo de error
  void showErrorDialog(String title, String message) {
    if (currentContext != null) {
      showDialog(
        context: currentContext!,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  /// Mostrar un diálogo de confirmación
  Future<bool?> showConfirmationDialog(String title, String message) async {
    if (currentContext != null) {
      return await showDialog<bool>(
        context: currentContext!,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirmar'),
            ),
          ],
        ),
      );
    }
    return null;
  }
}
