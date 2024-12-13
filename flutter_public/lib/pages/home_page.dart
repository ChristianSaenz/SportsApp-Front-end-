import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:sport_app/handlers/api_handler.dart';

final logger = Logger();

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key); 

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final ApiHandler apiHandler = ApiHandler();

  List<dynamic> todaysGame = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchGames();
  }

  Future<void> fetchGames() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final games = await apiHandler.fetchTodaysGames();
      setState(() {
        todaysGame = games;
        isLoading = false;
      });
    } catch (e) {
      logger.e('Error fetching games: $e');
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Today\'s Matches'), 
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator()) 
                : hasError
                    ? const Center(
                        child: Text(
                          'Failed to load games',
                          style: TextStyle(color: Colors.red),
                        ),
                      )
                    : todaysGame.isEmpty
                        ? const Center(
                            child: Text('No games scheduled for today.'),
                          )
                        : ListView.builder(
                            itemCount: todaysGame.length,
                            itemBuilder: (context, index) {
                              final game = todaysGame[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 30.0, vertical: 8.0),
                                elevation: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          if (game['HomeTeamBadge'] != null &&
                                              game['HomeTeamBadge']
                                                  .toString()
                                                  .isNotEmpty)
                                            Image.network(
                                              game['HomeTeamBadge'],
                                              width: 40,
                                              height: 40,
                                              fit: BoxFit.contain,
                                            ),
                                          const SizedBox(width: 20), 
                                          if (game['AwayTeamBadge'] != null &&
                                              game['AwayTeamBadge']
                                                  .toString()
                                                  .isNotEmpty)
                                            Image.network(
                                              game['AwayTeamBadge'],
                                              width: 40,
                                              height: 40,
                                              fit: BoxFit.contain,
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        '${game['HomeTeam']} vs ${game['AwayTeam']}',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle( 
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 8), 
                                      Text(
                                        'Time: ${game['MatchTime']} | League: ${game['League']}',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(fontSize: 14), 
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade400,
                  offset: const Offset(0, -1), 
                  blurRadius: 5,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.login),
                  onPressed: () {
                    Navigator.pushNamed(context, '/checkAuth');
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.score), 
                  onPressed: () {
                    Navigator.pushNamed(context, '/scores');
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.person), 
                  onPressed: () {
                    Navigator.pushNamed(context, '/player');
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.favorite),
                  onPressed: () {
                    Navigator.pushNamed(context, '/favorite');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
