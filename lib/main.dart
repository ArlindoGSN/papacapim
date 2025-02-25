import 'package:flutter/material.dart';
import 'package:papacapim/screens/login_screen.dart';
import 'package:papacapim/screens/profile_screen.dart';
import 'package:papacapim/screens/register_screen.dart';

void main() {
  runApp(const PapacapimApp());
}

class PapacapimApp extends StatelessWidget {
  const PapacapimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Papacapim',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const RegisterScreen(),
    );
  }
}
