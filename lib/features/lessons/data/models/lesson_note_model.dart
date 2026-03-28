import '../../domain/entities/lesson_note_entity.dart';

class LessonNoteModel {
  final String id;
  final String proId;
  final String studentId;
  final String? scheduleId;
  final String? manualNote;
  final String? homework;
  final String? nextFocus;
  final List<String>? keyPoints;
  final List<String>? improvements;
  final int? practiceTimeMinutes;
  final String? studentName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const LessonNoteModel({
    required this.id,
    required this.proId,
    required this.studentId,
    this.scheduleId,
    this.manualNote,
    this.homework,
    this.nextFocus,
    this.keyPoints,
    this.improvements,
    this.practiceTimeMinutes,
    this.studentName,
    this.createdAt,
    this.updatedAt,
  });

  factory LessonNoteModel.fromJson(Map<String, dynamic> json) {
    // 학생 이름: join된 lesson_students에서 가져오기
    String? name;
    if (json['lesson_students'] != null && json['lesson_students'] is Map) {
      name = json['lesson_students']['student_name'] as String?;
    }

    return LessonNoteModel(
      id: json['id'] as String,
      proId: json['pro_id'] as String,
      studentId: json['student_id'] as String,
      scheduleId: json['schedule_id'] as String?,
      manualNote: json['manual_note'] as String?,
      homework: json['homework'] as String?,
      nextFocus: json['next_focus'] as String?,
      keyPoints: json['key_points'] != null
          ? List<String>.from(json['key_points'])
          : null,
      improvements: json['improvements'] != null
          ? List<String>.from(json['improvements'])
          : null,
      practiceTimeMinutes: json['practice_time_minutes'] as int?,
      studentName: name,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  LessonNoteEntity toEntity() {
    return LessonNoteEntity(
      id: id,
      proId: proId,
      studentId: studentId,
      scheduleId: scheduleId,
      manualNote: manualNote,
      homework: homework,
      nextFocus: nextFocus,
      keyPoints: keyPoints,
      improvements: improvements,
      practiceTimeMinutes: practiceTimeMinutes,
      studentName: studentName,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
