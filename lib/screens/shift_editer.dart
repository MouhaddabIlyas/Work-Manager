import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:work_manager/appColor.dart';
import 'package:work_manager/main_screen.dart';
import 'package:work_manager/models/boxes.dart';
import 'package:work_manager/models/profile.dart';
import 'package:work_manager/models/shift.dart';

class ShiftEditor extends StatefulWidget {
  final Shift shift;
  final String currentProfile;
  final String shiftDate;
  late bool addShift;
  final double titleSize;
  //final bool withAppBar;
  ShiftEditor({
    super.key,
    required this.shift,
    required this.currentProfile,
    required this.shiftDate,
    required this.titleSize,
    //required this.withAppBar,
  });

  @override
  _ShiftEditorState createState() => _ShiftEditorState();
}

class _ShiftEditorState extends State<ShiftEditor> {
  late TextEditingController _startController;
  late TextEditingController _endController;
  late TextEditingController _breakController;
  late TextEditingController _workHoursController;
  late TextEditingController _hourWageController;
  late TextEditingController _moneyController;
  late TextEditingController _notesController;

  bool isDefault = false;

  int selectedDefault = 0;

  String hTravaille = "00:00";

  String _calculateDuration(String start, String end, String breakD) {
    DateFormat format = DateFormat("HH:mm");

    // Parse the start and end times
    DateTime startTime = format.parse(start);
    DateTime endTime = format.parse(end);

    // If end time is before start time, assume it is the next day
    if (endTime.isBefore(startTime)) {
      endTime = endTime.add(Duration(days: 1));
    }

    // Calculate the duration between start and end
    Duration duration = endTime.difference(startTime);

    // Parse the break duration
    List<String> breakParts = breakD.split(":");
    int breakHours = int.parse(breakParts[0]);
    int breakMinutes = int.parse(breakParts[1]);

    // Convert break duration into a Duration object
    Duration breakDuration = Duration(hours: breakHours, minutes: breakMinutes);

    // Subtract the break duration from the total event duration
    duration -= breakDuration;

    // Format the duration as "HH:mm"
    int hours = duration.inHours;
    int minutes = duration.inMinutes % 60;

    // Return the formatted duration as a string
    return "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}";
  }

  double _calculateDurationInHours(
    String startTime,
    String endTime,
    String breakD,
  ) {
    // Use DateFormat from intl package to parse the time in HH:mm format
    final DateFormat format = DateFormat("HH:mm");

    // Parse the start and end time into DateTime objects
    DateTime start = format.parse(startTime);
    DateTime end = format.parse(endTime);

    // Calculate the difference (Duration)
    Duration difference = end.difference(start);
    Duration breakDrt = Duration(
      hours: int.parse(breakD.split(":")[0]),
      minutes: int.parse(breakD.split(":")[1]),
    );

    // Convert the Duration to hours (including decimal places)
    double hours = (difference.inSeconds - breakDrt.inSeconds) / 3600;

    if (hours.isNegative) {
      hours = 24 + hours;
    }
    print(hours);
    print("hhhhh");
    return hours;
  }

