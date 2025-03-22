import 'package:flutter/material.dart';
import 'package:work_manager/appColor.dart';
import 'package:work_manager/models/boxes.dart';
import 'package:work_manager/models/profile.dart';
import 'package:work_manager/models/shift.dart';
import 'package:work_manager/screens/shift_editer.dart';

class ShiftScreen extends StatefulWidget {
  const ShiftScreen({super.key});

  @override
  State<ShiftScreen> createState() => _ShiftScreenState();
}

class _ShiftScreenState extends State<ShiftScreen> {
  late String currentProfile;
  late String shiftDate;

  String getSelectedProfile() {
    return profileBox.values
        .toList()
        .firstWhere(
          (obj) => obj.selected, // Optional: handle case when no match is found
        )
        .name;
  }

  String getFormattedDate() {
    DateTime now = DateTime.now();
    List<String> weekdays = [
      "Lundi",
      "Mardi",
      "Mercredi",
      "Jeudi",
      "Vendredi",
      "Samedi",
      "Dimanche",
    ];
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

    String weekday =
        weekdays[now.weekday - 1]; // DateTime.weekday starts from 1 (Monday)
    String month =
        months[now.month - 1]; // DateTime.month starts from 1 (January)

    return "$weekday ${now.day} $month ${now.year}";
  }

  String formatShiftDate() {
    String day =
        DateTime.now().day < 10
            ? "0${DateTime.now().day}"
            : "${DateTime.now().day}";
    String month =
        DateTime.now().month < 10
            ? "0${DateTime.now().month}"
            : "${DateTime.now().month}";

    return "//$day-$month/${DateTime.now().year}";
  }

  bool checkExistingShift() {
    List<Shift> shifts = profileBox.get(getSelectedProfile()).shifts;
    String shiftDate = formatShiftDate();

    return shifts.any((s) => s.date == shiftDate);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    shiftDate = formatShiftDate();
  }

  @override
  Widget build(BuildContext context) {
    currentProfile = getSelectedProfile();
    String currentDay = getFormattedDate();

    bool alreadySaved = checkExistingShift();
    Profile profile = profileBox.get(currentProfile);
    return Scaffold(
      body: Column(
        children: [
          Container(
            color: appColor,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Center(
              child: Text(
                currentDay,
                style: TextStyle(fontSize: 20, color: textColor),
              ),
            ),
          ),
          Expanded(
            child:
                !alreadySaved
                    ? ShiftEditor(
                      shift: Shift(
                        date: shiftDate,
                        shiftStart: "-",
                        shiftEnd: "-",
                        workedHours: "-",
                        workHours: profile.workHours.split(";")[0] ?? "00:00",
                        breakDuration: "00:00",
                        money: 0,
                        meal: false,
                        shiftWage: profile.hourlyWage ?? 0,
                        note: "",
                      ),
                      currentProfile: currentProfile,
                      shiftDate: "Veuillez insérer les horaires de ce jour :",
                      titleSize: 16,
                    )
                    : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          textAlign: TextAlign.center,
                          "Vous avez déjà remplit le formulaire d'aujourd'hui. Bon travail!",
                        ),
                        SizedBox(height: 16),
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              Profile profile = profileBox.get(currentProfile);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => ShiftEditor(
                                        shift: Shift(
                                          date: "${formatShiftDate()}+",
                                          shiftStart: "-",
                                          shiftEnd: "-",
                                          workedHours: "-",
                                          workHours:
                                              profile.workHours.split(";")[0] ??
                                              "00:00",
                                          breakDuration: "00:00",
                                          money: 0,
                                          meal: false,
                                          shiftWage: profile.hourlyWage ?? 0,
                                          note: "",
                                        ),
                                        currentProfile: currentProfile,
                                        shiftDate: currentDay,
                                        titleSize: 25,
                                      ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: appColor,
                              foregroundColor: textColor,
                            ),
                            child: Text("Ajouter Nouveau?"),
                          ),
                        ),
                      ],
                    ),
          ),
        ],
      ),
    );
  }
}
