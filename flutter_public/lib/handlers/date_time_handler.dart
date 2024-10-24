import 'package:intl/intl.dart';


class DateTimeHandler {
  static String formatDate(String date) {
    try {
      DateTime parsedDate = DateTime.parse(date);
       return DateFormat('yyyy-MM-dd').format(parsedDate); 
    } catch (e) {
      return 'Invalid Date'; 
    }
  }

 
  static String formatTime(String time) {
    try {
      DateTime parsedTime = DateTime.parse(time);
      return DateFormat('hh:mm a').format(parsedTime); 
    } catch (e) {
      return 'Invalid Time'; 
    }
  }

 
  static String formatDateTime(String dateTime) {
    try {
      DateTime parsedDateTime = DateTime.parse(dateTime);
      return DateFormat('yyyy-MM-dd hh:mm a').format(parsedDateTime); 
    } catch (e) {
      return 'Invalid DateTime';
    }
  }
}

