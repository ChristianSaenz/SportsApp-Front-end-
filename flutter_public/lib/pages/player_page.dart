import 'package:flutter/material.dart';
import 'package:sport_app/handlers/api_handler.dart';
import 'package:sport_app/Handlers/icon_handler.dart';
import 'package:sport_app/widget/error_widget.dart';

class PlayersPage extends StatefulWidget {
  const PlayersPage({Key? key}) : super(key: key);

  @override
  PlayersPageState createState() => PlayersPageState();
}

class PlayersPageState extends State<PlayersPage> {
  late Future<List<dynamic>> sportsFuture;
  Future<List<dynamic>>? leaguesFuture;
  Future<List<dynamic>>? teamsFuture;
  Future<List<dynamic>>? playersFuture;

  ApiHandler apiHandler = ApiHandler();
  int? selectedSportId;
  int? selectedLeagueId;
  int? selectedTeamId;

  Map<int, int> playerFavoriteMap = {};

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    sportsFuture = apiHandler.fetchSports();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFavoritePlayers();
    });
  }

  Future<void> _loadFavoritePlayers() async {
    try {
      Map<int, int> favorites = await apiHandler.loadFavoritePlayers();
      if (!mounted) return;
      setState(() {
        playerFavoriteMap = favorites;
      });
    } catch (e) {
       debugPrint('Error loading favorites: $e');
    }
  }

  Future<void> toggleFavorite(int playerId) async {
    try {
      Map<int, int> updatedFavorites =
          await apiHandler.toggleFavorite(playerId, playerFavoriteMap);
      if (!mounted) return;
      setState(() {
        playerFavoriteMap = updatedFavorites;
      });
    } catch (e) {
       debugPrint("Error toggling favorite: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to toggle favorite: $e')),
      );
    }
  }

  void fetchLeagues(int sportId) {
    setState(() {
      selectedSportId = sportId;
      leaguesFuture = apiHandler.fetchLeagues(sportId);
      teamsFuture = null;
      playersFuture = null;
    });
  }

  void fetchTeams(int leagueId) {
    setState(() {
      selectedLeagueId = leagueId;
      teamsFuture = apiHandler.fetchTeams(leagueId);
      playersFuture = null;
    });
  }

  void fetchPlayers(int teamId) {
    setState(() {
      selectedTeamId = teamId;
      playersFuture = apiHandler.fetchPlayers(teamId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Players'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: sportsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return ErrorWidgetWithRetry(
              errorMessage: snapshot.error.toString(),
              onRetry: () {
                setState(() {
                  sportsFuture = apiHandler.fetchSports();
                });
              },
            );
          } else if (snapshot.hasData) {
            final sports = snapshot.data!;
            return Column(
              children: [
                _buildSportSection(sports),
                if (selectedSportId != null && leaguesFuture != null)
                  _buildLeagueSection(),
                const SizedBox(height: 8),
                if (teamsFuture != null) _buildTeamSection(),
                if (playersFuture != null) _buildPlayerSection(),
              ],
            );
          } else {
            return const Center(child: Text('No sports found.'));
          }
        },
      ),
    );
  }
  // Sport section
  Widget _buildSportSection(List<dynamic> sports) {
    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: sports.map((sport) {
            return GestureDetector(
              onTap: () {
                fetchLeagues(sport['sportId']);
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 15.0),
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.blue,
                      child: Icon(
                        getSportIcon(sport['sportName']),
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      sport['sportName'],
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
  // League section
  Widget _buildLeagueSection() {
    return Container(
      height: 45,
      alignment: Alignment.center,
      child: FutureBuilder<List<dynamic>>(
        future: leaguesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return ErrorWidgetWithRetry(
              errorMessage: snapshot.error.toString(),
              onRetry: () {
                setState(() {
                  leaguesFuture = apiHandler.fetchLeagues(selectedSportId!);
                });
              },
            );
          } else if (snapshot.hasData) {
            final leagues = snapshot.data!;
            return Center(
              child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: leagues.length,
                itemBuilder: (context, index) {
                  final league = leagues[index];
                  return GestureDetector(
                    onTap: () {
                      fetchTeams(league['leagueId']);
                    },
                    child: Container(
                      width: 125,
                      margin: const EdgeInsets.symmetric(horizontal: 8.0),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Center(
                        child: Text(
                          league['leagueName'],
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          } else {
            return const Center(child: Text('No leagues found.'));
          }
        },
      ),
    );
  }
  // Team section
  Widget _buildTeamSection() {
  return SizedBox(
    height: 80,
    child: Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_scrollController.hasClients) {
              final newOffset = (_scrollController.offset - 300).clamp(
                _scrollController.position.minScrollExtent,
                _scrollController.position.maxScrollExtent,
              );
              _scrollController.animateTo(
                newOffset,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          },
        ),
        Expanded(
          child: FutureBuilder<List<dynamic>>(
            future: teamsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return ErrorWidgetWithRetry(
                  errorMessage: snapshot.error.toString(),
                  onRetry: () {
                    setState(() {
                      teamsFuture = apiHandler.fetchTeams(selectedLeagueId!);
                    });
                  },
                );
              } else if (snapshot.hasData) {
                final teams = snapshot.data!;
                return ListView.builder(
                  controller: _scrollController,
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: teams.length,
                  itemBuilder: (context, index) {
                    final team = teams[index];
                    return GestureDetector(
                      onTap: () {
                        fetchPlayers(team['teamId']);
                      },
                      child: Container(
                        width: 150,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: Center(
                          child: Text(
                            team['teamName'],
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color.fromARGB(255, 54, 119, 231),
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                  },
                );
              } else {
                return const Center(child: Text('No teams found.'));
              }
            },
          ),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: () {
            if (_scrollController.hasClients) {
              final newOffset = (_scrollController.offset + 300).clamp(
                _scrollController.position.minScrollExtent,
                _scrollController.position.maxScrollExtent,
              );
              _scrollController.animateTo(
                newOffset,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          },
        ),
      ],
    ),
  );
}

    // Player section
  Widget _buildPlayerSection() {
    return Expanded(
      child: FutureBuilder<List<dynamic>>(
        future: playersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return ErrorWidgetWithRetry(
              errorMessage: snapshot.error.toString(),
              onRetry: () {
                setState(() {
                  playersFuture = apiHandler.fetchPlayers(selectedTeamId!);
                });
              },
            );
          } else if (snapshot.hasData) {
            final players = snapshot.data!;
            return ListView.builder(
              itemCount: players.length,
              itemBuilder: (context, index) {
                final player = players[index];
                String fullname = '${player['firstname']} ${player['lastname']}'.trim();
                final playerId = player['playerId'];

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  elevation: 4.0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              fullname,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: Icon(
                                playerFavoriteMap.containsKey(playerId)
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: playerFavoriteMap.containsKey(playerId)
                                    ? Colors.red
                                    : Colors.grey,
                              ),
                              onPressed: () => toggleFavorite(playerId),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          'Position: ${player['postion'] ?? 'Unknown'}',
                          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                        Text(
                          'Age: ${player['age'] ?? '25'}',
                          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                        Text(
                          'Nationality: ${player['nationality'] ?? 'Unknown'}',
                          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No players were found.'));
          }
        },
      ),
    );
  }
}