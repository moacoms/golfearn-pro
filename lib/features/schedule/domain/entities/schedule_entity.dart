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
  final String? recurringGroupId;
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
    this.recurringGroupId,
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
    String? recurringGroupId,
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
      recurringGroupId: recurringGroupId ?? this.recurringGroupId,
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
    // 기본적으로는 코드 내 매핑을 사용 (하위 호환)
    switch (lessonType) {
      case 'regular': return '일반 레슨';
      case 'playing': return '필드 레슨';
      case 'short_game': return '숏게임';
      case 'putting': return '퍼팅';
      case 'forehand': return '포핸드';
      case 'backhand': return '백핸드';
      case 'serve': return '서브';
      case 'match': return '경기';
      case 'basic': return '기본기';
      case 'smash': return '스매시';
      case 'defense': return '수비';
      case 'freestyle': return '자유형';
      case 'backstroke': return '배영';
      case 'breaststroke': return '평영';
      case 'butterfly': return '접영';
      case 'mat': return '매트';
      case 'equipment': return '기구';
      case 'personal': return '개인';
      case 'group': return '그룹';
      case 'practice': return '연습';
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
