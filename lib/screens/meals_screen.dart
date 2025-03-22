import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:work_manager/appColor.dart';
import 'package:work_manager/models/boxes.dart';
import 'package:work_manager/models/profile.dart';
import 'package:work_manager/models/shift.dart';
import 'package:work_manager/screens/profile_screen.dart';
import 'package:work_manager/screens/shift_editer.dart';
import 'package:intl/intl.dart';

class MealsScreen extends StatefulWidget {
  const MealsScreen({super.key});

  @override
  State<MealsScreen> createState() => _MealsScreenState();
}

class _MealsScreenState extends State<MealsScreen> {
  String getSelectedProfile() {
    return profileBox.values
        .toList()
        .firstWhere(
          (obj) => obj.selected, // Optional: handle case when no match is found
        )
        .name;
  }

  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;
  // Number of days in a month
  int getDaysInMonth(int year, int month) {
    // Create a DateTime object for the first day of the next month
    DateTime firstDayOfNextMonth = DateTime(year, month + 1, 1);

    // Subtract one day from that date to get the last day of the current month
    DateTime lastDayOfMonth = firstDayOfNextMonth.subtract(Duration(days: 1));

    // Return the day of the month for the last day, which is the number of days in the month
    return lastDayOfMonth.day;
  }

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

  // Number of work days
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

