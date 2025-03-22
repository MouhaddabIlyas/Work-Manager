import 'package:hive/hive.dart';

part 'shift.g.dart';

@HiveType(typeId: 1)
class Shift {
  @HiveField(0)
  String date;
  @HiveField(1)
  String shiftStart;
  @HiveField(2)
  String shiftEnd;
  @HiveField(3)
  String workedHours;
  @HiveField(4)
  String workHours;
  @HiveField(5)
  String breakDuration;
  @HiveField(6)
  double money;
  @HiveField(7)
  bool meal;
  @HiveField(8)
  int shiftWage;
  @HiveField(9)
  String note;
  @HiveField(10)
  bool isVacation;

  Shift({
    required this.date,
    required this.shiftStart,
    required this.shiftEnd,
    required this.workedHours,
    required this.workHours,
    required this.breakDuration,
    required this.money,
    required this.meal,
    required this.shiftWage,
    required this.note,
    this.isVacation = false,
  });
}
