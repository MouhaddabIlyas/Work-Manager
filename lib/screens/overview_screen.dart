import 'package:flutter/material.dart';
import 'package:work_manager/appColor.dart';
import 'package:work_manager/functions.dart';
import 'package:work_manager/models/boxes.dart';
import 'package:work_manager/models/profile.dart';
import 'package:work_manager/models/shift.dart';
import 'package:work_manager/screens/meals_screen.dart';
import 'package:work_manager/screens/shift_editer.dart';

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;
  // Number of days in a month

  // Week days
  List<Map<String, String>> getDaysWithWeekdays(int year, int month) {
    List<Map<String, String>> daysWithWeekdays = [];

    // Get the number of days in the given month
    int daysInMonth = getDaysInMonth(year, month);

    // Loop through all the days of the month
    for (int day = 1; day <= daysInMonth; day++) {
      // Create a DateTime object for the current day
      DateTime date = DateTime(year, month, day);

      // Get the weekday (1 = Monday, 7 = Sunday)
      String weekday = _getWeekdayName(date.weekday);

      // Add the date and corresponding weekday to the list
      daysWithWeekdays.add({
        'date':
            '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}',
        'weekday': weekday,
      });
    }

    return daysWithWeekdays;
  }

  // Get Shifts of current profile
  List<Shift> getMonthShifts(int year, int month) {
    List<Shift> selectedProfileShifts =
        profileBox.get(getSelectedProfile()).shifts;
    List<Shift> currentMonthShifts = [];
    for (Shift shift in selectedProfileShifts) {
      if (shift.date.contains("-0${selectedMonth.toString()}/") &&
          shift.date.contains(selectedYear.toString())) {
        currentMonthShifts.add(shift);
      } else if (shift.date.contains("-${selectedMonth.toString()}/") &&
          shift.date.contains(selectedYear.toString())) {
        currentMonthShifts.add(shift);
      }
    }

    return currentMonthShifts;
  }

  String _getWeekdayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Lun';
      case 2:
        return 'Mar';
      case 3:
        return 'Mer';
      case 4:
        return 'Jeu';
      case 5:
        return 'Ven';
      case 6:
        return 'Sam';
      case 7:
        return 'Dim';
      default:
        return '';
    }
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'Janvier';
      case 2:
        return 'Février';
      case 3:
        return 'Mars';
      case 4:
        return 'Avril';
      case 5:
        return 'Mai';
      case 6:
        return 'Juin';
      case 7:
        return 'Juillet';
      case 8:
        return 'Août';
      case 9:
        return 'Septembre';
      case 10:
        return 'Octobre';
      case 11:
        return 'Novembre';
      case 12:
        return 'Décembre';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    if (selectedMonth != 1) {
                      selectedMonth--;
                    } else {
                      selectedMonth = 12;
                      selectedYear--;
                    }
                  });
                },
                icon: Icon(Icons.chevron_left_sharp),
              ),
              Text("${_getMonthName(selectedMonth)} $selectedYear"),
              IconButton(
                onPressed: () {
                  setState(() {
                    if (selectedMonth != 12) {
                      selectedMonth++;
                    } else {
                      selectedMonth = 1;
                      selectedYear++;
                    }
                  });
                },
                icon: Icon(Icons.chevron_right_sharp),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(flex: 1, child: Icon(Icons.calendar_month)),
              Expanded(
                flex: 5,
                child: Text(
                  "Jours de travail : ${getWorkdaysInMonth(selectedMonth, selectedMonth)} jour",
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8.0,
              vertical: 10.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Icon(Icons.calendar_month),
                Icon(Icons.arrow_upward_outlined),
                Icon(Icons.arrow_downward_outlined),
                Icon(Icons.coffee),
                Icon(Icons.schedule),
                Icon(Icons.more_time),
                Icon(Icons.restaurant_sharp),
              ],
            ),
          ),

          Expanded(
            child: RefreshIndicator(
              color: appColor,
              onRefresh: () async {
                setState(() {});
              },
              child: ListView.builder(
                itemCount: getDaysInMonth(selectedYear, selectedMonth),
                itemBuilder: (BuildContext context, int index) {
                  List<Map<String, String>> daysWithWeekdays =
                      getDaysWithWeekdays(selectedYear, selectedMonth);
                  List<Shift> selectedMonthShifts = getMonthShifts(
                    selectedYear,
                    selectedMonth,
                  );

                  // Get shifts for the current day
                  List<Shift> selectedShifts =
                      selectedMonthShifts.where((shift) {
                        return shift.date.contains("//0${index + 1}-") ||
                            shift.date.contains("//${index + 1}-");
                      }).toList();

                  String currentProfile = getSelectedProfile();

                  return Column(
                    children: [
                      Divider(),
                      if (selectedShifts.isNotEmpty)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Shared date cell (only once for multiple shifts)
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Container(
                                  width:
                                      80, // Fixed width to align with other columns
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                    "${index + 1} ${daysWithWeekdays[index]['weekday']}",
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall!
                                        .copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                            selectedShifts[0].isVacation
                                ? Expanded(
                                  flex: 5,
                                  child: Container(
                                    child: Text(
                                      "Jour de Vacances",
                                      style: TextStyle(fontSize: 18),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                )
                                : Expanded(
                                  flex: 5,
                                  child: Column(
                                    children: [
                                      ...List.generate(
                                        selectedShifts.length * 2 -
                                            1, // Double the size minus 1 for dividers
                                        (idx) {
                                          if (idx.isEven) {
                                            int shiftIndex = idx ~/ 2;
                                            var shift =
                                                selectedShifts[shiftIndex];

                                            return GestureDetector(
                                              onTap: () async {
                                                debugPrint(
                                                  "Tapped on shift: ${shift.date}",
                                                );

                                                var result = await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder:
                                                        (
                                                          context,
                                                        ) => ShiftEditor(
                                                          shift: shift,
                                                          currentProfile:
                                                              currentProfile,
                                                          shiftDate:
                                                              "${daysWithWeekdays[index]['weekday']} ${index + 1} ${_getMonthName(selectedMonth)} $selectedYear",
                                                          titleSize: 25,
                                                        ),
                                                  ),
                                                );

                                                if (result != null && result) {
                                                  setState(() {}); // Refresh UI
                                                }
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 6,
                                                      horizontal: 8,
                                                    ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        shift.shiftStart,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style:
                                                            Theme.of(context)
                                                                .textTheme
                                                                .labelSmall,
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        shift.shiftEnd,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style:
                                                            Theme.of(context)
                                                                .textTheme
                                                                .labelSmall,
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        shift.breakDuration,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style:
                                                            Theme.of(context)
                                                                .textTheme
                                                                .labelSmall,
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        shift.workedHours,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style:
                                                            Theme.of(context)
                                                                .textTheme
                                                                .labelSmall,
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        shift.workHours,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .labelSmall
                                                            ?.copyWith(
                                                              color:
                                                                  shift.workHours
                                                                          .contains(
                                                                            "-",
                                                                          )
                                                                      ? Colors
                                                                          .red
                                                                      : Colors
                                                                          .green,
                                                            ),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          } else {
                                            return const Divider(); // Add a divider between shifts
                                          }
                                        },
                                      ),

                                      // Total Row (only if there is more than 1 shift)
                                      if (selectedShifts.length > 1)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 8.0,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceEvenly, // Equal spacing
                                            children: [
                                              Text(
                                                "Total :",
                                                style:
                                                    Theme.of(
                                                      context,
                                                    ).textTheme.titleMedium,
                                              ),

                                              // Total Work Hours Section
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.schedule,
                                                    size: 18,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    returnTotalWorkHours(
                                                      selectedShifts,
                                                    ),
                                                    style:
                                                        Theme.of(
                                                          context,
                                                        ).textTheme.bodyMedium,
                                                  ),
                                                ],
                                              ),

                                              // Total Overtime Section
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.more_time,
                                                    size: 18,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    returnTotalOvertime(
                                                      selectedShifts,
                                                    ),
                                                    style:
                                                        Theme.of(
                                                          context,
                                                        ).textTheme.bodyMedium,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                            selectedShifts[0].isVacation
                                ? Expanded(
                                  flex: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          Profile profile = profileBox.get(
                                            currentProfile,
                                          );
                                          for (Shift sh in selectedShifts) {
                                            profile.shifts.remove(sh);
                                          }
                                          profileBox.put(
                                            currentProfile,
                                            profile,
                                          );
                                        });
                                      },
                                      icon: Icon(Icons.delete),
                                    ),
                                  ),
                                )
                                : Expanded(
                                  flex: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: Checkbox(
                                      value: selectedShifts[0].meal,
                                      activeColor: appColor,
                                      onChanged: (value) {
                                        setState(() {
                                          for (Shift s in selectedShifts) {
                                            s.meal = value!;
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                ),
                          ],
                        ),

                      if (selectedShifts.isEmpty)
                        GestureDetector(
                          onTap: () async {
                            debugPrint(
                              "Tapped on empty shift row for day: ${index + 1}",
                            );
                            var profile = profileBox.get(currentProfile);
                            if (profile == null) return; // Prevent crash

                            var result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => ShiftEditor(
                                      shift: Shift(
                                        date:
                                            "//${index + 1}-${selectedMonth}/${selectedYear}",
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
                                      shiftDate:
                                          "${daysWithWeekdays[index]['weekday']} ${index + 1} ${_getMonthName(selectedMonth)} ${selectedYear}",
                                      titleSize: 25,
                                    ),
                              ),
                            );

                            if (result != null && result) {
                              setState(() {}); // Refresh UI
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    width:
                                        80, // Match width with date cell in shift rows
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.symmetric(vertical: 8),
                                    child: Text(
                                      "${index + 1} ${daysWithWeekdays[index]['weekday']}",
                                      textAlign: TextAlign.center,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.labelSmall!.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    "-",
                                    textAlign: TextAlign.center,
                                    style:
                                        Theme.of(context).textTheme.labelSmall,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    "-",
                                    textAlign: TextAlign.center,
                                    style:
                                        Theme.of(context).textTheme.labelSmall,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    "-",
                                    textAlign: TextAlign.center,
                                    style:
                                        Theme.of(context).textTheme.labelSmall,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    "-",
                                    textAlign: TextAlign.center,
                                    style:
                                        Theme.of(context).textTheme.labelSmall,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    daysWithWeekdays[index]['weekday'] !=
                                                'Sam' &&
                                            daysWithWeekdays[index]['weekday'] !=
                                                'Dim'
                                        ? "-${profileBox.get(currentProfile)?.workHours.split(";")[0] ?? "00:00"}"
                                        : "-",
                                    style: Theme.of(
                                      context,
                                    ).textTheme.labelSmall?.copyWith(
                                      color:
                                          daysWithWeekdays[index]['weekday'] !=
                                                      'Sam' &&
                                                  daysWithWeekdays[index]['weekday'] !=
                                                      'Dim'
                                              ? Colors.red
                                              : Colors.black,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      left: 14,
                                      right: 14,
                                    ),
                                    child: Checkbox(
                                      value: false,
                                      activeColor: appColor,
                                      onChanged: (value) {
                                        setState(() {
                                          Profile cPrf = profileBox.get(
                                            currentProfile,
                                          );
                                          cPrf.shifts.add(
                                            Shift(
                                              date:
                                                  "//${index + 1}-${selectedMonth}/${selectedYear}",
                                              shiftStart: "-",
                                              shiftEnd: "-",
                                              workedHours: "-",
                                              workHours:
                                                  "-${cPrf.workHours.split(";")[0]}",
                                              breakDuration: "-",
                                              money: 0,
                                              meal: true,
                                              shiftWage: cPrf.hourlyWage,
                                              note: "",
                                            ),
                                          );
                                          profileBox.put(currentProfile, cPrf);
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),

          Container(
            color: appColor,
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total :",
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.attach_money_rounded),
                    Text(
                      returnTotalSalary(
                        getMonthShifts(selectedYear, selectedMonth),
                      ),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Icon(Icons.schedule),
                    ),
                    Text(
                      returnTotalWorkHours(
                        getMonthShifts(selectedYear, selectedMonth),
                      ),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Icon(Icons.more_time),
                    ),
                    Text(
                      returnTotalOvertime(
                        getMonthShifts(selectedYear, selectedMonth),
                      ),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
