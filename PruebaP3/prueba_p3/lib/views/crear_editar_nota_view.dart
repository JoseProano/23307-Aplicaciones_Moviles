import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/nota.dart';
import '../viewmodels/estudiante_viewmodel.dart';

class CrearEditarNotaView extends StatefulWidget {
  final String estudianteId;
  final Nota? nota;

  const CrearEditarNotaView({
    super.key,
    required this.estudianteId,
    this.nota,
  });

  @override
  State<CrearEditarNotaView> createState() => _CrearEditarNotaViewState();
}

class _CrearEditarNotaViewState extends State<CrearEditarNotaView> {
  final _formKey = GlobalKey<FormState>();
  final _materiaController = TextEditingController();
  final _calificacionController = TextEditingController();
  final _descripcionController = TextEditingController();

  bool get _esEdicion => widget.nota != null;

  @override
  void initState() {
    super.initState();
    if (_esEdicion) {
      _materiaController.text = widget.nota!.materia;
      _calificacionController.text = widget.nota!.calificacion.toString();
      _descripcionController.text = widget.nota!.descripcion;
    }
  }

  @override
  void dispose() {
    _materiaController.dispose();
    _calificacionController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_esEdicion ? 'Editar Nota' : 'Nueva Nota'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información de la Nota',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _materiaController,
                      decoration: const InputDecoration(
                        labelText: 'Materia',
                        prefixIcon: Icon(Icons.subject),
                        border: OutlineInputBorder(),
                        hintText: 'Ej: Matemáticas, Historia, etc.',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'La materia es requerida';
                        }
                        if (value.trim().length < 2) {
                          return 'La materia debe tener al menos 2 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _calificacionController,
                      decoration: const InputDecoration(
                        labelText: 'Calificación (sobre 20)',
                        prefixIcon: Icon(Icons.grade),
                        border: OutlineInputBorder(),
                        hintText: 'Ej: 18.5',
                        suffixText: '/20',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'La calificación es requerida';
                        }
                        double? calificacion = double.tryParse(value);
                        if (calificacion == null) {
                          return 'Ingrese una calificación válida';
                        }
                        if (calificacion < 0 || calificacion > 20) {
                          return 'La calificación debe estar entre 0 y 20';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descripcionController,
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                        prefixIcon: Icon(Icons.description),
                        border: OutlineInputBorder(),
                        hintText: 'Descripción opcional de la evaluación',
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'La descripción es requerida';
                        }
                        if (value.trim().length < 5) {
                          return 'La descripción debe tener al menos 5 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    // Indicador visual de la calificación
                    if (_calificacionController.text.isNotEmpty)
                      _buildIndicadorCalificacion(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Consumer<EstudianteViewModel>(
              builder: (context, viewModel, child) {
                return ElevatedButton(
                  onPressed: viewModel.isLoading ? null : _guardarNota,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: viewModel.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          _esEdicion ? 'Actualizar Nota' : 'Crear Nota',
                          style: const TextStyle(fontSize: 16),
                        ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicadorCalificacion() {
    double? calificacion = double.tryParse(_calificacionController.text);
    if (calificacion == null) return const SizedBox.shrink();

    Color color;
    String texto;
    IconData icono;

    if (calificacion >= 9.0) {
      color = Colors.green;
      texto = 'Excelente';
      icono = Icons.sentiment_very_satisfied;
    } else if (calificacion >= 7.0) {
      color = Colors.orange;
      texto = 'Bueno';
      icono = Icons.sentiment_satisfied;
    } else if (calificacion >= 6.0) {
      color = Colors.yellow[700]!;
      texto = 'Regular';
      icono = Icons.sentiment_neutral;
    } else {
      color = Colors.red;
      texto = 'Necesita mejorar';
      icono = Icons.sentiment_dissatisfied;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icono, color: color),
          const SizedBox(width: 8),
          Text(
            texto,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              calificacion.toStringAsFixed(1),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _guardarNota() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final viewModel = context.read<EstudianteViewModel>();

    final nota = Nota(
      id: _esEdicion ? widget.nota!.id : null,
      materia: _materiaController.text.trim(),
      calificacion: double.parse(_calificacionController.text),
      descripcion: _descripcionController.text.trim(),
      fecha: _esEdicion ? widget.nota!.fecha : DateTime.now(),
    );

    bool success;
    if (_esEdicion) {
      success = await viewModel.actualizarNota(
        widget.estudianteId,
        widget.nota!.id!,
        nota,
      );
    } else {
      success = await viewModel.crearNota(widget.estudianteId, nota);
    }

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _esEdicion 
                  ? 'Nota actualizada correctamente'
                  : 'Nota creada correctamente',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              viewModel.errorMessage ?? 
              (_esEdicion 
                  ? 'Error al actualizar nota'
                  : 'Error al crear nota'),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
