import 'package:intl/intl.dart';

class DateHandler {
  static String formatTime(String strTime) {
    if (strTime.isEmpty) {
      return 'Unknown Time';
    }

    try {
      DateTime eetDateTime = DateFormat('HH:mm:ss').parse(strTime);
      DateTime utcDateTime = eetDateTime.subtract(const Duration(hours: 8));
      return '${DateFormat('h:mm a').format(utcDateTime)} PST';
    } catch (e) {
      return 'Invalid Time';
    }
  }
}
