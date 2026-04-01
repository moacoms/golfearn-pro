class StudentEntity {
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
  final String? groupName;
  final String? familyGroupId;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const StudentEntity({
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
    this.groupName,
    this.familyGroupId,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  StudentEntity copyWith({
    String? id,
    String? proId,
    String? userId,
    String? studentName,
    String? studentPhone,
    String? studentEmail,
    String? studentMemo,
    String? currentLevel,
    String? goal,
    DateTime? birthDate,
    String? gender,
    DateTime? startedGolfAt,
    int? averageScore,
    int? totalLessonCount,
    DateTime? lastLessonAt,
    String? groupName,
    String? familyGroupId,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StudentEntity(
      id: id ?? this.id,
      proId: proId ?? this.proId,
      userId: userId ?? this.userId,
      studentName: studentName ?? this.studentName,
      studentPhone: studentPhone ?? this.studentPhone,
      studentEmail: studentEmail ?? this.studentEmail,
      studentMemo: studentMemo ?? this.studentMemo,
      currentLevel: currentLevel ?? this.currentLevel,
      goal: goal ?? this.goal,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      startedGolfAt: startedGolfAt ?? this.startedGolfAt,
      averageScore: averageScore ?? this.averageScore,
      totalLessonCount: totalLessonCount ?? this.totalLessonCount,
      lastLessonAt: lastLessonAt ?? this.lastLessonAt,
      groupName: groupName ?? this.groupName,
      familyGroupId: familyGroupId ?? this.familyGroupId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StudentEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
