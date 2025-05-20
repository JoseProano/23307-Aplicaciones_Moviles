import 'package:flutter/material.dart';
import '../controllers/boleto_controller.dart';

class ResultadoView extends StatelessWidget {
  final int numeroBoleto;

  const ResultadoView({required this.numeroBoleto, super.key});

  @override
  Widget build(BuildContext context) {
    final BoletoController boletoController = BoletoController();
    final bool esValido = boletoController.validarBoleto(numeroBoleto);

    return Scaffold(
      appBar: AppBar(
        title: Text('Resultado'),
        centerTitle: true,
      ),
      body: Center(
        child: Card(
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          margin: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: esValido
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                      : Theme.of(context).colorScheme.error.withOpacity(0.1),
                  child: Icon(
                    esValido ? Icons.check_circle : Icons.cancel,
                    size: 64,
                    color: esValido
                        ? Colors.green // Verde cuando es válido
                        : Theme.of(context).colorScheme.error, // Rojo cuando es inválido
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  'El boleto ingresado es:',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Text(
                  '$numeroBoleto',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  esValido ? '¡VÁLIDO!' : 'INVÁLIDO',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: esValido
                        ? Colors.green // Verde cuando es válido
                        : Theme.of(context).colorScheme.error, // Rojo cuando es inválido
                    letterSpacing: 2,
                  ),
                ),
                SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back),
                    label: Text('Regresar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}