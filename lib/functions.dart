import 'package:work_manager/models/boxes.dart';
import 'package:work_manager/models/shift.dart';

String getSelectedProfile() {
  return profileBox.values
      .toList()
      .firstWhere(
        (obj) => obj.selected, // Optional: handle case when no match is found
      )
      .name;
}

int getDaysInMonth(int year, int month) {
  // Create a DateTime object for the first day of the next month
  DateTime firstDayOfNextMonth = DateTime(year, month + 1, 1);

  // Subtract one day from that date to get the last day of the current month
  DateTime lastDayOfMonth = firstDayOfNextMonth.subtract(Duration(days: 1));

  // Return the day of the month for the last day, which is the number of days in the month
  return lastDayOfMonth.day;
}

int getWorkdaysInMonth(int year, int month) {
  int workdays = 0;

  // Get the number of days in the given month
  int daysInMonth = getDaysInMonth(year, month);

  // Loop through all the days of the month
  for (int day = 1; day <= daysInMonth; day++) {
    // Create a DateTime object for the current day
    DateTime date = DateTime(year, month, day);

    // Check if the day is a weekday (Mon = 1, Tue = 2, ..., Fri = 5)
    if (date.weekday >= 1 && date.weekday <= 5) {
      workdays++;
    }
  }

  return workdays;
}

String returnTotalSalary(List availableShifts) {
  //List availableShifts = getMonthShifts(selectedYear, selectedMonth);
  double totalSalary = 0;
  for (Shift s in availableShifts) {
    totalSalary += s.money;
  }
  return "${totalSalary.toStringAsFixed(2)} €";
}

String returnTotalWorkHours(List availableShifts) {
  //List availableShifts = getMonthShifts(selectedYear, selectedMonth);
  int totalMin = 0;
  String totalHours = "00:00";
  for (Shift s in availableShifts) {
    if (s.workedHours != "-") {
      totalMin +=
          int.parse(s.workedHours.split(":")[0]) * 60 +
          int.parse(s.workedHours.split(":")[1]);
    }
  }
  if (totalMin > 60) {
    String h =
        (totalMin / 60).floor() < 10
            ? "0${(totalMin / 60).floor()}"
            : "${(totalMin / 60).floor()}";
    String m =
        ((totalMin / 60 - (totalMin / 60).floor()) * 60).round() < 10
            ? "0${((totalMin / 60 - (totalMin / 60).floor()) * 60).round()}"
            : "${((totalMin / 60 - (totalMin / 60).floor()) * 60).round()}";

    totalHours = "${h}:${m}";
  }
  return "$totalHours h";
}

String returnTotalOvertime(List availableShifts) {
  //List availableShifts = getMonthShifts(selectedYear, selectedMonth);
  int totalMin = 0;
  String totalHours = "00:00";
  for (Shift s in availableShifts) {
    if (s.shiftStart != "-") {
      totalMin +=
          int.parse(s.workHours.split(":")[0]) * 60 +
          int.parse(s.workHours.split(":")[1]);
    }
  }
  if (totalMin > 60) {
    String h =
        (totalMin / 60).floor() < 10
            ? "0${(totalMin / 60).floor()}"
            : "${(totalMin / 60).floor()}";
    String m =
        ((totalMin / 60 - (totalMin / 60).floor()) * 60).round() < 10
            ? "0${((totalMin / 60 - (totalMin / 60).floor()) * 60).round()}"
            : "${((totalMin / 60 - (totalMin / 60).floor()) * 60).round()}";

    totalHours = "${h}:${m}";
  } else {
    String h = "00";
    String m =
        ((totalMin / 60 - (totalMin / 60).floor()) * 60).round() < 10
            ? "0${((totalMin / 60 - (totalMin / 60).floor()) * 60).round()}"
            : "${((totalMin / 60 - (totalMin / 60).floor()) * 60).round()}";

    totalHours = "${h}:${m}";
  }
  return "$totalHours h";
}

List<Shift> getMonthShifts(int year, int month) {
  List<Shift> selectedProfileShifts =
      profileBox.get(getSelectedProfile()).shifts;
  List<Shift> currentMonthShifts = [];
  for (Shift shift in selectedProfileShifts) {
    if (shift.date.contains("-0${month.toString()}/") &&
        shift.date.contains(year.toString())) {
      currentMonthShifts.add(shift);
    } else if (shift.date.contains("-${month.toString()}/") &&
        shift.date.contains(year.toString())) {
      currentMonthShifts.add(shift);
    }
  }

  return currentMonthShifts;
}
