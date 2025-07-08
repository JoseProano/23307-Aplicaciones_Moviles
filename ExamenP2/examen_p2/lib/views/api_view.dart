import 'package:flutter/material.dart';
import '../view_models/api_view_model.dart';
import '../models/usuario_model.dart';

class ApiView extends StatefulWidget {
  final ApiViewModel viewModel;

  const ApiView({super.key, required this.viewModel});

  @override
  State<ApiView> createState() => _ApiViewState();
}

class _ApiViewState extends State<ApiView> {
  @override
  void initState() {
    super.initState();
    // Cargar datos al inicializar la vista
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.viewModel.cargarUsuarios();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuarios API'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => widget.viewModel.cargarUsuarios(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: widget.viewModel,
        builder: (context, child) {
          if (widget.viewModel.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando usuarios...'),
                ],
              ),
            );
          }

          if (widget.viewModel.error.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar datos',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      widget.viewModel.error,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => widget.viewModel.cargarUsuarios(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (widget.viewModel.usuarios.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No hay usuarios disponibles',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => widget.viewModel.cargarUsuarios(),
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: widget.viewModel.usuarios.length,
              itemBuilder: (context, index) {
                final usuario = widget.viewModel.usuarios[index];
                return _buildUsuarioCard(usuario);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildUsuarioCard(Usuario usuario) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.purple,
          child: Text(
            usuario.name.isNotEmpty ? usuario.name[0].toUpperCase() : '?',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          usuario.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('@${usuario.username}'),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.email, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(child: Text(usuario.email, style: const TextStyle(fontSize: 12))),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.phone, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(child: Text(usuario.phone, style: const TextStyle(fontSize: 12))),
              ],
            ),
            if (usuario.website.isNotEmpty) ...[
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(Icons.web, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(child: Text(usuario.website, style: const TextStyle(fontSize: 12))),
                ],
              ),
            ],
          ],
        ),
        isThreeLine: true,
        onTap: () => _mostrarDetallesUsuario(usuario),
      ),
    );
  }

  void _mostrarDetallesUsuario(Usuario usuario) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(usuario.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('ID', usuario.id.toString()),
            _buildDetailRow('Usuario', usuario.username),
            _buildDetailRow('Email', usuario.email),
            _buildDetailRow('Teléfono', usuario.phone),
            if (usuario.website.isNotEmpty)
              _buildDetailRow('Sitio Web', usuario.website),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
