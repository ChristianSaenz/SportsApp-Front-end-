class Sport {
  final int sportId;
  final String sportsName;

  Sport({required this.sportId, required this.sportsName});

  factory Sport.fromJson(Map<String, dynamic> json) {
    return Sport(
      sportId: json['sports_id'],
      sportsName: json['sports_name'],
    );
  }
}