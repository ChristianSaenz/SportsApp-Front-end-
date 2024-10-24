import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class ApiHandler {
  final String baseUrl = "https://localhost:7259/api";
  final String? token;

  ApiHandler([this.token]);


  Future<User> fetchUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    if (token == null) {
    throw Exception('Token not found');
  }
    
    final response = await http.get(
      Uri.parse('$baseUrl/User/profile'),
      headers:{
        'Authorization': 'Bearer $token',
      },
    );

    if(response.statusCode == 200){
      return User.fromJson(json.decode(response.body));
    } else if (response.statusCode == 401){
      throw Exception('Unauthorized');
    }else {
      throw Exception('Failed to load profile');
    }
  }


  Future<void> updateUserProfile(String firstname, String lastname, String email, String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.put(
      Uri.parse('$baseUrl/User/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'Firstname': firstname,
        'Lastname': lastname,
        'Email': email,
        'Username' : username,
        'password' : password
        
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update profile. Status: ${response.statusCode}');
    }
  }


   Future<List<dynamic>> fetchSports() async {
    final response = await http.get(Uri.parse('$baseUrl/Sport'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body); 
    } else {
      throw Exception('Failed to load sports');
    }
  }


  Future<List<dynamic>> fetchLeagues(int sportId) async {
  final response = await http.get(Uri.parse('$baseUrl/League/Sport/$sportId/leagues'));
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to load leagues');
  }
}


  Future<List<dynamic>> fetchMatchesByLeague(int leagueId) async {
    final response = await http.get(Uri.parse('$baseUrl/Match/league/$leagueId'));

    if (response.statusCode == 200){
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load matches');
    }
  }


}