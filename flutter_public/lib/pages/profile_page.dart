import 'package:flutter/material.dart';
import 'package:sport_app/handlers/api_handler.dart';

class ProfilePage extends StatefulWidget {
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
  ApiHandler apiHandler = ApiHandler();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final userProfile = await apiHandler.fetchUserProfile();

      setState(() {
        _emailController.text = userProfile.email;
        _firstNameController.text = userProfile.firstname;
        _lastNameController.text = userProfile.lastname;
        _usernameController.text = userProfile.username;
        _passwordController.text = userProfile.password;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _errorMessage = 'Failed to load profile ${error.toString()}';
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
        SnackBar(content: Text('Profile updated successfully!')),
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
      title: Text('Profile Page'),
      centerTitle: true,
    ),
    body: _isLoading
        ? Center(child: CircularProgressIndicator())
        : Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (_errorMessage != null) 
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red),
                  ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                readOnly: true,
              ),
              TextField(
                controller: _firstNameController,
                decoration: InputDecoration(labelText: 'First Name'),
              ),
              TextField(
                controller: _lastNameController,
                decoration: InputDecoration(labelText: 'Last Name'),
              ),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'User Name'),
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateProfile, 
                child: Text('Update Profile'),
              ),
            ],
          )
          ) 
  );
 }
}





