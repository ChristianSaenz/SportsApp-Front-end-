import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthHandler {
  final String baseUrl = "https://localhost:7066/api";

  Future<String> login(String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/Auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setInt('token_expiration',
            DateTime.now().add(const Duration(days: 30)).millisecondsSinceEpoch); 

        return data['token'];
      } else if (response.statusCode == 401) {
        throw Exception('Invalid credentials');
      } else {
        throw Exception('Failed to login. Status: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error during login: $error');
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    int? expirationTime = prefs.getInt('token_expiration');

    if (token != null && expirationTime != null) {
      if (DateTime.now().millisecondsSinceEpoch < expirationTime) {
        return token;
      } else {
        await prefs.remove('token');
        await prefs.remove('token_expiration');
      }
    }
    return null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }
}
