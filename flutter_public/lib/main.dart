import 'package:flutter/material.dart';
import 'package:sport_app/handlers/auth_handler.dart';
import 'package:sport_app/pages/home_page.dart';
import 'package:sport_app/pages/login_page.dart';
import 'package:sport_app/pages/postlogin_page.dart';
import 'package:sport_app/pages/profile_page.dart';
import 'package:sport_app/pages/scores_page.dart';



void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
     return MaterialApp(
      home: HomePage(),
      routes: {
        '/login' : (context) => LoginPage(), 
        '/profile': (context) => ProfilePage(),
        '/scores' : (context) => ScoresPage(),
        '/postloginpage' : (context) => PostloginPage(), 
        '/home' : (context) => HomePage()
      },
    );
  }
}


class CheckAuthPage extends StatelessWidget {
  final AuthHandler _authHandler = AuthHandler();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _authHandler.getToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else {
          if (snapshot.hasData && snapshot.data != null) { 
            Future.microtask(() => Navigator.pushReplacementNamed(context, '/home'));
          } else {
            Future.microtask(() => Navigator.pushReplacementNamed(context, '/login'));
          }
          return SizedBox(); 
        }
      },
    );
  }
}
