import '../../domain/entities/schedule_entity.dart';

class ScheduleModel {
  final String id;
  final String proId;
  final String studentId;
  final String? packageId;
  final DateTime lessonDate;
  final String lessonTime;
  final int durationMinutes;
  final String status;
  final String? location;
  final String? lessonType;
  final String? memo;
  final String? studentName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ScheduleModel({
    required this.id,
    required this.proId,
    required this.studentId,
    this.packageId,
    required this.lessonDate,
    required this.lessonTime,
    this.durationMinutes = 60,
    this.status = 'scheduled',
    this.location,
    this.lessonType,
    this.memo,
    this.studentName,
    this.createdAt,
    this.updatedAt,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    String? name = json['student_name'] as String?;
    if (name == null && json['lesson_students'] != null) {
      name = json['lesson_students']['student_name'] as String?;
    }

    return ScheduleModel(
      id: json['id'] as String,
      proId: json['pro_id'] as String,
      studentId: json['student_id'] as String,
      packageId: json['package_id'] as String?,
      lessonDate: DateTime.parse(json['lesson_date'] as String),
      lessonTime: json['lesson_time'] as String,
      durationMinutes: json['duration_minutes'] as int? ?? 60,
      status: json['status'] as String? ?? 'scheduled',
      location: json['location'] as String?,
      lessonType: json['lesson_type'] as String?,
      memo: json['memo'] as String?,
      studentName: name,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pro_id': proId,
      'student_id': studentId,
      if (packageId != null) 'package_id': packageId,
      'lesson_date': lessonDate.toIso8601String().split('T').first,
      'lesson_time': lessonTime,
      'duration_minutes': durationMinutes,
      'status': status,
      'location': location,
      'lesson_type': lessonType,
      'memo': memo,
    };
  }

  ScheduleEntity toEntity() {
    return ScheduleEntity(
      id: id,
      proId: proId,
      studentId: studentId,
      packageId: packageId,
      lessonDate: lessonDate,
      lessonTime: lessonTime,
      durationMinutes: durationMinutes,
      status: status,
      location: location,
      lessonType: lessonType,
      memo: memo,
      studentName: studentName,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
