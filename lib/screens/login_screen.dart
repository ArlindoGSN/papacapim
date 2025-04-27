import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:papacapim/screens/register_screen.dart';
import 'package:papacapim/screens/feed_screen.dart';
import 'package:papacapim/providers/auth_provider.dart';
import 'package:papacapim/theme/form_styles.dart'; // Adicionar esta linha

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 48),
                Hero(
                  tag: 'app_logo',
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: theme.colorScheme.primary,
                    child: Icon(
                      Icons.nature,
                      size: 50,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Papacapim',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 48),
                TextFormField(
                  controller: _loginController,
                  decoration: FormStyles.inputDecoration(
                    label: 'Login',
                    icon: Icons.person_outline,
                    hint: 'Digite seu login',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira seu login';
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
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira sua senha';
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
                Consumer<AuthProvider>(
                  builder: (context, auth, child) {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: FormStyles.elevatedButtonStyle(context),
                        onPressed: auth.isLoading
                            ? null
                            : () async {
                                if (_formKey.currentState!.validate()) {
                                  try {
                                    await auth.login(
                                      _loginController.text,
                                      _passwordController.text,
                                    );
                                    if (mounted) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const FeedScreen(),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    setState(() {
                                      _errorMessage = 'Falha ao fazer login. Verifique suas credenciais.';
                                    });
                                  }
                                }
                              },
                        child: auth.isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(),
                              )
                            : const Text('ENTRAR'),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.person_add_outlined),
                  label: const Text('Criar nova conta'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}