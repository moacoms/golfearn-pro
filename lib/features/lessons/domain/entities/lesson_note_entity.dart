class LessonNoteEntity {
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

  const LessonNoteEntity({
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

  LessonNoteEntity copyWith({
    String? id,
    String? proId,
    String? studentId,
    String? scheduleId,
    DateTime? lessonDate,
    String? title,
    String? content,
    String? improvement,
    String? homework,
    String? studentName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LessonNoteEntity(
      id: id ?? this.id,
      proId: proId ?? this.proId,
      studentId: studentId ?? this.studentId,
      scheduleId: scheduleId ?? this.scheduleId,
      lessonDate: lessonDate ?? this.lessonDate,
      title: title ?? this.title,
      content: content ?? this.content,
      improvement: improvement ?? this.improvement,
      homework: homework ?? this.homework,
      studentName: studentName ?? this.studentName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LessonNoteEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
