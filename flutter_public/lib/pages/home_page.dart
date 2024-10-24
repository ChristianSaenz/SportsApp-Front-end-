import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logger/logger.dart';

final logger = Logger();



class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
 }


class HomePageState extends State<HomePage> {
  final String baseUrl = "https://localhost:7259/api";
  List<dynamic> todaysGame = [];
  bool isLoading = true;
  bool haserror = false;

  @override 
  void initState() {
    super.initState();
    fetchTodaysGames();
  }

  Future<void> fetchTodaysGames() async {
   logger.d('Fetching today\'s games...');

    try {
      final response = await http.get(Uri.parse('$baseUrl/Match/today'));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

       if (data is Map<String, dynamic> && data.containsKey('message')) {
        logger.i(data['message']);
        setState(() {
          todaysGame = []; 
          isLoading = false;
        });
      } else if (data is List) {
        logger.i('Data fetched successfully.');
        setState(() {
          todaysGame = data; 
          isLoading = false;
        });
      }
      } else {
        logger.e('Failed to fetch games. Status code: ${response.statusCode}');
        setState(() {
          haserror = true;
        });
      }
    } catch (e) {
      logger.e('Error occurred while fetching games: $e');
      setState(() {
        haserror = true;
      });
    }
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Home Page'),
      centerTitle: true, 
    ),
    body: Column(
      children: [
        Expanded(
          child: isLoading
              ? Center(child: CircularProgressIndicator())
              : haserror
                  ? Center(child: Text('Failed to load games', style: TextStyle(color: Colors.red)))
                  : todaysGame.isEmpty
                      ? Center(child: Text('No games scheduled for today.'))
                      : ListView.builder(
                          itemCount: todaysGame.length,
                          itemBuilder: (context, index) {
                            var game = todaysGame[index];
                            return ListTile(
                              title: Text('${game['HomeTeam']}  vs ${game['AwayTeam']}'),
                              subtitle: Text('Time: ${game['MatchTime']}'),
                            );
                          },
                        ),
          ),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(Icons.login),
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
              ),
              IconButton(
                icon: Icon(Icons.score),
                onPressed: () {
                  Navigator.pushNamed(context, '/scores');
                },
              ),
            ],
          ),
        SizedBox(height: 25), 
      ] ,
      ),
    );
  }
}


