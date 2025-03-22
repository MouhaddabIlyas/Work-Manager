// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProfileAdapter extends TypeAdapter<Profile> {
  @override
  final int typeId = 0;

  @override
  Profile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Profile(
      name: fields[0] as String,
      shifts: (fields[1] as List).cast<Shift>(),
      hourlyWage: fields[2] as int,
      workHours: fields[3] as String,
      vacations: fields[4] as int,
      selected: fields[5] as bool,
      defaultTime: fields[6] as String,
      breakDuration: fields[7] as String,
      meals: (fields[8] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Profile obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.shifts)
      ..writeByte(2)
      ..write(obj.hourlyWage)
      ..writeByte(3)
      ..write(obj.workHours)
      ..writeByte(4)
      ..write(obj.vacations)
      ..writeByte(5)
      ..write(obj.selected)
      ..writeByte(6)
      ..write(obj.defaultTime)
      ..writeByte(7)
      ..write(obj.breakDuration)
      ..writeByte(8)
      ..write(obj.meals);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
