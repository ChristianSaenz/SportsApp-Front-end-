import 'package:flutter/material.dart';

IconData getSportIcon(String sportName) {
  switch (sportName.toLowerCase()) {
    case 'soccer':
      return Icons.sports_soccer;
    case 'football':
      return Icons.sports_football;
    case 'basketball':
      return Icons.sports_basketball;
    case 'baseball':
      return Icons.sports_baseball;
    case 'mma':
      return Icons.sports_mma;
    case 'hockey':
      return Icons.sports_hockey;
    case 'tennis':
      return Icons.sports_tennis;
    case 'f1':
      return Icons.sports_motorsports;

    case 'rugby' :
      return Icons.sports_rugby;
    
    default:
      return Icons.sports;
  }
}