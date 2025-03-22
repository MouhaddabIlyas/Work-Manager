import 'package:flutter/material.dart';
import 'package:work_manager/functions.dart';
import 'package:work_manager/models/boxes.dart';
import 'dart:math';

import 'package:work_manager/models/shift.dart';

class ProgressScreen extends StatefulWidget {
  @override
  _ProgressScreenState createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  int selectedYear = DateTime.now().year;
  final Map<int, Map<String, dynamic>> monthlyData = {};

  double returnMonthProgress(List<Shift> cShifts, int cMonth) {
    int totalWorkedMin = 0;
    for (Shift s in cShifts) {
      if (s.shiftStart != "-" && !s.isVacation) {
        totalWorkedMin +=
            int.parse(s.workedHours.split(":")[0]) * 60 +
            int.parse(s.workedHours.split(":")[1]);
      }
    }
    double workLimit =
        (double.parse(
                  profileBox
                      .get(getSelectedProfile())
                      .workHours
                      .split(";")[0]
                      .split(":")[0],
                ) *
                60 +
            double.parse(
              profileBox
                  .get(getSelectedProfile())
                  .workHours
                  .split(";")[0]
                  .split(":")[1],
            )) *
        (getWorkdaysInMonth(selectedYear, cMonth) -
            cShifts.where((sh) => sh.isVacation).length);

    return totalWorkedMin / workLimit;
  }

  int countVacations(List<Shift> cShifts) {
    return cShifts.where((sh) => sh.isVacation).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Progrès Annuel"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_left),
            onPressed: () {
              setState(() {
                selectedYear--;
              });
            },
          ),
          Text(
            "$selectedYear",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: Icon(Icons.arrow_right),
            onPressed: () {
              setState(() {
                selectedYear++;
              });
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(10),
        itemCount: 12,
        itemBuilder: (context, index) {
          int month = index + 1;
          List<Shift> currentMonthShifts = getMonthShifts(selectedYear, month);
          double progress = returnMonthProgress(currentMonthShifts, month);

          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  // Circular Progress Indicator
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 60,
                        width: 60,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CircularProgressIndicator(
                              value: returnMonthProgress(
                                currentMonthShifts,
                                month,
                              ),
                              backgroundColor: Colors.grey[300],
                              color:
                                  progress >= 0.5 ? Colors.green : Colors.red,
                              strokeWidth: 6,
                            ),
                            Center(
                              child: Text(
                                progress * 100 < 100
                                    ? "${(progress * 100).toInt()}%"
                                    : "100%",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        _getMonthName(month),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 16),
                  // Text Summary
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Salaire: ${returnTotalSalary(currentMonthShifts)}",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Heures travailées: ${returnTotalWorkHours(currentMonthShifts)}",
                          style: TextStyle(fontSize: 14, color: Colors.blue),
                        ),
                        Text(
                          "Heures extra: ${returnTotalOvertime(currentMonthShifts)}",
                          style: TextStyle(fontSize: 14, color: Colors.red),
                        ),
                        Text(
                          "Jours de travail: ${getWorkdaysInMonth(selectedYear, month)} jour",
                        ),
                        Text(
                          "Jours de vacances: ${countVacations(currentMonthShifts)} / ${profileBox.get(getSelectedProfile()).vacations}",
                        ),
                      ],
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

  // Convert month number to name
  String _getMonthName(int month) {
    List<String> months = [
      "Janvier",
      "Février",
      "Mars",
      "Avril",
      "Mai",
      "Juin",
      "Juillet",
      "Août",
      "Septembre",
      "Octobre",
      "Novembre",
      "Décembre",
    ];
    return months[month - 1];
  }
}
