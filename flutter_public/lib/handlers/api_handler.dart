import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'package:sport_app/handlers/tokenstorage_handler.dart';
import 'package:sport_app/handlers/date_handler.dart';


class ApiHandler {
  final String baseUrl = "https://localhost:7259/api";
  final String? token;
  final String apiKey = '??????';

  ApiHandler([this.token]);

  // list of leagues
  static final List<String> leagues = [
    "English Premier League",
    "NFL",
    "NBA",
    "NHL",
    "MLB",
    "Spanish La Liga",
    "Italian Serie A",
    "German Bundesliga",
    "Major League Soccer",
    "ATP Tennis",
    "WTA Tennis",
    "NRL",
    "UFC",
    "Formula 1",
  ];

  // ==================== User APIs ====================

  /// Fetch the profile of the logged-in user
  Future<User> fetchUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/User/profile'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized');
    } else {
      throw Exception('Failed to load profile');
    }
  }

  /// Update the profile of the logged-in user
  Future<void> updateUserProfile(
      String firstname, String lastname, String email, String username, String password) async {
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
        'Username': username,
        'password': password,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update profile. Status: ${response.statusCode}');
    }
  }

  /// Register a new user
  Future<http.Response> register(String email, String username, String password, String firstname, String lastname) async {
    final response = await http.post(
      Uri.parse('$baseUrl/Auth/register'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'Firstname': firstname,
        'Lastname': lastname,
        'Email': email,
        'Username': username,
        'password': password,
      }),
    );
    return response;
  }

  // ==================== Sports & League APIs ====================

  /// Fetch all available sports
  Future<List<dynamic>> fetchSports() async {
    final response = await http.get(Uri.parse('$baseUrl/Sport'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load sports');
    }
  }

  /// Fetch leagues for a specific sport
  Future<List<dynamic>> fetchLeagues(int sportId) async {
    final response = await http.get(Uri.parse('$baseUrl/League/Sport/$sportId/leagues'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load leagues');
    }
  }

  /// Fetch teams for a specific league
  Future<List<dynamic>> fetchTeams(int leagueId) async {
    final response = await http.get(Uri.parse('$baseUrl/Team/$leagueId/teams'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load teams');
    }
  }

  /// Fetch players for a specific team
  Future<List<dynamic>> fetchPlayers(int teamId) async {
    final response = await http.get(Uri.parse('$baseUrl/Player/$teamId/players'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load players');
    }
  }

  // ==================== Course Info APIs ====================

  /// Fetch course information for a specific sport
  Future<List<dynamic>> fetchCourseBySport(int sportId) async {
    final response = await http.get(Uri.parse('$baseUrl/CourseInfo/$sportId/course'));

    if (response.statusCode == 200) {
      return List<dynamic>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load course');
    }
  }

  // ==================== Favorite APIs ====================

  /// Fetch all favorite players for the user
  Future<List<dynamic>> getFavorites() async {
    String? jwtToken = await TokenstorageHandler.getToken();

    if (jwtToken == null) {
      throw Exception('No JWT token found. Please log in.');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/Favorite'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('Failed to load favorites. Status: ${response.statusCode}');
    }
  }

  /// Add a favorite player
  Future<int> addFavorite(int playerId) async {
    String? jwtToken = await TokenstorageHandler.getToken();

    if (jwtToken == null) {
      throw Exception('No JWT token found. Please log in.');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/Favorite'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
      },
      body: jsonEncode(<String, dynamic>{
        'PlayerId': playerId,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData.containsKey('favoriteId')) {
        return responseData['favoriteId'];
      } else {
        throw Exception('Invalid response from the server.');
      }
    } else {
      throw Exception('Failed to add favorite. Status: ${response.statusCode}');
    }
  }

  /// Remove a favorite player
  Future<void> removeFavorite(int favoriteId) async {
    String? jwtToken = await TokenstorageHandler.getToken();

    if (jwtToken == null) {
      throw Exception('No JWT token found. Please log in.');
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/Favorite/$favoriteId'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to remove favorite. Status: ${response.statusCode}');
    }
  }

  /// Load and return a map of favorite players
  Future<Map<int, int>> loadFavoritePlayers() async {
    try {
      List<dynamic> favorites = await getFavorites();
      return {
        for (var f in favorites) f['playerId']: f['favoriteId']
      };
    } catch (e) {
      throw Exception('Failed to load favorite players.');
    }
  }

  /// Toggle a favorite player (add or remove)
  Future<Map<int, int>> toggleFavorite(int playerId, Map<int, int> currentFavorites) async {
    if (currentFavorites.containsKey(playerId)) {
      int favoriteId = currentFavorites[playerId]!;
      await removeFavorite(favoriteId);
      currentFavorites.remove(playerId);
    } else {
      int favoriteId = await addFavorite(playerId);
      currentFavorites[playerId] = favoriteId;
    }
    return currentFavorites;
  }

  // ==================== Matches APIs ====================

  /// Fetch matches by league
  Future<List<dynamic>> fetchMatchesByLeague(int leagueId) async {
    final response = await http.get(Uri.parse('$baseUrl/Match/league/$leagueId'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load matches');
    }
  }

Future<List<dynamic>> fetchMatchesFromSportsDB(DateTime date, String leagueName) async {
  final formattedDate = DateFormat('yyyy-MM-dd').format(date);
  final url = Uri.parse(
    'https://www.thesportsdb.com/api/v1/json/$apiKey/eventsday.php?d=$formattedDate&l=${Uri.encodeComponent(leagueName)}',
  );

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    
    if (data != null && data['events'] != null && data['events'] is List) {
      return data['events'];
    } else {
      return [];
    }
  } else {
    throw Exception('Failed to fetch matches from TheSportsDB: ${response.statusCode}');
  }
}





  /// Fetch today's games for all leagues
  Future<List<dynamic>> fetchTodaysGames() async {
    final now = DateTime.now();
    final String today = DateFormat('yyyy-MM-dd').format(now);
    List<dynamic> allGames = [];

    for (String league in leagues) {
      try {
        final url = Uri.parse(
          'https://www.thesportsdb.com/api/v1/json/$apiKey/eventsday.php?d=$today&l=$league',
        );
        final response = await http.get(url);

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data != null && data['events'] != null && data['events'] is List) {
            List events = data['events'];
            for (int i = 0; i < events.length && i < 2; i++) {
              final event = events[i];
              final homeTeam = event['strHomeTeam'] ?? 'N/A';
              final awayTeam = event['strAwayTeam'] ?? 'N/A';
              final apiTime = event['strTime'] ?? '00:00:00';
              final homeTeamBadge = event['strHomeTeamBadge'];
              final awayTeamBadge = event['strAwayTeamBadge'];
              final strProgress = event['strProgress'] ?? 'TBD';

             String formattedTime = DateHandler.formatTime(apiTime);


              allGames.add({
                'HomeTeam': homeTeam,
                'AwayTeam': awayTeam,
                'MatchTime': formattedTime,
                'GameStatus': strProgress,
                'League': league,
                'HomeTeamBadge': homeTeamBadge,
                'AwayTeamBadge': awayTeamBadge,
              });
            }
          }
        } else {
          throw Exception('Failed to fetch $league. Status code: ${response.statusCode}');
        }
      } catch (e) {
        throw Exception('Error fetching $league: $e');
      }
    }
    return allGames;
  }
} 
