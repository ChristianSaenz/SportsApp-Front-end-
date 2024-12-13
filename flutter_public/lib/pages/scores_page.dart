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
            return _buildContent(snapshot.data!);
          } else {
            return const Center(child: Text('No sports found.'));
          }
        },
      ),
    );
  }
  // Content section
  Widget _buildContent(List<dynamic> sports) {
    return Column(
      children: [
        _buildSportSection(sports),
        _buildDateSelector(),
        const SizedBox(height: 5),
        selectedSportId != null && leaguesFuture != null
            ? _buildLeagueSection()
            : const Expanded(child: Center(child: Text('Select a sport to view leagues'))),
        matchesFuture != null
            ? _buildMatchesSection()
            : const Expanded(child: Center(child: Text('Select a league to view matches'))),
      ],
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
              onTap: () => fetchLeagues(sport['sportId']),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
  // Date section
  Widget _buildDateSelector() {
    return Container(
      height: 60,
      alignment: Alignment.center,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 12,
        itemBuilder: (context, index) {
          DateTime date = DateTime.now().add(Duration(days: index - 5));
          String day = DateFormat('EEE').format(date);
          String dayNumber = DateFormat('MMM d').format(date);

          bool isSelected = selectedDate.isAtSameMomentAs(date);

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
    );
  }
  // League section
  Widget _buildLeagueSection() {
    return FutureBuilder<List<dynamic>>(
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
          return ListView.builder(
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
                    ),
                  ),
                ),
              );
            },
          );
        } else {
          return const Center(child: Text('No leagues found.'));
        }
      },
    );
  }
  // Match section
  Widget _buildMatchesSection() {
    return FutureBuilder<List<dynamic>>(
      future: matchesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final matches = snapshot.data!;
          return ListView.builder(
            itemCount: matches.length,
            itemBuilder: (context, index) {
              return _buildMatchCard(matches[index]);
            },
          );
        } else {
          return const Center(child: Text('No matches found for the selected date.'));
        }
      },
    );
  }
  //Match Card
  Widget _buildMatchCard(dynamic match) {
    final homeTeam = match['strHomeTeam'] ?? 'N/A';
    final awayTeam = match['strAwayTeam'] ?? 'N/A';
    final strTime = match['strTime'] ?? '';
    final strProgress = match['strProgress'] ?? 'Not Started';

    String formattedTime = strTime.isNotEmpty
        ? DateHandler.formatTime(strTime)
        : 'Unknown Time';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: ListTile(
        title: Text('$homeTeam vs $awayTeam'),
        subtitle: Text(strProgress == 'Not Started' ? formattedTime : strProgress),
      ),
    );
  }
}
