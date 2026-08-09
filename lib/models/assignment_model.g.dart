// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assignment_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AssignmentModelAdapter extends TypeAdapter<AssignmentModel> {
  @override
  final int typeId = 1;

  @override
  AssignmentModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AssignmentModel(
      id: fields[0] as String,
      title: fields[1] as String,
      courseName: fields[2] as String? ?? '',
      description: fields[3] as String? ?? '',
      dueDate: fields[4] as DateTime?,
      dueTime: fields[5] as String?,
      priority: fields[6] as int? ?? 1,
      isSubmitted: fields[7] as bool? ?? false,
      marksObtained: fields[8] as double?,
      totalMarks: fields[9] as double?,
      reminderEnabled: fields[10] as bool? ?? false,
      reminderMinutes: fields[11] as int? ?? 30,
      createdAt: fields[12] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, AssignmentModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.courseName)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.dueDate)
      ..writeByte(5)
      ..write(obj.dueTime)
      ..writeByte(6)
      ..write(obj.priority)
      ..writeByte(7)
      ..write(obj.isSubmitted)
      ..writeByte(8)
      ..write(obj.marksObtained)
      ..writeByte(9)
      ..write(obj.totalMarks)
      ..writeByte(10)
      ..write(obj.reminderEnabled)
      ..writeByte(11)
      ..write(obj.reminderMinutes)
      ..writeByte(12)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssignmentModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
