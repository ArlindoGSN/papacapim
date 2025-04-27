import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:papacapim/screens/login_screen.dart';
import 'package:papacapim/screens/feed_screen.dart';
import 'package:papacapim/providers/auth_provider.dart';
import 'package:papacapim/providers/posts_provider.dart';
import 'package:papacapim/providers/profile_provider.dart';
import 'package:papacapim/providers/post_details_provider.dart';
import 'package:timeago/timeago.dart' as timeago;

void main() {
  // Configura a localização em português
  timeago.setLocaleMessages('pt_BR', timeago.PtBrMessages());
  timeago.setDefaultLocale('pt_BR');

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
        ChangeNotifierProvider(create: (_) => PostDetailsProvider()),
      ],
      child: MaterialApp(
        title: 'Papacapim',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
          useMaterial3: true,
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/feed': (context) => const FeedScreen(),
        },
        onGenerateRoute: (settings) {
          // Redireciona qualquer rota não encontrada para login
          return MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          );
        },
      ),
    );
  }
}
