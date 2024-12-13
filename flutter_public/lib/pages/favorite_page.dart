import 'package:flutter/material.dart';
import 'package:sport_app/handlers/api_handler.dart';
import 'package:sport_app/handlers/unit_handler.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({Key? key}) : super(key: key); 

  @override
  FavoritePageState createState() => FavoritePageState();
}

class FavoritePageState extends State<FavoritePage> {
  ApiHandler apiHandler = ApiHandler();
  Future<List<dynamic>>? favoritesFuture;

  @override
  void initState() {
    super.initState();
    _refreshFavorites();
  }

  Future<void> _refreshFavorites() async {
    setState(() {
      favoritesFuture = apiHandler.getFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Players'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshFavorites,
        child: FutureBuilder<List<dynamic>>(
          future: favoritesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator()); 
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
              );
            } else if (snapshot.hasData) {
              final favorites = snapshot.data!;
              if (favorites.isEmpty) {
                return const Center(child: Text('No favorite players yet.')); 
              }

              return ListView.builder(
                itemCount: favorites.length,
                itemBuilder: (context, index) {
                  final player = favorites[index];

                  final heightCm = player['height'] ?? 0;
                  final weightKg = player['weight'] ?? 0;

                  final height = heightCm > 0
                      ? UnitConverter.convertHeightToFeet(heightCm)
                      : 'Unknown Height';
                  final weight = weightKg > 0
                      ? UnitConverter.convertWeightToPounds(weightKg)
                      : 'Unknown Weight';

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), 
                    child: Card(
                      child: ListTile(
                        title: Text(
                          '${player['firstName']} ${player['lastName']}',
                          style: const TextStyle(fontWeight: FontWeight.bold), 
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Position: ${player['position']}'),
                            Text('Age: ${player['age']}'),
                            Text('Height: $height ft'),
                            Text('Weight: $weight'),
                            Text('Team: ${player['teamName']}'),
                          ],
                        ),
                        isThreeLine: true,
                      ),
                    ),
                  );
                },
              );
            } else {
              return const Center(child: Text('Failed to load favorites.')); 
            }
          },
        ),
      ),
    );
  }
}
