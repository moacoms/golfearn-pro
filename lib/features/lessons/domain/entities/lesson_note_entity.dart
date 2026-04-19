class LessonNoteEntity {
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
  final Map<String, dynamic>? fieldData;
  final String? studentName; // join용
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const LessonNoteEntity({
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
    this.fieldData,
    this.studentName,
    this.createdAt,
    this.updatedAt,
  });

  bool get hasFieldData => fieldData != null && fieldData!.isNotEmpty;

  /// 레슨 날짜 (createdAt 기반)
  DateTime get lessonDate => createdAt ?? DateTime.now();

  /// 제목 대용 (manualNote 앞부분)
  String get title {
    if (manualNote != null && manualNote!.isNotEmpty) {
      final firstLine = manualNote!.split('\n').first;
      return firstLine.length > 30 ? '${firstLine.substring(0, 30)}...' : firstLine;
    }
    return '레슨 노트';
  }

  LessonNoteEntity copyWith({
    String? id,
    String? proId,
    String? studentId,
    String? scheduleId,
    String? manualNote,
    String? homework,
    String? nextFocus,
    List<String>? keyPoints,
    List<String>? improvements,
    int? practiceTimeMinutes,
    Map<String, dynamic>? fieldData,
    String? studentName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LessonNoteEntity(
      id: id ?? this.id,
      proId: proId ?? this.proId,
      studentId: studentId ?? this.studentId,
      scheduleId: scheduleId ?? this.scheduleId,
      manualNote: manualNote ?? this.manualNote,
      homework: homework ?? this.homework,
      nextFocus: nextFocus ?? this.nextFocus,
      keyPoints: keyPoints ?? this.keyPoints,
      improvements: improvements ?? this.improvements,
      practiceTimeMinutes: practiceTimeMinutes ?? this.practiceTimeMinutes,
      fieldData: fieldData ?? this.fieldData,
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
