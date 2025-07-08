import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/auth_viewmodel.dart';
import '../../../utils/app_theme.dart';
import '../../../utils/format_utils.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      
      bool success = await authViewModel.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!success && mounted) {
        _showErrorSnackBar(authViewModel.errorMessage);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.xxl),
                
                // Logo o título
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppBorderRadius.circle),
                  ),
                  child: const Icon(
                    Icons.store,
                    size: AppConstants.iconXLarge,
                    color: AppColors.white,
                  ),
                ),
                
                const SizedBox(height: AppSpacing.xl),
                
                Text(
                  'Bienvenido',
                  style: AppTextStyles.h2,
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: AppSpacing.sm),
                
                Text(
                  'Inicia sesión para continuar',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: AppSpacing.xl),
                
                // Campo de email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: ValidationUtils.validateEmail,
                ),
                
                const SizedBox(height: AppSpacing.md),
                
                // Campo de contraseña
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: ValidationUtils.validatePassword,
                ),
                
                const SizedBox(height: AppSpacing.lg),
                
                // Botón de login
                Consumer<AuthViewModel>(
                  builder: (context, authViewModel, child) {
                    return ElevatedButton(
                      onPressed: authViewModel.isLoading ? null : _handleLogin,
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
                          : const Text('Iniciar Sesión'),
                    );
                  },
                ),
                
                const SizedBox(height: AppSpacing.md),
                
                // Enlace para registro
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '¿No tienes cuenta? ',
                      style: AppTextStyles.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: const Text('Regístrate'),
                    ),
                  ],
                ),
                
                const SizedBox(height: AppSpacing.md),
                
                // Enlace para olvidé contraseña
                TextButton(
                  onPressed: () {
                    _showForgotPasswordDialog();
                  },
                  child: const Text('¿Olvidaste tu contraseña?'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restablecer Contraseña'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Ingresa tu email para recibir un enlace de restablecimiento',
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
          ],
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
                        if (emailController.text.trim().isNotEmpty) {
                          bool success = await authViewModel.resetPassword(
                            emailController.text.trim(),
                          );
                          
                          if (mounted) {
                            Navigator.of(context).pop();
                            
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Se ha enviado un enlace de restablecimiento a tu email',
                                  ),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            } else {
                              _showErrorSnackBar(authViewModel.errorMessage);
                            }
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
}
