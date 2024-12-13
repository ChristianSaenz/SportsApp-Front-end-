import 'package:flutter/material.dart';
import 'package:sport_app/handlers/auth_handler.dart';  
import 'package:sport_app/handlers/tokenstorage_handler.dart';
import 'package:sport_app/pages/register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key); 
  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final AuthHandler _authHandler = AuthHandler();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _authHandler.getToken(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); 
          } else if (snapshot.hasData && snapshot.data != null) {
            if (mounted) {
              // ignore: use_build_context_synchronously
              Future.microtask(() => Navigator.pushReplacementNamed(context, '/home'));
            }
          }
          return const LoginForm(); 
        },
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key); 
  @override
  LoginFormState createState() => LoginFormState();
}

class LoginFormState extends State<LoginForm> {  
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
        title: const Text('Login'),
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
                  decoration: const InputDecoration(labelText: 'Email'), 
                ),
              ),
              const SizedBox(height: 16), 
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'), 
                ),
              ),
              const SizedBox(height: 16), 
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red), 
                ),
              const SizedBox(height: 20), 
              _isLoading
                  ? const CircularProgressIndicator() 
                  : SizedBox(
                      width: 150,
                      child: ElevatedButton(
                        onPressed: _login,
                        child: const Text('Login'), 
                      ),
                    ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterPage()), 
                  );
                },
                child: const Text('Don\'t have an account? Register'), 
              ),
            ],
          ),
        ),
      ),
    );
  }
}
