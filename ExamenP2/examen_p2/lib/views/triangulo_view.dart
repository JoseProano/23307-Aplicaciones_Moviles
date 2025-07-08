import 'package:flutter/material.dart';
import '../view_models/triangulo_view_model.dart';
import '../models/triangulo_model.dart';

class TrianguloView extends StatefulWidget {
  final TrianguloViewModel viewModel;

  const TrianguloView({super.key, required this.viewModel});

  @override
  State<TrianguloView> createState() => _TrianguloViewState();
}

class _TrianguloViewState extends State<TrianguloView> {
  final _lado1Controller = TextEditingController();
  final _lado2Controller = TextEditingController();
  final _lado3Controller = TextEditingController();

  @override
  void dispose() {
    _lado1Controller.dispose();
    _lado2Controller.dispose();
    _lado3Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analizador de Triángulos'),
        backgroundColor: Colors.green,
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
                      'Ingresa los lados del triángulo',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _lado1Controller,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Lado 1',
                        border: OutlineInputBorder(),
                        hintText: 'Ingresa el primer lado',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _lado2Controller,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Lado 2',
                        border: OutlineInputBorder(),
                        hintText: 'Ingresa el segundo lado',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _lado3Controller,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Lado 3',
                        border: OutlineInputBorder(),
                        hintText: 'Ingresa el tercer lado',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _analizarTriangulo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Analizar', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _limpiarCampos,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Limpiar', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
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

                if (widget.viewModel.triangulo != null) {
                  final triangulo = widget.viewModel.triangulo!;
                  final esValido = triangulo.tipo != TipoTriangulo.invalido;
                  
                  return Card(
                    color: esValido ? Colors.green.shade100 : Colors.orange.shade100,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Resultado del Análisis',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: esValido ? Colors.green : Colors.orange,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Lados: ${triangulo.lado1}, ${triangulo.lado2}, ${triangulo.lado3}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tipo: ${widget.viewModel.obtenerDescripcionTipo(triangulo.tipo)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: esValido ? Colors.green : Colors.orange,
                            ),
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

  void _analizarTriangulo() {
    widget.viewModel.analizarTriangulo(
      _lado1Controller.text,
      _lado2Controller.text,
      _lado3Controller.text,
    );
  }

  void _limpiarCampos() {
    _lado1Controller.clear();
    _lado2Controller.clear();
    _lado3Controller.clear();
    widget.viewModel.limpiar();
  }
}