  String _calculateOvertime(String workingTime, String workHours) {
    // convert them to minutes

    int workingTimeMin =
        int.parse(workingTime.split(":")[0]) * 60 +
        int.parse(workingTime.split(":")[1]);
    print(workingTimeMin);
    int workHoursMin =
        int.parse(workHours.split(":")[0]).abs() * 60 +
        int.parse(workHours.split(":")[1]);
    print(workHoursMin);

    int overtimeMin = workHoursMin - workingTimeMin;
    print(overtimeMin);
    String sign;
    if (overtimeMin.isNegative) {
      sign = "+";
    } else {
      sign = "-";
    }
    overtimeMin = overtimeMin.abs();
    String overtime;
    if (overtimeMin.abs() >= 60) {
      String h =
          (overtimeMin / 60).floor() < 10
              ? "0${(overtimeMin / 60).floor()}"
              : "${(overtimeMin / 60).floor()}";
      String m =
          ((overtimeMin / 60 - (overtimeMin / 60).floor()) * 60).round() < 10
              ? "0${((overtimeMin / 60 - (overtimeMin / 60).floor()) * 60).round()}"
              : "${((overtimeMin / 60 - (overtimeMin / 60).floor()) * 60).round()}";

      overtime = "${sign}${h}:${m}";

      return overtime;
    } else {
      String m =
          ((overtimeMin / 60 - (overtimeMin / 60).floor()) * 60).round() < 10
              ? "0${((overtimeMin / 60 - (overtimeMin / 60).floor()) * 60).round()}"
              : "${((overtimeMin / 60 - (overtimeMin / 60).floor()) * 60).round()}";

      overtime = "${sign}00:${m}";
      return overtime;
    }
  }

  Duration _parseTimeToDurationOverTime(String time) {
    // Split the time into hours and minutes
    List<String> timeParts = time.split(":");
    int hours = int.parse(timeParts[0]);
    int minutes = int.parse(timeParts[1]);

    // Check if the time is negative (e.g., "-05:00")
    if (hours < 0) {
      // Create a negative duration
      return Duration(hours: hours, minutes: minutes);
    } else {
      // Create a positive duration
      return Duration(hours: hours, minutes: minutes);
    }
  }

  // Helper function to parse "HH:mm" into Duration
  Duration _parseTimeToDuration(String time) {
    // Split the time into hours and minutes
    List<String> timeParts = time.split(":");
    int hours = int.parse(timeParts[0]);
    int minutes = int.parse(timeParts[1]);

    // Check if the time is negative (e.g., "-05:00")
    if (hours < 0) {
      // Create a negative duration
      return Duration(hours: hours, minutes: minutes);
    } else {
      // Create a positive duration
      return Duration(hours: hours, minutes: minutes);
    }
  }

  String calculateWorkHours(String h1, String h2) {
    try {
      int workingTimeMin =
          int.parse(h1.split(":")[0]).abs() * 60 + int.parse(h1.split(":")[1]);
      print(workingTimeMin);
      int workHoursMin =
          int.parse(h2.split(":")[0]).abs() * 60 + int.parse(h2.split(":")[1]);
      print(workHoursMin);

      int durationMin =
          h1.contains("-") || h2.contains("-")
              ? workHoursMin + workingTimeMin
              : (workHoursMin - workingTimeMin).abs();
      String duration;
      if (durationMin.abs() >= 60) {
        String h =
            (durationMin / 60).floor() < 10
                ? "0${(durationMin / 60).floor()}"
                : "${(durationMin / 60).floor()}";
        String m =
            ((durationMin / 60 - (durationMin / 60).floor()) * 60).round() < 10
                ? "0${((durationMin / 60 - (durationMin / 60).floor()) * 60).round()}"
                : "${((durationMin / 60 - (durationMin / 60).floor()) * 60).round()}";

        duration = "${h}:${m}";

        return duration;
      } else {
        String m =
            ((durationMin / 60 - (durationMin / 60).floor()) * 60).round() < 10
                ? "0${((durationMin / 60 - (durationMin / 60).floor()) * 60).round()}"
                : "${((durationMin / 60 - (durationMin / 60).floor()) * 60).round()}";

        duration = "00:${m}";
        return duration;
      }
    } catch (e) {
      print("error hh");
      return profileBox.get(widget.currentProfile).workHours.split(";")[0];
    }
  }

