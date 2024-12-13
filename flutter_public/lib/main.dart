import 'package:flutter/material.dart';
import 'package:sport_app/handlers/auth_handler.dart';
import 'package:sport_app/pages/home_page.dart';
import 'package:sport_app/pages/login_page.dart';
import 'package:sport_app/pages/postlogin_page.dart';
import 'package:sport_app/pages/profile_page.dart';
import 'package:sport_app/pages/scores_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomePage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/profile': (context) => const ProfilePage(),
        '/scores': (context) => const ScoresPage(),
        '/postloginpage': (context) => const PostloginPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}

class CheckAuthPage extends StatelessWidget {
  final AuthHandler _authHandler = AuthHandler();

  CheckAuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _authHandler.getToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (snapshot.hasData && snapshot.data != null) {
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/home');
              }
            } else {
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            }
          });
          return const SizedBox();
        }
      },
    );
  }
}
