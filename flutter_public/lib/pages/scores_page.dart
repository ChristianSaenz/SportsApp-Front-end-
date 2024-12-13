import 'package:flutter/material.dart';
import 'package:sport_app/handlers/api_handler.dart';
import 'package:sport_app/Handlers/icon_handler.dart';
import 'package:sport_app/pages/course_page.dart';
import 'package:sport_app/widget/error_widget.dart';
import 'package:intl/intl.dart';
import 'package:sport_app/handlers/date_handler.dart';

class ScoresPage extends StatefulWidget {
  const ScoresPage({Key? key}) : super(key: key);

  @override
  ScoresPageState createState() => ScoresPageState();
}

class ScoresPageState extends State<ScoresPage> {
  late Future<List<dynamic>> sportsFuture;
  Future<List<dynamic>>? leaguesFuture;
  Future<List<dynamic>>? matchesFuture;
  DateTime selectedDate = DateTime.now();

  final ApiHandler apiHandler = ApiHandler();
  int? selectedSportId;
  String? selectedLeagueName;

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
      selectedLeagueName = null;
    });
  }

  void navigateToCoursePage(int sportId, String sportName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CoursePage(sportId: sportId, sportName: sportName),
      ),
    );
  }

  void fetchMatchesForSelectedDate(int leagueId) {
    if (selectedLeagueName == null) {
      return;
    }

    setState(() {
      matchesFuture = apiHandler.fetchMatchesFromSportsDB(selectedDate, selectedLeagueName!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sports'),
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
                // Sports Row
                _buildSportSection(sports),

                // Date Selector
                _buildDateSelector(),

                const SizedBox(height: 5),

                // Leagues
                if (selectedSportId != null && leaguesFuture != null)
                  _buildLeagueSection()
                else
                  const Expanded(child: Center(child: Text('Select a sport to view leagues'))),

                // Matches
                if (matchesFuture != null)
                  _buildMatchesSection()
                else
                  const Expanded(child: Center(child: Text('Select a league to view matches'))),
              ],
            );
          } else {
            return const Center(child: Text('No sports found.'));
          }
        },
      ),
    );
  }

  // Sport Section
  Widget _buildSportSection(List<dynamic> sports) {
    return Align(
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
                margin: const EdgeInsets.symmetric(horizontal: 15.0),
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
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    if (selectedSportId == sport['sportId'])
                      ElevatedButton(
                        onPressed: () {
                          navigateToCoursePage(sport['sportId'], sport['sportName']);
                        },
                        child: const Text('Course Info'),
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

  // Date Selector
  Widget _buildDateSelector() {
    return Container(
      height: 60,
      alignment: Alignment.center,
      child: Center(
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 12,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            DateTime date = DateTime.now().add(Duration(days: index - 5));
            String day = DateFormat('EEE').format(date);
            String dayNumber = DateFormat('MMM d').format(date);

            bool isSelected = selectedDate.day == date.day &&
                selectedDate.month == date.month &&
                selectedDate.year == date.year;

            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedDate = date;
                  if (selectedSportId != null &&
                      leaguesFuture != null &&
                      selectedLeagueName != null) {
                    fetchMatchesForSelectedDate(selectedSportId!);
                  }
                });
              },
              child: Container(
                width: 60,
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      day.toUpperCase(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                    Text(
                      dayNumber,
                      style: TextStyle(
                        fontSize: 14,
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // League Section
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
                      selectedLeagueName = league['leagueName'];
                      fetchMatchesForSelectedDate(league['leagueId']);
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
                          style: const TextStyle(fontSize: 16),
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

  // Loads Matches 
  Widget _buildMatchesSection() {
    return Expanded(
      child: FutureBuilder<List<dynamic>>(
        future: matchesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final matches = snapshot.data!;
            return ListView.builder(
              itemCount: matches.length,
              itemBuilder: (context, index) {
                final match = matches[index];
                return _buildMatchCard(match); 
              },
            );
          } else {
            return const Center(child: Text('No matches found for the selected date.'));
          }
        },
      ),
    );
  }

  // Builds the Match Card
  Widget _buildMatchCard(dynamic match) {
    final homeTeam = match['strHomeTeam'] ?? 'N/A';
    final awayTeam = match['strAwayTeam'] ?? 'N/A';
    final homeScore = match['intHomeScore'];
    final awayScore = match['intAwayScore'];
    final strTime = match['strTime'] ?? '';
    final homeTeamBadge = match['strHomeTeamBadge'];
    final awayTeamBadge = match['strAwayTeamBadge'];
    final strProgress = match['strProgress'] ?? 'Not Started';

    String formattedTime = strTime.isNotEmpty
        ? DateHandler.formatTime(strTime)
        : 'Unknown Time';

    String displayText;
    if (strProgress.toLowerCase() == 'final' || (homeScore != null && awayScore != null)) {
      displayText = 'Final: $homeScore - $awayScore';
    } else if (strProgress.toLowerCase() != 'not started') {
      displayText = strProgress; 
    } else {
      displayText = 'Not Started\n$formattedTime';
    }

    Color containerColor = Colors.blue.shade100;
    if (strProgress.contains('Q') || strProgress.contains('H')) {
      containerColor = Colors.green.shade100; 
    } else if (strProgress.toLowerCase() == 'final') {
      containerColor = Colors.grey.shade300; 
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (homeTeamBadge != null && homeTeamBadge.isNotEmpty)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.network(
                        homeTeamBadge,
                        width: 50,
                        height: 50,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        homeTeam,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                const SizedBox(width: 20),
                Text(
                  'vs',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(width: 20),
                if (awayTeamBadge != null && awayTeamBadge.isNotEmpty)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.network(
                        awayTeamBadge,
                        width: 50,
                        height: 50,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        awayTeam,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: containerColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue, width: 2),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              child: Text(
                displayText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


