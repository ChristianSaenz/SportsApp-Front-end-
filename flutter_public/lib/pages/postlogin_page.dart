import 'package:flutter/material.dart';

class PostloginPage extends StatelessWidget {
  const PostloginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Successful'), 
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text( 
              'Successfully Logged In!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20), 
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/profile');
              },
              child: const Text('View/Edit Profile'), 
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/home');
              },
              child: const Text('Go to Home'), 
            ),
          ],
        ),
      ),
    );
  }
}
