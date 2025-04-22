import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:papacapim/providers/auth_provider.dart';
import 'package:papacapim/screens/login_screen.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: context.read<AuthProvider>().user?['name'],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        actions: [
          Consumer<AuthProvider>(
            builder: (context, auth, child) {
              if (auth.isLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              return TextButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      await auth.updateProfile(
                        _nameController.text,
                        password: _passwordController.text.isNotEmpty
                            ? _passwordController.text
                            : null,
                      );
                      if (mounted) {
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      setState(() {
                        _errorMessage = e.toString();
                      });
                    }
                  }
                },
                child: const Text('Salvar'),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira seu nome';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Nova Senha (opcional)',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirmar Nova Senha',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (_passwordController.text.isNotEmpty &&
                      value != _passwordController.text) {
                    return 'As senhas não coincidem';
                  }
                  return null;
                },
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
              const SizedBox(height: 24),
              Consumer<AuthProvider>(
                builder: (context, auth, child) {
                  if (auth.isLoading) {
                    return const CircularProgressIndicator();
                  }
                  return ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Excluir conta'),
                          content: const Text(
                            'Tem certeza que deseja excluir sua conta? Esta ação não pode ser desfeita.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () async {
                                try {
                                  await auth.deleteAccount();
                                  if (mounted) {
                                    Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                        builder: (context) => const LoginScreen(),
                                      ),
                                      (route) => false,
                                    );
                                  }
                                } catch (e) {
                                  setState(() {
                                    _errorMessage = e.toString();
                                  });
                                  Navigator.pop(context);
                                }
                              },
                              child: const Text(
                                'Excluir',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text(
                      'Excluir Conta',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
} 