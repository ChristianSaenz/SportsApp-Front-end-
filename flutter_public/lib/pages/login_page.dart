import 'package:flutter/material.dart';
import 'package:sport_app/handlers/auth_handler.dart';  
import 'package:sport_app/handlers/tokenstorage_handler.dart';  

class LoginPage extends StatefulWidget {
  @override
  LoginPageState createState() => LoginPageState(); 
}

class LoginPageState extends State<LoginPage> {  
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = "Email and Password cannot be empty!";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      
      final authandler = AuthHandler();
      final token = await authandler.login(_emailController.text, _passwordController.text);
      
      
      await TokenstorageHandler.saveToken(token);

      
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/postloginpage');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to login: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 300,
              child: TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: 300,
              child: TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
              ),
            ),
            SizedBox(height: 16),
            if (_errorMessage != null)
              Text(_errorMessage!, style: TextStyle(color: Colors.red)),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : SizedBox(
                  width: 150,
                  child: ElevatedButton(
                    onPressed: _login,
                    child: Text('Login')
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
