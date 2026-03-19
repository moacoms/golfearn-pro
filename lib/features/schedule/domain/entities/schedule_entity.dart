class ScheduleEntity {
  final String id;
  final String proId;
  final String studentId;
  final String? packageId;
  final DateTime lessonDate;
  final String lessonTime; // "HH:mm" 형식
  final int durationMinutes;
  final String status; // scheduled, completed, cancelled, no_show
  final String? location;
  final String? lessonType; // regular, playing, short_game, putting
  final String? memo;
  final String? studentName; // join으로 가져올 때
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ScheduleEntity({
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

  ScheduleEntity copyWith({
    String? id,
    String? proId,
    String? studentId,
    String? packageId,
    DateTime? lessonDate,
    String? lessonTime,
    int? durationMinutes,
    String? status,
    String? location,
    String? lessonType,
    String? memo,
    String? studentName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ScheduleEntity(
      id: id ?? this.id,
      proId: proId ?? this.proId,
      studentId: studentId ?? this.studentId,
      packageId: packageId ?? this.packageId,
      lessonDate: lessonDate ?? this.lessonDate,
      lessonTime: lessonTime ?? this.lessonTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      status: status ?? this.status,
      location: location ?? this.location,
      lessonType: lessonType ?? this.lessonType,
      memo: memo ?? this.memo,
      studentName: studentName ?? this.studentName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get statusLabel {
    switch (status) {
      case 'scheduled': return '예정';
      case 'completed': return '완료';
      case 'cancelled': return '취소';
      case 'no_show': return '노쇼';
      default: return status;
    }
  }

  String get lessonTypeLabel {
    switch (lessonType) {
      case 'regular': return '일반 레슨';
      case 'playing': return '필드 레슨';
      case 'short_game': return '숏게임';
      case 'putting': return '퍼팅';
      default: return lessonType ?? '일반 레슨';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ScheduleEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
