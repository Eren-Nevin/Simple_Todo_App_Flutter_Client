import 'package:flutter/material.dart';

getWeekDayName(DateTime time) {
  switch (time.weekday) {
    case DateTime.saturday:
      return 'Saturday';
    case DateTime.sunday:
      return 'Sunday';
    case DateTime.monday:
      return 'Monday';
    case DateTime.tuesday:
      return 'Tuesday';
    case DateTime.wednesday:
      return 'Wednesday';
    case DateTime.thursday:
      return 'Thursday';
    case DateTime.friday:
      return 'Friday';
  }
}

int getCurrentEpoch() {
  return DateTime.now().millisecondsSinceEpoch;
}

// TODO: Enhance This
Widget BlankWidgetBuilder() {
  return Container(
    color: Colors.indigo,
  );
}