  void setDefaultValues(int defaultIndex) {
    Profile p = profileBox.get(widget.currentProfile);
    _startController = TextEditingController(
      text:
          p.defaultTime.split(";")[defaultIndex].split("/")[0] != ""
              ? p.defaultTime.split(";")[defaultIndex].split("/")[0]
              : "00:00",
    );
    _endController = TextEditingController(
      text:
          p.defaultTime.split(";")[defaultIndex].split("/")[1] != ""
              ? p.defaultTime.split(";")[defaultIndex].split("/")[1]
              : "00:00",
    );
    _breakController = TextEditingController(
      text:
          p.breakDuration.split(";")[defaultIndex] != ""
              ? p.breakDuration.split(";")[defaultIndex]
              : "00:00",
    );
    _workHoursController = TextEditingController(
      text:
          p.workHours.split(";")[defaultIndex] != ""
              ? p.workHours.split(";")[defaultIndex]
              : "00:00",
    );
    _hourWageController = TextEditingController(
      text: p.hourlyWage.isNaN ? "0" : p.hourlyWage.toString(),
    );
  }

  @override
  void initState() {
    super.initState();

    _startController = TextEditingController(
      text: widget.shift.shiftStart.toString(),
    );
    _endController = TextEditingController(
      text: widget.shift.shiftEnd.toString(),
    );
    _breakController = TextEditingController(
      text: widget.shift.breakDuration.toString(),
    );
    _workHoursController = TextEditingController(
      text: calculateWorkHours(
        widget.shift.workedHours,
        widget.shift.workHours,
      ),
    );
    _hourWageController = TextEditingController(
      text: widget.shift.shiftWage.toString(),
    );
    _moneyController = TextEditingController(
      text: widget.shift.money.toStringAsFixed(2),
    );
    _notesController = TextEditingController(text: widget.shift.note);

    try {
      hTravaille =
          _calculateDuration(
            _startController.text,
            _endController.text,
            _breakController.text,
          ).toString();
    } catch (e) {
      print("ici!");
    }
  }

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    _breakController.dispose();
    _workHoursController.dispose();
    _hourWageController.dispose();
    _moneyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // Function to show a time picker and update the corresponding controller
  Future<void> _selectTime(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      // Convert to 24-hour format using DateFormat
      final DateFormat formatter = DateFormat.Hm(); // Hm for 24-hour format
      final DateTime time = DateTime(
        0,
        1,
        1,
        pickedTime.hour,
        pickedTime.minute,
      );
      final String formattedTime = formatter.format(time);

      controller.text =
          formattedTime; // Update the controller text with the formatted time
    }
  }

  void _saveShift() {
    Profile profile = profileBox.get(widget.currentProfile);
    if (!widget.shift.date.contains("+")) {
      for (Shift shift in profile.shifts) {
        if (shift.date == widget.shift.date) {
          profile.shifts.remove(shift);
          break;
        }
      }
    }

    try {
      profile.shifts.add(
        Shift(
          date:
              widget.shift.date.contains("+")
                  ? widget.shift.date.split("+")[0]
                  : widget.shift.date,
          shiftStart: _startController.text,
          shiftEnd: _endController.text,
          workedHours:
              _calculateDuration(
                _startController.text,
                _endController.text,
                _breakController.text,
              ).toString(),
          workHours: _calculateOvertime(
            _calculateDuration(
              _startController.text,
              _endController.text,
              _breakController.text,
            ).toString(),
            _workHoursController.text,
          ),
          breakDuration: _breakController.text,
          money: double.parse(_moneyController.text),
          meal: widget.shift.meal,
          shiftWage: int.parse(_hourWageController.text),
          note: _notesController.text,
          isVacation: widget.shift.isVacation,
        ),
      );
    } catch (e) {
      profile.shifts.add(
        Shift(
          date:
              widget.shift.date.contains("+")
                  ? widget.shift.date.split("+")[0]
                  : widget.shift.date,
          shiftStart: "00:00",
          shiftEnd: "00:00",
          workedHours: "00:00",
          workHours: "00:00",
          breakDuration: "00:00",
          money: 0,
          meal: widget.shift.meal,
          shiftWage: 0,
          note: _notesController.text,
          isVacation: widget.shift.isVacation,
        ),
      );
    }

    profileBox.put(widget.currentProfile, profile);
    if (widget.shiftDate != "Veuillez insérer les horaires de ce jour :") {
      Navigator.pop(context, true);
    } else {
      setState(() {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen(currentIndex: 0)),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    widget.addShift = widget.shift.shiftStart != "-";
    String overtimeValue = "00:00";
    try {
      overtimeValue = _calculateOvertime(
        _calculateDuration(
          _startController.text,
          _endController.text,
          _breakController.text,
        ).toString(),
        _workHoursController.text,
      );
    } catch (e) {
      overtimeValue = "00:00";
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.shiftDate,
          style: TextStyle(fontSize: widget.titleSize),
        ),
        scrolledUnderElevation: 0.0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: appColor,
        foregroundColor: textColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _startController,
                      readOnly: true, // Make it read-only to avoid manual input
                      decoration: InputDecoration(labelText: 'Début'),
                      onTap: () async {
                        if (!isDefault && !widget.shift.isVacation) {
                          await _selectTime(context, _startController);
                        }
                        setState(() {
                          hTravaille =
                              _calculateDuration(
                                _startController.text,
                                _endController.text,
                                _breakController.text,
                              ).toString();
                          _moneyController.text = (double.parse(
                                    _hourWageController.text,
                                  ) *
                                  (_calculateDurationInHours(
                                    "00:00",
                                    hTravaille,
                                    "00:00",
                                  )))
                              .toStringAsFixed(2);
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _endController,
                      readOnly: true, // Make it read-only to avoid manual input
                      decoration: InputDecoration(labelText: 'Fin'),
                      onTap: () async {
                        if (!isDefault && !widget.shift.isVacation) {
                          await _selectTime(context, _endController);
                        }
                        setState(() {
                          hTravaille =
                              _calculateDuration(
                                _startController.text,
                                _endController.text,
                                _breakController.text,
                              ).toString();
                          _moneyController.text = (double.parse(
                                    _hourWageController.text,
                                  ) *
                                  (_calculateDurationInHours(
                                    "00:00",
                                    hTravaille,
                                    "00:00",
                                  )))
                              .toStringAsFixed(2);
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _breakController,
                      readOnly:
                          true, // Make it read-only to avoid manual InputDecoration

                      decoration: InputDecoration(labelText: 'Pause'),
                      onTap: () async {
                        if (!isDefault && !widget.shift.isVacation) {
                          await _selectTime(context, _breakController);
                        }
                        setState(() {
                          hTravaille =
                              _calculateDuration(
                                _startController.text,
                                _endController.text,
                                _breakController.text,
                              ).toString();
                          _moneyController.text = (double.parse(
                                    _hourWageController.text,
                                  ) *
                                  (_calculateDurationInHours(
                                    "00:00",
                                    hTravaille,
                                    "00:00",
                                  )))
                              .toStringAsFixed(2);
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _workHoursController,
                      readOnly: true,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Heures de Travail',
                      ),
                      onTap: () {
                        setState(() {
                          if (!isDefault && !widget.shift.isVacation) {
                            _selectTime(context, _workHoursController);
                          }
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _hourWageController,
                      readOnly: isDefault || widget.shift.isVacation,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'Salaire par h'),
                      onChanged: (value) {
                        setState(() {
                          _moneyController.text = (double.parse(
                                    _hourWageController.text,
                                  ) *
                                  (_calculateDurationInHours(
                                    "00:00",
                                    hTravaille,
                                    "00:00",
                                  )))
                              .toStringAsFixed(2);
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _moneyController,
                      keyboardType: TextInputType.number,
                      readOnly: true,
                      decoration: InputDecoration(labelText: 'Salaire'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text("Utilser les valeurs standard ?"),
                  ),
                  Expanded(
                    flex: 1,
                    child: Switch(
                      activeColor: appColor,
                      value: isDefault,
                      onChanged: (value) {
                        setState(() {
                          isDefault = value;
                          widget.shift.isVacation = false;
                          setDefaultValues(selectedDefault);
                          hTravaille =
                              _calculateDuration(
                                _startController.text,
                                _endController.text,
                                _breakController.text,
                              ).toString();
                          _moneyController.text = (double.parse(
                                    _hourWageController.text,
                                  ) *
                                  (_calculateDurationInHours(
                                    "00:00",
                                    hTravaille,
                                    "00:00",
                                  )))
                              .toStringAsFixed(2);
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              if (isDefault)
                Column(
                  children: [
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
                                  setDefaultValues(selectedDefault);
                                  hTravaille =
                                      _calculateDuration(
                                        _startController.text,
                                        _endController.text,
                                        _breakController.text,
                                      ).toString();
                                  _moneyController.text = (double.parse(
                                            _hourWageController.text,
                                          ) *
                                          (_calculateDurationInHours(
                                            "00:00",
                                            hTravaille,
                                            "00:00",
                                          )))
                                      .toStringAsFixed(2);
                                });
                              },
                            ),
                            Text("${index + 1}"),
                          ],
                        );
                      }),
                    ),
                    SizedBox(height: 32),
                  ],
                ),

              Text(
                "Heures Travaillées : ${hTravaille} h",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 30),
              Text(
                "Heures Supplémentaires : ${overtimeValue.contains("-") ? "00:00" : overtimeValue} h",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 30),
              Row(
                children: [
                  Expanded(flex: 2, child: Text("Jour de vacances ?")),
                  Expanded(
                    flex: 1,
                    child: Switch(
                      activeColor: appColor,
                      value: widget.shift.isVacation,
                      onChanged: (value) {
                        setState(() {
                          isDefault = false;
                          widget.shift.isVacation = !widget.shift.isVacation;

                          _startController = TextEditingController(text: "-");
                          _endController = TextEditingController(text: "-");
                          _breakController = TextEditingController(text: "-");
                          _workHoursController = TextEditingController(
                            text: "-",
                          );
                          _hourWageController = TextEditingController(
                            text: "-",
                          );
                          _moneyController = TextEditingController(text: "-");
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Text(
                "Notes",
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 30),
              TextField(
                controller: _notesController,
                minLines: 3,
                maxLines: null, // Allows unlimited lines
                keyboardType:
                    TextInputType.multiline, // Enables multi-line input
                decoration: InputDecoration(
                  hintText: "Entrez vos notes...",
                  border: OutlineInputBorder(), // Default border
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey,
                    ), // Default border color
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: appColor,
                      width: 2,
                    ), // Border when focused
                  ),
                  contentPadding: EdgeInsets.all(
                    16,
                  ), // Padding for better spacing
                ),
                style: TextStyle(fontSize: 16), // Customize text style
              ),

              SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: _saveShift,
                  child: Text('Sauvegarder'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appColor,
                    foregroundColor: textColor,
                  ),
                ),
              ),
              SizedBox(height: 15),
              widget.shiftDate != "Veuillez insérer les horaires de ce jour :"
                  ? Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Profile newP = profileBox.get(widget.currentProfile);
                        newP.shifts.remove(widget.shift);
                        profileBox.put(widget.currentProfile, newP);
                        Navigator.pop(context, true);
                      },
                      child: Text('Supprimer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: textColor,
                      ),
                    ),
                  )
                  : Container(),
              SizedBox(height: 16),
              widget.addShift
                  ? Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Profile profile = profileBox.get(widget.currentProfile);
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ShiftEditor(
                                  shift: Shift(
                                    date: "${widget.shift.date}+",
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
                                  currentProfile: widget.currentProfile,
                                  shiftDate: widget.shiftDate,
                                  titleSize: 25,
                                ),
                          ),
                        );
                      },
                      child: Text("Nouveau"),
                    ),
                  )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
