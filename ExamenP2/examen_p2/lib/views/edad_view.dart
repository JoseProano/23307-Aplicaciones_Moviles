import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../view_models/edad_view_model.dart';

class EdadView extends StatefulWidget {
  final EdadViewModel viewModel;

  const EdadView({super.key, required this.viewModel});

  @override
  State<EdadView> createState() => _EdadViewState();
}

class _EdadViewState extends State<EdadView> {
  DateTime? _fechaSeleccionada;
  final DateFormat _formatoFecha = DateFormat('dd/MM/yyyy', 'es_ES');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculadora de Edad'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Fecha de Nacimiento',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _fechaSeleccionada == null
                                ? 'Selecciona tu fecha de nacimiento'
                                : 'Fecha: ${_formatoFecha.format(_fechaSeleccionada!)}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _seleccionarFecha,
                          child: const Text('Seleccionar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fechaSeleccionada == null
                  ? null
                  : () => widget.viewModel.calcularEdad(_fechaSeleccionada!),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Calcular Edad', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 20),
            AnimatedBuilder(
              animation: widget.viewModel,
              builder: (context, child) {
                if (widget.viewModel.error.isNotEmpty) {
                  return Card(
                    color: Colors.red.shade100,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        widget.viewModel.error,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    ),
                  );
                }

                if (widget.viewModel.edad != null) {
                  final edad = widget.viewModel.edad!;
                  return Card(
                    color: Colors.green.shade100,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tu edad es:',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '${edad.anios} años, ${edad.meses} meses y ${edad.dias} días',
                            style: const TextStyle(fontSize: 20, color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (fecha != null) {
      setState(() {
        _fechaSeleccionada = fecha;
      });
    }
  }
}
