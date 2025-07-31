import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/estudiante.dart';
import '../viewmodels/estudiante_viewmodel.dart';

class CrearEditarEstudianteView extends StatefulWidget {
  final Estudiante? estudiante;

  const CrearEditarEstudianteView({
    super.key,
    this.estudiante,
  });

  @override
  State<CrearEditarEstudianteView> createState() => _CrearEditarEstudianteViewState();
}

class _CrearEditarEstudianteViewState extends State<CrearEditarEstudianteView> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _edadController = TextEditingController();
  final _carreraController = TextEditingController();
  final _emailController = TextEditingController();

  bool get _esEdicion => widget.estudiante != null;

  @override
  void initState() {
    super.initState();
    if (_esEdicion) {
      _nombreController.text = widget.estudiante!.nombre;
      _edadController.text = widget.estudiante!.edad.toString();
      _carreraController.text = widget.estudiante!.carrera;
      _emailController.text = widget.estudiante!.email;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _edadController.dispose();
    _carreraController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_esEdicion ? 'Editar Estudiante' : 'Nuevo Estudiante'),
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
                      'Información Personal',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nombreController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre completo',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El nombre es requerido';
                        }
                        if (value.trim().length < 2) {
                          return 'El nombre debe tener al menos 2 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _edadController,
                      decoration: const InputDecoration(
                        labelText: 'Edad',
                        prefixIcon: Icon(Icons.cake),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'La edad es requerida';
                        }
                        int? edad = int.tryParse(value);
                        if (edad == null) {
                          return 'Ingrese una edad válida';
                        }
                        if (edad < 15 || edad > 100) {
                          return 'La edad debe estar entre 15 y 100 años';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _carreraController,
                      decoration: const InputDecoration(
                        labelText: 'Carrera',
                        prefixIcon: Icon(Icons.school),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'La carrera es requerida';
                        }
                        if (value.trim().length < 3) {
                          return 'La carrera debe tener al menos 3 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El email es requerido';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value)) {
                          return 'Ingrese un email válido';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Consumer<EstudianteViewModel>(
              builder: (context, viewModel, child) {
                return ElevatedButton(
                  onPressed: viewModel.isLoading ? null : _guardarEstudiante,
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
                          _esEdicion ? 'Actualizar Estudiante' : 'Crear Estudiante',
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

  Future<void> _guardarEstudiante() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final viewModel = context.read<EstudianteViewModel>();

    final estudiante = Estudiante(
      id: _esEdicion ? widget.estudiante!.id : null,
      nombre: _nombreController.text.trim(),
      edad: int.parse(_edadController.text),
      carrera: _carreraController.text.trim(),
      email: _emailController.text.trim(),
      fechaRegistro: _esEdicion 
          ? widget.estudiante!.fechaRegistro 
          : DateTime.now(),
    );

    bool success;
    if (_esEdicion) {
      success = await viewModel.actualizarEstudiante(
        widget.estudiante!.id!,
        estudiante,
      );
    } else {
      success = await viewModel.crearEstudiante(estudiante);
    }

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _esEdicion 
                  ? 'Estudiante actualizado correctamente'
                  : 'Estudiante creado correctamente',
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
                  ? 'Error al actualizar estudiante'
                  : 'Error al crear estudiante'),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
