import 'package:flutter/material.dart';
import 'package:papacapim/services/user_service.dart';
import 'package:papacapim/theme/form_styles.dart'; // Adicionar esta linha

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _loginController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _loginController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await UserService.createUser( // Atualizado para usar UserService
        _loginController.text,
        _nameController.text,
        _passwordController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conta criada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage =
              'Não foi possível criar a conta. O login pode já estar em uso.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Criar Conta',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Hero(
                  tag: 'app_logo',
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: theme.colorScheme.primary,
                    child: Icon(
                      Icons.nature,
                      size: 40,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _loginController,
                  decoration: FormStyles.inputDecoration(
                    label: 'Login',
                    icon: Icons.person_outline,
                    hint: 'Digite seu login',
                  ),
                  enabled: !_isLoading,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira um login';
                    }
                    if (value.length < 3) {
                      return 'O login deve ter pelo menos 3 caracteres';
                    }
                    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                      return 'Use apenas letras, números e underscore';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: FormStyles.inputDecoration(
                    label: 'Nome Completo',
                    icon: Icons.badge_outlined,
                    hint: 'Digite seu nome completo',
                  ),
                  enabled: !_isLoading,
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira seu nome';
                    }
                    if (value.trim().split(' ').length < 2) {
                      return 'Digite seu nome completo';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: FormStyles.inputDecoration(
                    label: 'Senha',
                    icon: Icons.lock_outline,
                    hint: '********',
                  ),
                  enabled: !_isLoading,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira uma senha';
                    }
                    if (value.length < 6) {
                      return 'A senha deve ter pelo menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: FormStyles.inputDecoration(
                    label: 'Confirmar Senha',
                    icon: Icons.lock_outline,
                    hint: '********',
                  ),
                  enabled: !_isLoading,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, confirme sua senha';
                    }
                    if (value != _passwordController.text) {
                      return 'As senhas não coincidem';
                    }
                    return null;
                  },
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: theme.colorScheme.error,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                ElevatedButton(
                  style: FormStyles.elevatedButtonStyle(context),
                  onPressed: _isLoading ? null : _register,
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(),
                        )
                      : const Text('CRIAR CONTA'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
