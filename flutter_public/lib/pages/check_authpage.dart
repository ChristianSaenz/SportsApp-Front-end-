import 'package:flutter/material.dart';
import 'package:sport_app/handlers/auth_handler.dart';

class CheckAuthPage extends StatefulWidget {
  const CheckAuthPage({Key? key}) : super(key: key); 
  @override
  CheckAuthPageState createState() => CheckAuthPageState();
}

class CheckAuthPageState extends State<CheckAuthPage> {
  final AuthHandler _authHandler = AuthHandler();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _authHandler.getToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator()); 
        } else if (snapshot.hasData && snapshot.data != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/profile');
          });
          return const SizedBox.shrink(); 
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/login');
          });
          return const SizedBox.shrink(); 
        }
      },
    );
  }
}
