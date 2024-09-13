import 'dart:io';

import 'package:path_provider/path_provider.dart';

DateTime dayToDateTime(Day day) {
  return DateTime(day.year, day.month, day.day);
}
Day dateTimeToDay(DateTime dateTime){
  return Day(dateTime.day, dateTime.month, dateTime.year);
}

class Day {
  int day;
  int month;
  int year;

  Day(this.day, this.month, this.year);

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'month': month,
      'year': year,
    };
  }

  factory Day.fromJson(Map<String, dynamic> json) {
    return Day(json['day'], json['month'], json['year']);
  }

  Day operator +(int days) {
    final date = DateTime(year, month, day).add(Duration(days: days));
    return Day(date.day, date.month, date.year);
  }

  Day operator -(int days) {
    final date = DateTime(year, month, day).subtract(Duration(days: days));
    return Day(date.day, date.month, date.year);
  }

  @override
  String toString() {
    return "${year}-${month}-${day}";
  }
}

Future<String> loadLanguage() async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/language.json');
  if (!file.existsSync()) {
    return "English";
  }
  String contents = await file.readAsString();
  return contents;
}
Future<void> saveLanguage({required String language}) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/language.json');
  await file.writeAsString(language);
}