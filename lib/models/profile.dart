import 'package:hive/hive.dart';
import 'package:work_manager/models/shift.dart';

part 'profile.g.dart';

@HiveType(typeId: 0)
class Profile {
  Profile({
    required this.name,
    required this.shifts,
    required this.hourlyWage,
    required this.workHours,
    required this.vacations,
    required this.selected,
    required this.defaultTime,
    required this.breakDuration,
    required this.meals,

  });
  @HiveField(0)
  String name;

  @HiveField(1)
  List<Shift> shifts;

  @HiveField(2)
  int hourlyWage;

  @HiveField(3)
  String workHours;

  @HiveField(4)
  int vacations;

  @HiveField(5)
  bool selected;

  @HiveField(6)
  String defaultTime;

  @HiveField(7)
  String breakDuration;

  @HiveField(8)
  List<String> meals;
}
