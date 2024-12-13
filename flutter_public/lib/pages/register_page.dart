import 'package:flutter/material.dart';
import 'package:sport_app/handlers/api_handler.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  RegisterPageState createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiHandler apiHandler = ApiHandler();
  bool _isLoading = false;

  Future<void> _registerUser() async {
  setState(() => _isLoading = true); 
  final email = _emailController.text;
  final username = _usernameController.text;
  final password = _passwordController.text;
  final firstname = _firstNameController.text;
  final lastname = _lastNameController.text;

  try {
    final response =
        await apiHandler.register(email, username, password, firstname, lastname);

    if (!mounted) return; 

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful!')),
      );
      Navigator.pop(context); 
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration failed! Please try again.')),
      );
    }
  } catch (e) {
    if (!mounted) return; 
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('An error occurred: $e')),
    );
  } finally {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
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
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(labelText: 'First Name'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(labelText: 'Last Name'),
                ),
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: 150,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _registerUser,
                        child: const Text('Register'),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
