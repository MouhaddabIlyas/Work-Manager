import 'package:flutter/material.dart';
import 'package:work_manager/appColor.dart';
import 'package:work_manager/main_screen.dart';
import 'package:work_manager/models/boxes.dart';
import 'package:work_manager/models/profile.dart';

class ProfileScreen extends StatefulWidget {
  final String profileName;
  final String title;
  ProfileScreen({super.key, required this.profileName, required this.title});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Profile? profile;
  int selectedDefault = 0;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController hourlyWageController = TextEditingController();
  final TextEditingController vacationsController = TextEditingController();
  final List<TextEditingController> startControllers = List.generate(
    3,
    (_) => TextEditingController(),
  );
  final List<TextEditingController> endControllers = List.generate(
    3,
    (_) => TextEditingController(),
  );
  final List<TextEditingController> breakControllers = List.generate(
    3,
    (_) => TextEditingController(),
  );
  final List<TextEditingController> workHoursControllers = List.generate(
    3,
    (_) => TextEditingController(),
  );

  @override
  void initState() {
    super.initState();
    if (widget.profileName.isNotEmpty) {
      profile = profileBox.get(widget.profileName);
      if (profile != null) {
        nameController.text = profile!.name;
        hourlyWageController.text = profile!.hourlyWage.toString();
        vacationsController.text = profile!.vacations.toString();
        List<String> defaultTimes = profile!.defaultTime.split(";");
        for (int i = 0; i < defaultTimes.length && i < 3; i++) {
          List<String> times = defaultTimes[i].split("/");
          if (times.length == 2) {
            startControllers[i].text = times[0];
            endControllers[i].text = times[1];
          }
        }
        List<String> breakDurations = profile!.breakDuration.split(";");
        for (int i = 0; i < breakDurations.length && i < 3; i++) {
          breakControllers[i].text = breakDurations[i];
        }
        List<String> workHours = profile!.workHours.split(";");
        for (int i = 0; i < workHours.length && i < 3; i++) {
          workHoursControllers[i].text = workHours[i];
        }
      }
    }
  }

  Future<void> _selectTime(
    BuildContext context,
    TextEditingController controller,
  ) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        controller.text =
            "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Nom du profil"),
            ),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: startControllers[selectedDefault],
                    readOnly: true,
                    decoration: InputDecoration(labelText: "Début"),
                    onTap:
                        () => _selectTime(
                          context,
                          startControllers[selectedDefault],
                        ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: endControllers[selectedDefault],
                    readOnly: true,
                    decoration: InputDecoration(labelText: "Fin"),
                    onTap:
                        () => _selectTime(
                          context,
                          endControllers[selectedDefault],
                        ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: breakControllers[selectedDefault],
                    readOnly: true,
                    decoration: InputDecoration(labelText: "Pause"),
                    onTap:
                        () => _selectTime(
                          context,
                          breakControllers[selectedDefault],
                        ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: workHoursControllers[selectedDefault],
                    readOnly: true,
                    decoration: InputDecoration(labelText: "Heures de travail"),
                    keyboardType: TextInputType.number,
                    onTap:
                        () => _selectTime(
                          context,
                          workHoursControllers[selectedDefault],
                        ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: hourlyWageController,
                    decoration: InputDecoration(labelText: "Salaire par h"),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: vacationsController,
                    decoration: InputDecoration(
                      labelText: "Nombre de vacances",
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return Row(
                  children: [
                    Radio(
                      activeColor: appColor,
                      value: index,
                      groupValue: selectedDefault,
                      onChanged: (value) {
                        setState(() {
                          selectedDefault = value as int;
                        });
                      },
                    ),
                    Text("${index + 1}"),
                  ],
                );
              })..insert(0, Text("Horaire ")),
            ),
            SizedBox(height: 36),
            ElevatedButton(
              onPressed: () {
                bool firstAccount = profileBox.isEmpty;
                List<String> defaultTimes = List.generate(
                  3,
                  (i) =>
                      "${startControllers[i].text}/${endControllers[i].text}",
                );
                List<String> breakDurations = List.generate(
                  3,
                  (i) => breakControllers[i].text,
                );
                List<String> workHours = List.generate(
                  3,
                  (i) => workHoursControllers[i].text,
                );
                if (defaultTimes.any((dt) => dt != "/")) {
                  profileBox.put(
                    nameController.text,
                    Profile(
                      name: nameController.text,
                      shifts: profile?.shifts ?? [],
                      hourlyWage: int.parse(hourlyWageController.text),
                      workHours: workHours.join(";"),
                      vacations: int.parse(vacationsController.text),
                      selected: true,
                      defaultTime: defaultTimes.join(";"),
                      breakDuration: breakDurations.join(";"),
                      meals: [],
                    ),
                  );
                  if (!firstAccount) {
                    Navigator.pop(context);
                  } else {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MainScreen(currentIndex: 0),
                      ),
                    );
                  }
                }
              },
              child: Text("Sauvegarder"),
            ),
            SizedBox(height: 16),
            widget.title == "Modifier mon profil"
                ? ElevatedButton(
                  onPressed: () {
                    if (profileBox.values.length > 1) {
                      profileBox.delete(profile!.name);
                      for (Profile prf in profileBox.values.toList()) {
                        if (prf.name != nameController.text) {
                          prf.selected = false;
                          profileBox.put(prf.name, prf);
                        }
                      }
                      profileBox.getAt(0).selected = true;
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("C'est votre seul profil!"),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: Text("Supprimer"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                )
                : SizedBox(),
          ],
        ),
      ),
    );
  }
}
