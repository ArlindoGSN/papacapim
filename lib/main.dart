import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:papacapim/screens/login_screen.dart';
import 'package:papacapim/providers/auth_provider.dart';
import 'package:papacapim/providers/posts_provider.dart';
import 'package:papacapim/providers/profile_provider.dart';

void main() {
  runApp(const PapacapimApp());
}

class PapacapimApp extends StatelessWidget {
  const PapacapimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PostsProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: MaterialApp(
        title: 'Papacapim',
        theme: ThemeData(
          primarySwatch: Colors.green,
          useMaterial3: true,
        ),
        home: const LoginScreen(),
      ),
    );
  }
}
