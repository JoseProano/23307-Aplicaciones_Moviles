import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/auth_viewmodel.dart';
import '../../../models/user_model.dart';
import '../../../utils/app_theme.dart';
import '../../../utils/format_utils.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    _nameController = TextEditingController(text: authViewModel.currentUser?.name ?? '');
    _phoneController = TextEditingController(text: authViewModel.currentUser?.phone ?? '');
    _addressController = TextEditingController(text: authViewModel.currentUser?.address ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuthViewModel>(
        builder: (context, authViewModel, child) {
          final user = authViewModel.currentUser;
          
          if (user == null) {
            return const Center(
              child: Text('No se pudo cargar la información del usuario'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Avatar del usuario
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppBorderRadius.circle),
                    ),
                    child: Center(
                      child: Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                        style: AppTextStyles.h1.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: AppSpacing.lg),
                  
                  // Información del usuario
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Información Personal',
                                style: AppTextStyles.h5,
                              ),
                              const Spacer(),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _isEditing = !_isEditing;
                                    if (!_isEditing) {
                                      // Resetear valores si se cancela la edición
                                      _nameController.text = user.name;
                                      _phoneController.text = user.phone ?? '';
                                      _addressController.text = user.address ?? '';
                                    }
                                  });
                                },
                                icon: Icon(
                                  _isEditing ? Icons.close : Icons.edit,
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: AppSpacing.md),
                          
                          // Campo de nombre
                          TextFormField(
                            controller: _nameController,
                            enabled: _isEditing,
                            decoration: const InputDecoration(
                              labelText: 'Nombre completo',
                              prefixIcon: Icon(Icons.person),
                            ),
                            validator: (value) => ValidationUtils.validateRequired(value, 'Nombre'),
                          ),
                          
                          const SizedBox(height: AppSpacing.md),
                          
                          // Campo de email (solo lectura)
                          TextFormField(
                            initialValue: user.email,
                            enabled: false,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email),
                            ),
                          ),
                          
                          const SizedBox(height: AppSpacing.md),
                          
                          // Campo de teléfono
                          TextFormField(
                            controller: _phoneController,
                            enabled: _isEditing,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Teléfono',
                              prefixIcon: Icon(Icons.phone),
                            ),
                            validator: ValidationUtils.validatePhone,
                          ),
                          
                          const SizedBox(height: AppSpacing.md),
                          
                          // Campo de dirección
                          TextFormField(
                            controller: _addressController,
                            enabled: _isEditing,
                            maxLines: 2,
                            decoration: const InputDecoration(
                              labelText: 'Dirección',
                              prefixIcon: Icon(Icons.location_on),
                            ),
                          ),
                          
                          if (_isEditing) ...[
                            const SizedBox(height: AppSpacing.lg),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: authViewModel.isLoading ? null : _saveProfile,
                                child: authViewModel.isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            AppColors.white,
                                          ),
                                        ),
                                      )
                                    : const Text('Guardar Cambios'),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: AppSpacing.lg),
                  
                  // Información adicional
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Información de Cuenta',
                            style: AppTextStyles.h5,
                          ),
                          
                          const SizedBox(height: AppSpacing.md),
                          
                          ListTile(
                            leading: const Icon(Icons.calendar_today),
                            title: const Text('Miembro desde'),
                            subtitle: Text(
                              FormatUtils.formatDate(user.createdAt),
                            ),
                            contentPadding: EdgeInsets.zero,
                          ),
                          
                          ListTile(
                            leading: const Icon(Icons.verified_user),
                            title: const Text('Estado de la cuenta'),
                            subtitle: const Text('Verificada'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: AppSpacing.lg),
                  
                  // Opciones adicionales
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.lock),
                          title: const Text('Cambiar Contraseña'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: _showChangePasswordDialog,
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.help),
                          title: const Text('Ayuda y Soporte'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: _showHelpDialog,
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.privacy_tip),
                          title: const Text('Política de Privacidad'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: _showPrivacyDialog,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      final currentUser = authViewModel.currentUser!;
      
      final updatedUser = currentUser.copyWith(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
      );

      bool success = await authViewModel.updateProfile(updatedUser);
      
      if (success && mounted) {
        setState(() {
          _isEditing = false;
        });
        _showSnackBar('Perfil actualizado exitosamente');
      } else if (mounted) {
        _showSnackBar(authViewModel.errorMessage);
      }
    }
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar Contraseña'),
        content: const Text(
          'Para cambiar tu contraseña, se enviará un enlace de restablecimiento a tu email.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          Consumer<AuthViewModel>(
            builder: (context, authViewModel, child) {
              return TextButton(
                onPressed: authViewModel.isLoading
                    ? null
                    : () async {
                        bool success = await authViewModel.resetPassword(
                          authViewModel.currentUser!.email,
                        );
                        
                        if (mounted) {
                          Navigator.of(context).pop();
                          
                          if (success) {
                            _showSnackBar('Se ha enviado un enlace a tu email');
                          } else {
                            _showSnackBar(authViewModel.errorMessage);
                          }
                        }
                      },
                child: authViewModel.isLoading
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Enviar'),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ayuda y Soporte'),
        content: const Text(
          'Si necesitas ayuda o tienes alguna pregunta, puedes contactarnos a través de:\n\n'
          '• Email: soporte@tiendalocal.com\n'
          '• Teléfono: +1234567890\n'
          '• WhatsApp: +1234567890\n\n'
          'Nuestro horario de atención es de lunes a viernes de 9:00 AM a 6:00 PM.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Política de Privacidad'),
        content: const SingleChildScrollView(
          child: Text(
            'Respetamos tu privacidad y nos comprometemos a proteger tus datos personales.\n\n'
            'Información que recopilamos:\n'
            '• Información de cuenta (nombre, email)\n'
            '• Información de contacto (teléfono, dirección)\n'
            '• Historial de pedidos\n\n'
            'Uso de la información:\n'
            '• Procesar tus pedidos\n'
            '• Mejorar nuestros servicios\n'
            '• Comunicarnos contigo\n\n'
            'No compartimos tu información con terceros sin tu consentimiento.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
