import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:work_manager/appColor.dart';
import 'package:work_manager/models/boxes.dart';
import 'package:work_manager/models/profile.dart';
import 'package:work_manager/screens/meals_screen.dart';
import 'package:work_manager/screens/overview_screen.dart';
import 'package:work_manager/screens/profile_screen.dart';
import 'package:work_manager/screens/progress_screen.dart';
import 'package:work_manager/screens/shift_screen.dart';
import 'package:hive/hive.dart';

class MainScreen extends StatefulWidget {
  int currentIndex;
  MainScreen({super.key,required this.currentIndex});

  @override
  State<MainScreen> createState() => _MainScreenState();
  
}

class _MainScreenState extends State<MainScreen> {
  
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  String getSelectedProfile() {
    return profileBox.values
        .toList()
        .firstWhere(
          (obj) => obj.selected, // Optional: handle case when no match is found
        )
        .name;
  }

  void pickColor() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Choisir une couleur"),
            content: SingleChildScrollView(
              child: ColorPicker(
                pickerColor: appColor,
                onColorChanged: (color) {
                  setState(() => appColor = color);
                },
                showLabel: true,
                pickerAreaHeightPercent: 0.8,
              ),
            ),
            actions: [
              TextButton(
                child: const Text("Appliquer"),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey, // Assign the GlobalKey to Scaffold
      appBar: AppBar(
        foregroundColor: textColor,
        title: Center(child: Text(getSelectedProfile())),
        backgroundColor: appColor,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MealsScreen()),
              );
            },
            icon: Icon(Icons.restaurant_sharp),
          ),
          IconButton(
            icon: Icon(Icons.account_circle, color: textColor),
            onPressed: () {
              // Open the drawer when the profile button is pressed
              scaffoldKey.currentState?.openEndDrawer();
            },
          ),
          IconButton(onPressed: pickColor, icon: Icon(Icons.brush)),
        ],
      ),
      body: _buildPage(widget.currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: appColor,
        currentIndex: widget.currentIndex,
        onTap: (index) => setState(() => widget.currentIndex = index),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Tableau Mensuel",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: "Aujourd'hui"),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: "Progrès",
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
                  ) /*
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          profileBox.put(
                            "Ilyas",
                            Profile(
                              name: "Ilyas",
                              shifts: [],
                              hourlyWage: 10,
                              vacations: 30,
                              workHours: "04:00",
                              selected: false,
                              defaultTime: "08:00/12:00",
                              breakDuration: "00:00",
                            ),
                          );
                          profileBox.put(
                            "Adam",
                            Profile(
                              name: "Adam",
                              shifts: [],
                              hourlyWage: 5,
                              vacations: 2,
                              workHours: "01:00",
                              selected: true,
                              defaultTime: "00:00/01:30",
                              breakDuration: "00:00",
                            ),
                          );
                        });
                      },
                      child: Text("Add"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          profileBox.clear();
                        });
                      },
                      child: Text("Clear"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          Profile selectedProfile = profileBox.get("Ilyas");
                          print(selectedProfile.name);
                          print(selectedProfile.shifts[0].date);
                        });
                      },
                      child: Text("Get"),
                    ),
                  ],
                ),*/,
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return OverviewScreen();
      case 1:
        return ShiftScreen();
      case 2:
        return ProgressScreen();
      default:
        return OverviewScreen();
    }
  }
}
