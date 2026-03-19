import '../../domain/entities/lesson_note_entity.dart';

class LessonNoteModel {
  final String id;
  final String proId;
  final String studentId;
  final String? scheduleId;
  final DateTime lessonDate;
  final String? title;
  final String? content;
  final String? improvement;
  final String? homework;
  final String? studentName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const LessonNoteModel({
    required this.id,
    required this.proId,
    required this.studentId,
    this.scheduleId,
    required this.lessonDate,
    this.title,
    this.content,
    this.improvement,
    this.homework,
    this.studentName,
    this.createdAt,
    this.updatedAt,
  });

  factory LessonNoteModel.fromJson(Map<String, dynamic> json) {
    String? name;
    if (json['lesson_students'] != null) {
      name = json['lesson_students']['student_name'] as String?;
    }

    return LessonNoteModel(
      id: json['id'] as String,
      proId: json['pro_id'] as String,
      studentId: json['student_id'] as String,
      scheduleId: json['schedule_id'] as String?,
      lessonDate: DateTime.parse(json['lesson_date'] as String),
      title: json['title'] as String?,
      content: json['content'] as String?,
      improvement: json['improvement'] as String?,
      homework: json['homework'] as String?,
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
      if (scheduleId != null) 'schedule_id': scheduleId,
      'lesson_date': lessonDate.toIso8601String().split('T').first,
      'title': title,
      'content': content,
      'improvement': improvement,
      'homework': homework,
    };
  }

  LessonNoteEntity toEntity() {
    return LessonNoteEntity(
      id: id,
      proId: proId,
      studentId: studentId,
      scheduleId: scheduleId,
      lessonDate: lessonDate,
      title: title,
      content: content,
      improvement: improvement,
      homework: homework,
      studentName: studentName,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