  // Get Shifts of current profile
  List<String> getMonthMeals(int year, int month) {
    List<String> selectedProfileMeals =
        profileBox.get(getSelectedProfile()).meals;
    List<String> currentMonthShifts = [];
    for (String meal in selectedProfileMeals) {
      if (meal.contains("-0${selectedMonth.toString()}/") &&
          meal.contains(selectedYear.toString())) {
        currentMonthShifts.add(meal);
      } else if (meal.contains("-${selectedMonth.toString()}/") &&
          meal.contains(selectedYear.toString())) {
        currentMonthShifts.add(meal);
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

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey, // Assign the GlobalKey to Scaffold
      appBar: AppBar(
        foregroundColor: textColor,
        title: Center(child: Text("Repas de ${getSelectedProfile()}")),
        backgroundColor: appColor,
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle, color: textColor),
            onPressed: () {
              // Open the drawer when the profile button is pressed
              scaffoldKey.currentState?.openEndDrawer();
            },
          ),
        ],
      ),
      // Use endDrawer to make it appear from the right side
      endDrawer: Drawer(
        child: ValueListenableBuilder(
          valueListenable:
              profileBox.listenable(), // Listening to profileBox changes
          builder: (context, Box profileBox, _) {
            // Get all profiles from the box
            var profiles = profileBox.values.toList();
            return ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  child: Center(
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            'Mes Profils',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: IconButton(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => ProfileScreen(
                                        profileName: "",
                                        title: "Nouveau Profil",
                                      ),
                                ),
                              );
                              setState(() {});
                            },
                            icon: Icon(Icons.add),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Generate ListTiles for each profile stored in the profileBox
                for (var profile in profiles)
                  ListTile(
                    title: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            profile.name,
                            style: TextStyle(
                              fontWeight:
                                  profile.selected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: IconButton(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => ProfileScreen(
                                        profileName: profile.name,
                                        title: "Modifier mon profil",
                                      ),
                                ),
                              );
                              setState(() {});
                            },

                            icon: Icon(Icons.edit),
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      // Handle profile selection (e.g., navigate to profile details screen)
                      // You can handle the selected profile here.
                      //print("Selected profile: ${profile.name}");
                      setState(() {
                        profile.selected = true;
                        profileBox.put(profile.name, profile);
                        for (Profile prf in profileBox.values.toList()) {
                          if (prf.name != profile.name) {
                            prf.selected = false;
                            profileBox.put(prf.name, prf);
                          }
                        }
                      });
                      Navigator.pop(context);
                      /* print(
                        profileBox.values
                            .toList()
                            .firstWhere((obj) => obj.selected)
                            .name,
                      );*/
                    },
                  ),
              ],
            );
          },
        ),
      ),
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

          Expanded(
            child: ListView.builder(
              itemCount: getDaysInMonth(selectedYear, selectedMonth),
              itemBuilder: (BuildContext context, int index) {
                String currentProfile = getSelectedProfile();

                List<Map<String, String>> daysWithWeekdays =
                    getDaysWithWeekdays(selectedYear, selectedMonth);
                List selectedMonthMeals = getMonthMeals(
                  selectedYear,
                  selectedMonth,
                );
                String? selectedMeal;
                if (selectedMonthMeals.isNotEmpty) {
                  for (String meal in selectedMonthMeals) {
                    if (meal.contains("//0${index + 1}-") ||
                        meal.contains("//${index + 1}-")) {
                      print("found");
                      selectedMeal = meal;
                      break;
                    }
                  }
                }
                return Column(
                  children: [
                    Container(
                      //color:index % 2 == 0 ? const Color.fromARGB(102, 196, 196, 196) : Colors.transparent,
                      child: GestureDetector(
                        onTap: () async {
                          String mealDate;
                          if (selectedMonth >= 10) {
                            mealDate =
                                "//${index + 1}-${selectedMonth}/${selectedYear}";
                          } else {
                            mealDate =
                                "//${index + 1}-0${selectedMonth}/${selectedYear}";
                          }

                          bool refresh = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => MealEditor(
                                    selectedMeal:
                                        selectedMeal != null
                                            ? selectedMeal
                                            : "==",
                                    currentProfile: currentProfile,
                                    title:
                                        "${daysWithWeekdays[index]['weekday']} ${index + 1} ${_getMonthName(selectedMonth)} ${selectedYear}",
                                    date:
                                        "${daysWithWeekdays[index]['weekday']}${mealDate}",
                                  ),
                            ),
                          );

                          if (refresh) {
                            setState(() {});
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: IntrinsicHeight(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                // Use Container with fixed width for alignment
                                Expanded(
                                  flex: 1,
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      "${index + 1} ${daysWithWeekdays[index]['weekday']}",
                                      textAlign: TextAlign.left,
                                      overflow: TextOverflow.ellipsis,
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.labelLarge,
                                    ),
                                  ),
                                ),
                                VerticalDivider(),
                                Expanded(
                                  flex: 5,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.wb_sunny_outlined),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 4.0,
                                                    horizontal: 8.0,
                                                  ),
                                              child: Text.rich(
                                                TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: "Repas de midi : ",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .labelLarge
                                                          ?.copyWith(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                    ),
                                                    TextSpan(
                                                      text:
                                                          (selectedMeal ==
                                                                      null ||
                                                                  selectedMeal!
                                                                      .split(
                                                                        "=",
                                                                      )[1]
                                                                      .isEmpty)
                                                              ? "X"
                                                              : selectedMeal
                                                                  .split(
                                                                    "=",
                                                                  )[1],
                                                      style:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .labelLarge,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Icon(Icons.nightlight_outlined),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 4.0,
                                                    horizontal: 8.0,
                                                  ),
                                              child: Text.rich(
                                                TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: "Repas du soir : ",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .labelLarge
                                                          ?.copyWith(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                    ),
                                                    TextSpan(
                                                      text:
                                                          (selectedMeal ==
                                                                      null ||
                                                                  selectedMeal!
                                                                      .split(
                                                                        "=",
                                                                      )[2]
                                                                      .isEmpty)
                                                              ? "X"
                                                              : selectedMeal
                                                                  .split(
                                                                    "=",
                                                                  )[2],
                                                      style:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .labelLarge,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Divider(),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: ElevatedButton(
              onPressed: () {
                String currentP = getSelectedProfile();
                Profile prf = profileBox.get(currentP);
                prf.meals.removeWhere(
                  (item) =>
                      (item.contains("-$selectedMonth/$selectedYear") ||
                          item.contains("-0$selectedMonth/$selectedYear")),
                );
                profileBox.put(currentP, prf);
                setState(() {});
              },
              child: Text("Réinitialiser"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MealEditor extends StatefulWidget {
  final String selectedMeal;
  final String currentProfile;
  final String title;
  final String date;

  MealEditor({
    super.key,
    required this.selectedMeal,
    required this.currentProfile,
    required this.title,
    required this.date,
  });

  @override
  State<MealEditor> createState() => _MealEditorState();
}

class _MealEditorState extends State<MealEditor> {
  late TextEditingController lunchController;
  late TextEditingController dinnerController;
  bool applyForAllDays = false;
  bool includeWeekend =
      false; // New checkbox to decide if weekends should be included

  @override
  void initState() {
    super.initState();
    lunchController = TextEditingController(
      text: widget.selectedMeal.split("=")[1],
    );
    dinnerController = TextEditingController(
      text: widget.selectedMeal.split("=")[2],
    );
  }

  void resetFields() {
    setState(() {
      lunchController.clear();
      dinnerController.clear();
      applyForAllDays = false;
      includeWeekend = false;
    });
  }

  // For date handling

  void saveMeal() {
    if (lunchController.text.isNotEmpty || dinnerController.text.isNotEmpty) {
      Profile prf = profileBox.get(widget.currentProfile);
      String datePart =
          widget.date.split("//")[1]; // Extract only "day-month/year"

      String mealEntry =
          "//$datePart=${lunchController.text}=${dinnerController.text}";

      for (String ms in prf.meals) {
        if (ms.contains(datePart)) {
          prf.meals.remove(ms);
          break;
        }
      }

      if (applyForAllDays) {
        // Get the full date from the current datePart
        DateFormat dateFormat = DateFormat("dd-MM/yyyy");
        DateTime selectedDate = dateFormat.parse(
          datePart,
        ); // Convert to DateTime

        // Find the start of the week (Monday)
        int currentWeekday = selectedDate.weekday; // 1 = Monday, 7 = Sunday
        DateTime mondayOfWeek = selectedDate.subtract(
          Duration(days: currentWeekday - 1),
        );

        // Loop through Monday to Friday or Monday to Sunday based on the checkbox
        int loopLimit =
            includeWeekend
                ? 7
                : 5; // If weekend is included, loop through 7 days, else only 5

        for (int i = 0; i < loopLimit; i++) {
          DateTime newDate = mondayOfWeek.add(Duration(days: i));
          String formattedDate = dateFormat.format(
            newDate,
          ); // Convert back to "day-month/year"

          String newMealEntry =
              "//$formattedDate=${lunchController.text}=${dinnerController.text}";
          prf.meals.add(newMealEntry);
        }
      } else {
        prf.meals.add(mealEntry);
        // Save only for the selected day
      }

      profileBox.put(widget.currentProfile, prf);
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Veuillez remplir au moins 1 champ!"),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              controller: lunchController,
              decoration: InputDecoration(
                labelText: "Repas de midi",
                icon: Icon(Icons.wb_sunny_outlined),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: dinnerController,
              decoration: InputDecoration(
                labelText: "Repas du soir",
                icon: Icon(Icons.nightlight_outlined),
              ),
            ),
            SizedBox(height: 10),
            CheckboxListTile(
              title: Text("Appliquer pour toute la semaine?"),
              value: applyForAllDays,
              onChanged: (value) {
                setState(() {
                  applyForAllDays = value ?? false;
                });
              },
            ),
            CheckboxListTile(
              title: Text("Inclure le weekend?"),
              value: includeWeekend,
              onChanged:
                  applyForAllDays
                      ? (value) {
                        setState(() {
                          includeWeekend = value ?? false;
                        });
                      }
                      : null, // Disable checkbox if "Apply for all days?" is not selected
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width:
                      MediaQuery.of(context).size.width *
                      0.4, // 40% of screen width
                  child: ElevatedButton(
                    onPressed: resetFields,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: Text(
                      "Réinitialiser",
                      style: TextStyle(color: textColor),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                SizedBox(
                  width:
                      MediaQuery.of(context).size.width *
                      0.4, // 40% of screen width
                  child: ElevatedButton(
                    onPressed: saveMeal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appColor, // Uses your defined constant
                    ),
                    child: Text(
                      "Sauvegarder",
                      style: TextStyle(color: textColor),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
