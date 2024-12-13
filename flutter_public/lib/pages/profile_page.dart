import 'package:flutter/material.dart';
import 'package:sport_app/handlers/api_handler.dart';
import 'package:sport_app/handlers/auth_handler.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key); 
  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = true;
  String? _errorMessage;
  final ApiHandler apiHandler = ApiHandler();
  final AuthHandler authHandler = AuthHandler();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final userProfile = await apiHandler.fetchUserProfile();
      if (!mounted) return;

      setState(() {
        _emailController.text = userProfile.email;
        _firstNameController.text = userProfile.firstname;
        _lastNameController.text = userProfile.lastname;
        _usernameController.text = userProfile.username;
        _passwordController.text = userProfile.password;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Failed to load profile: ${error.toString()}';
        _isLoading = false;
      });
    }
  }

 Future<void> _updateProfile() async {
  setState(() {
    _isLoading = true;
  });

  try {
    await apiHandler.updateUserProfile(
      _firstNameController.text,
      _lastNameController.text,
      _emailController.text,
      _usernameController.text,
      _passwordController.text,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    }
  } catch (error) {
    if (mounted) {
      setState(() {
        _errorMessage = 'Failed to update profile: ${error.toString()}';
      });
    }
  } finally {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Page'), 
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) 
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0), 
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (_errorMessage != null)
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red), 
                      ),
                    const SizedBox(height: 16), 
                    _buildTextField(_emailController, 'Email', readOnly: true),
                    const SizedBox(height: 16), 
                    _buildTextField(_firstNameController, 'First Name'),
                    const SizedBox(height: 16), 
                    _buildTextField(_lastNameController, 'Last Name'),
                    const SizedBox(height: 16), 
                    _buildTextField(_usernameController, 'Username'),
                    const SizedBox(height: 16), 
                    _buildTextField(
                      _passwordController,
                      'Password',
                      obscureText: true,
                    ),
                    const SizedBox(height: 20), 
                    ElevatedButton(
                      onPressed: _isLoading ? null : _updateProfile,
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Update Profile'), 
                    ),
                    const SizedBox(height: 20), 
                    ElevatedButton(
                      onPressed: () async {
                        await authHandler.logout();
                        if (mounted) {
                          // ignore: use_build_context_synchronously
                          Navigator.pushReplacementNamed(context, '/login');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Sign out'), 
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText,
      {bool readOnly = false, bool obscureText = false}) {
    return SizedBox(
      width: 300,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: labelText),
        readOnly: readOnly,
        obscureText: obscureText,
      ),
    );
  }
}
