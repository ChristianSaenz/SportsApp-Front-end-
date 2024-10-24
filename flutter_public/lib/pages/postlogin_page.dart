import 'package:flutter/material.dart';

class PostloginPage extends StatelessWidget{
  const PostloginPage({Key? key}) : super (key : key);

@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login Succesful'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Succesfully Logged In!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/profile');
              }, 
              child: Text('View/Edit Profile'),
              ),
              ElevatedButton(
                onPressed: () {
                Navigator.pushReplacementNamed(context, '/home');
              }, 
              child: Text('Go to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
