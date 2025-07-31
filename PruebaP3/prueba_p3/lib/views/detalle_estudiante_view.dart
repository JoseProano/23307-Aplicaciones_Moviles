import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/estudiante.dart';
import '../models/nota.dart';
import '../viewmodels/estudiante_viewmodel.dart';
import '../widgets/nota_card.dart';
import '../widgets/common_widgets.dart';
import 'crear_editar_nota_view.dart';

class DetalleEstudianteView extends StatefulWidget {
  final Estudiante estudiante;

  const DetalleEstudianteView({
    super.key,
    required this.estudiante,
  });

  @override
  State<DetalleEstudianteView> createState() => _DetalleEstudianteViewState();
}

class _DetalleEstudianteViewState extends State<DetalleEstudianteView> {
  double _promedio = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<EstudianteViewModel>();
      viewModel.seleccionarEstudiante(widget.estudiante);
      _cargarPromedio();
    });
  }

  Future<void> _cargarPromedio() async {
    final viewModel = context.read<EstudianteViewModel>();
    final promedio = await viewModel.obtenerPromedioEstudiante(widget.estudiante.id!);
    if (mounted) {
      setState(() {
        _promedio = promedio;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.estudiante.nombre),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _cargarPromedio(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Información del estudiante
            Container(
              width: double.infinity,
              color: Theme.of(context).primaryColor,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Text(
                            widget.estudiante.nombre[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.estudiante.nombre,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.estudiante.carrera,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoCard(
                                'Edad',
                                '${widget.estudiante.edad} años',
                                Icons.cake,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildInfoCard(
                                'Promedio',
                                _promedio > 0 ? _promedio.toStringAsFixed(1) : 'N/A',
                                Icons.grade,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildInfoCard(
                          'Email',
                          widget.estudiante.email,
                          Icons.email,
                          fullWidth: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Lista de notas
            Expanded(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.note,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Notas',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: () => _navegarACrearNota(),
                          icon: const Icon(Icons.add),
                          label: const Text('Agregar'),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Consumer<EstudianteViewModel>(
                      builder: (context, viewModel, child) {
                        if (viewModel.isLoading) {
                          return const LoadingWidget(message: 'Cargando notas...');
                        }

                        if (viewModel.errorMessage != null) {
                          return CustomErrorWidget(
                            message: viewModel.errorMessage!,
                            onRetry: () => viewModel.seleccionarEstudiante(widget.estudiante),
                          );
                        }

                        final notas = viewModel.notasEstudianteSeleccionado;

                        if (notas.isEmpty) {
                          return EmptyWidget(
                            message: 'No hay notas registradas',
                            icon: Icons.note_add,
                            actionText: 'Agregar Primera Nota',
                            onAction: () => _navegarACrearNota(),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.only(bottom: 16),
                          itemCount: notas.length,
                          itemBuilder: (context, index) {
                            final nota = notas[index];
                            return NotaCard(
                              nota: nota,
                              onEdit: () => _navegarAEditarNota(nota),
                              onDelete: () => _mostrarDialogoEliminarNota(nota),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String titulo, String valor, IconData icono, {bool fullWidth = false}) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            icono,
            color: Theme.of(context).primaryColor,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            titulo,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            valor,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _navegarACrearNota() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CrearEditarNotaView(
          estudianteId: widget.estudiante.id!,
        ),
      ),
    ).then((_) => _cargarPromedio());
  }

  void _navegarAEditarNota(Nota nota) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CrearEditarNotaView(
          estudianteId: widget.estudiante.id!,
          nota: nota,
        ),
      ),
    ).then((_) => _cargarPromedio());
  }

  void _mostrarDialogoEliminarNota(Nota nota) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Nota'),
        content: Text(
          '¿Estás seguro de que deseas eliminar la nota de ${nota.materia}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final viewModel = context.read<EstudianteViewModel>();
              bool success = await viewModel.eliminarNota(
                widget.estudiante.id!,
                nota.id!,
              );
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success 
                          ? 'Nota eliminada correctamente'
                          : 'Error al eliminar nota',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
                if (success) {
                  _cargarPromedio();
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
