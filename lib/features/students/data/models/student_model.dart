import '../../domain/entities/student_entity.dart';

class StudentModel {
  final String id;
  final String proId;
  final String? userId;
  final String studentName;
  final String? studentPhone;
  final String? studentEmail;
  final String? studentMemo;
  final String? currentLevel;
  final String? goal;
  final DateTime? birthDate;
  final String? gender;
  final DateTime? startedGolfAt;
  final int? averageScore;
  final int totalLessonCount;
  final DateTime? lastLessonAt;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const StudentModel({
    required this.id,
    required this.proId,
    this.userId,
    required this.studentName,
    this.studentPhone,
    this.studentEmail,
    this.studentMemo,
    this.currentLevel,
    this.goal,
    this.birthDate,
    this.gender,
    this.startedGolfAt,
    this.averageScore,
    this.totalLessonCount = 0,
    this.lastLessonAt,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'] as String,
      proId: json['pro_id'] as String,
      userId: json['user_id'] as String?,
      studentName: json['student_name'] as String,
      studentPhone: json['student_phone'] as String?,
      studentEmail: json['student_email'] as String?,
      studentMemo: json['student_memo'] as String?,
      currentLevel: json['current_level'] as String?,
      goal: json['goal'] as String?,
      birthDate: json['birth_date'] != null
          ? DateTime.parse(json['birth_date'] as String)
          : null,
      gender: json['gender'] as String?,
      startedGolfAt: json['started_golf_at'] != null
          ? DateTime.parse(json['started_golf_at'] as String)
          : null,
      averageScore: json['average_score'] as int?,
      totalLessonCount: json['total_lesson_count'] as int? ?? 0,
      lastLessonAt: json['last_lesson_at'] != null
          ? DateTime.parse(json['last_lesson_at'] as String)
          : null,
      isActive: json['is_active'] as bool? ?? true,
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
      if (userId != null) 'user_id': userId,
      'student_name': studentName,
      'student_phone': studentPhone,
      'student_email': studentEmail,
      'student_memo': studentMemo,
      'current_level': currentLevel,
      'goal': goal,
      'birth_date': birthDate?.toIso8601String().split('T').first,
      'gender': gender,
      'started_golf_at': startedGolfAt?.toIso8601String().split('T').first,
      'average_score': averageScore,
      'total_lesson_count': totalLessonCount,
      'is_active': isActive,
    };
  }

  StudentEntity toEntity() {
    return StudentEntity(
      id: id,
      proId: proId,
      userId: userId,
      studentName: studentName,
      studentPhone: studentPhone,
      studentEmail: studentEmail,
      studentMemo: studentMemo,
      currentLevel: currentLevel,
      goal: goal,
      birthDate: birthDate,
      gender: gender,
      startedGolfAt: startedGolfAt,
      averageScore: averageScore,
      totalLessonCount: totalLessonCount,
      lastLessonAt: lastLessonAt,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
