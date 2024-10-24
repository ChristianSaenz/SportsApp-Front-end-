import 'package:flutter/material.dart';
import 'package:sport_app/handlers/api_handler.dart';
import 'package:sport_app/Handlers/icon_handler.dart';
import 'package:sport_app/handlers/date_time_handler.dart';

class ScoresPage extends StatefulWidget {
  @override
  ScoresPageState createState() => ScoresPageState();
}

class ScoresPageState extends State<ScoresPage> {
  late Future<List<dynamic>> sportsFuture;
  Future<List<dynamic>>? leaguesFuture; 
  Future<List<dynamic>>? matchesFuture; 
  

  ApiHandler apiHandler = ApiHandler();
  int? selectedSportId;

  @override
  void initState() {
    super.initState();
    sportsFuture = apiHandler.fetchSports();
  }

  
  void fetchLeagues(int sportId) {
    setState(() {
      selectedSportId = sportId;
      leaguesFuture = apiHandler.fetchLeagues(sportId); 
      matchesFuture = null; 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sports'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: sportsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final sports = snapshot.data!;
            return Column(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: sports.map((sport) {
                        return GestureDetector(
                          onTap: () async {
                            fetchLeagues(sport['sportId']); 
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 15.0),
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
                                SizedBox(height: 8),
                                Text(
                                  sport['sportName'],
                                  style: TextStyle(fontSize: 16),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                
                if (selectedSportId != null && leaguesFuture != null) 
                  Expanded(
                    child: FutureBuilder<List<dynamic>>(
                      future: leaguesFuture, 
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        } else if (snapshot.hasData) {
                          final leagues = snapshot.data!;
                          return ListView.builder(
                            itemCount: leagues.length,
                            itemBuilder: (context, index) {
                              final league = leagues[index];
                              return ListTile(
                                title: Center(
                                  child: Text(
                                    league['leagueName'],
                                    style: TextStyle(fontSize: 16),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                onTap: () {
                                  setState(() {
                                    matchesFuture = apiHandler.fetchMatchesByLeague(league['leagueId']);
                                  });
                                },
                              );
                            },
                          );
                        } else {
                          return Center(child: Text('No leagues found.'));
                        }
                      },
                    ),
                  )
                else
                  Expanded(child: Center(child: Text('Select a sport to view leagues'))),

               
                if (matchesFuture != null) 
                  Expanded(
                    child: FutureBuilder<List<dynamic>>(
                      future: matchesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        } else if (snapshot.hasData) {
                          final matches = snapshot.data!;
                          return ListView.builder(
                            itemCount: matches.length,
                            itemBuilder: (context, index) {
                              final match = matches[index];
                              String formattedDate = DateTimeHandler.formatDate(match['matchDate']);
                              String formattedTime = DateTimeHandler.formatTime(match['matchTime']);
                              return ListTile(
                                title: Center(child: Text('${match['homeTeam']} vs ${match['awayTeam']}')),
                                subtitle: Center(child: Text('Date: $formattedDate, Time: $formattedTime'),
                                ),
                              );
                            },
                          );
                        } else {
                          return Center(child: Text('No matches found.'));
                        }
                      },
                    ),
                  )
                else
                  Expanded(child: Center(child: Text('Select a league to view matches'))),
              ],
            );
          } else {
            return Center(child: Text('No sports found.'));
          }
        },
      ),
    );
  }
}
