import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/estudiante_viewmodel.dart';
import '../widgets/estudiante_card.dart';
import '../widgets/common_widgets.dart';
import 'crear_editar_estudiante_view.dart';
import 'detalle_estudiante_view.dart';

class EstudiantesView extends StatefulWidget {
  const EstudiantesView({super.key});

  @override
  State<EstudiantesView> createState() => _EstudiantesViewState();
}

class _EstudiantesViewState extends State<EstudiantesView> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EstudianteViewModel>().cargarEstudiantes();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estudiantes'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<EstudianteViewModel>().refrescar();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Container(
            color: Theme.of(context).primaryColor,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre o edad...',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              context.read<EstudianteViewModel>().limpiarFiltros();
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    // Cancelar el timer anterior
                    _debounceTimer?.cancel();
                    
                    if (value.isEmpty) {
                      context.read<EstudianteViewModel>().limpiarFiltros();
                    } else {
                      // Crear un nuevo timer para la búsqueda con delay
                      _debounceTimer = Timer(const Duration(milliseconds: 500), () {
                        context.read<EstudianteViewModel>().buscarEstudiantes(value);
                      });
                    }
                    
                    // Actualizar el estado para mostrar/ocultar el botón clear
                    setState(() {});
                  },
                  onSubmitted: (value) {
                    context.read<EstudianteViewModel>().buscarEstudiantes(value);
                  },
                ),
                const SizedBox(height: 12),
                // Filtros activos
                Consumer<EstudianteViewModel>(
                  builder: (context, viewModel, child) {
                    bool tienesFiltros = viewModel.filtroNombre.isNotEmpty ||
                        viewModel.filtroEdad != null;

                    if (!tienesFiltros) return const SizedBox.shrink();

                    return Container(
                      width: double.infinity,
                      child: Wrap(
                        spacing: 8,
                        children: [
                          if (viewModel.filtroNombre.isNotEmpty)
                            Chip(
                              label: Text('Nombre: ${viewModel.filtroNombre}'),
                              backgroundColor: Colors.white.withOpacity(0.9),
                              deleteIcon: const Icon(Icons.close, size: 18),
                              onDeleted: () {
                                _searchController.clear();
                                viewModel.setFiltroNombre('');
                                viewModel.cargarEstudiantes();
                              },
                            ),
                          if (viewModel.filtroEdad != null)
                            Chip(
                              label: Text('Edad: ${viewModel.filtroEdad}'),
                              backgroundColor: Colors.white.withOpacity(0.9),
                              deleteIcon: const Icon(Icons.close, size: 18),
                              onDeleted: () {
                                _searchController.clear();
                                viewModel.setFiltroEdad(null);
                                viewModel.cargarEstudiantes();
                              },
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          // Lista de estudiantes
          Expanded(
            child: Consumer<EstudianteViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading && viewModel.estudiantes.isEmpty) {
                  return const LoadingWidget(message: 'Cargando estudiantes...');
                }

                if (viewModel.errorMessage != null) {
                  return CustomErrorWidget(
                    message: viewModel.errorMessage!,
                    onRetry: () => viewModel.cargarEstudiantes(),
                  );
                }

                if (viewModel.estudiantes.isEmpty) {
                  return EmptyWidget(
                    message: 'No hay estudiantes registrados',
                    icon: Icons.school,
                    actionText: 'Agregar Estudiante',
                    onAction: () => _navegarACrearEstudiante(),
                  );
                }

                return Column(
                  children: [
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () => viewModel.refrescar(),
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: viewModel.estudiantes.length,
                          itemBuilder: (context, index) {
                            final estudiante = viewModel.estudiantes[index];
                            return EstudianteCard(
                              estudiante: estudiante,
                              onTap: () => _navegarADetalleEstudiante(estudiante),
                              onEdit: () => _navegarAEditarEstudiante(estudiante),
                              onDelete: () => _mostrarDialogoEliminar(estudiante),
                            );
                          },
                        ),
                      ),
                    ),
                    // Controles de paginación
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        border: Border(
                          top: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Botón página anterior
                            IconButton(
                              onPressed: viewModel.paginaActual > 1 && !viewModel.isLoading
                                  ? () => _irAPaginaAnterior()
                                  : null,
                              icon: const Icon(Icons.arrow_back_ios),
                              style: IconButton.styleFrom(
                                backgroundColor: viewModel.paginaActual > 1 && !viewModel.isLoading
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey[300],
                                foregroundColor: viewModel.paginaActual > 1 && !viewModel.isLoading
                                    ? Colors.white
                                    : Colors.grey[500],
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Información de página
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                'Página ${viewModel.paginaActual}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Botón página siguiente
                            IconButton(
                              onPressed: viewModel.tieneMasDatos && !viewModel.isLoading
                                  ? () => _irAPaginaSiguiente()
                                  : null,
                              icon: const Icon(Icons.arrow_forward_ios),
                              style: IconButton.styleFrom(
                                backgroundColor: viewModel.tieneMasDatos && !viewModel.isLoading
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey[300],
                                foregroundColor: viewModel.tieneMasDatos && !viewModel.isLoading
                                    ? Colors.white
                                    : Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navegarACrearEstudiante,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _navegarACrearEstudiante() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CrearEditarEstudianteView(),
      ),
    );
  }

  void _navegarAEditarEstudiante(estudiante) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CrearEditarEstudianteView(estudiante: estudiante),
      ),
    );
  }

  void _navegarADetalleEstudiante(estudiante) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetalleEstudianteView(estudiante: estudiante),
      ),
    );
  }

  void _irAPaginaAnterior() {
    final viewModel = context.read<EstudianteViewModel>();
    viewModel.irAPaginaAnterior();
  }

  void _irAPaginaSiguiente() {
    final viewModel = context.read<EstudianteViewModel>();
    viewModel.irAPaginaSiguiente();
  }

  void _mostrarDialogoEliminar(estudiante) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Estudiante'),
        content: Text(
          '¿Estás seguro de que deseas eliminar a ${estudiante.nombre}? '
          'Esta acción también eliminará todas sus notas.',
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
              bool success = await viewModel.eliminarEstudiante(estudiante.id!);
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success 
                          ? 'Estudiante eliminado correctamente'
                          : 'Error al eliminar estudiante',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
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
