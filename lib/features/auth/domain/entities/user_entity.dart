class UserEntity {
  final String id;
  final String email;
  final String? fullName;
  final String? phoneNumber;
  final String? avatarUrl;
  final bool isLessonPro;
  final bool isStudent;
  final bool isAdmin;
  final String sportType; // golf, tennis, badminton, swimming, pilates_yoga, other
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserEntity({
    required this.id,
    required this.email,
    this.fullName,
    this.phoneNumber,
    this.avatarUrl,
    this.isLessonPro = false,
    this.isStudent = false,
    this.isAdmin = false,
    this.sportType = 'golf',
    this.createdAt,
    this.updatedAt,
  });

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      isLessonPro: json['isLessonPro'] as bool? ?? false,
      isStudent: json['isStudent'] as bool? ?? false,
      isAdmin: json['isAdmin'] as bool? ?? false,
      sportType: json['sportType'] as String? ?? 'golf',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'avatarUrl': avatarUrl,
      'isLessonPro': isLessonPro,
      'isStudent': isStudent,
      'isAdmin': isAdmin,
      'sportType': sportType,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  UserEntity copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phoneNumber,
    String? avatarUrl,
    bool? isLessonPro,
    bool? isStudent,
    bool? isAdmin,
    String? sportType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isLessonPro: isLessonPro ?? this.isLessonPro,
      isStudent: isStudent ?? this.isStudent,
      isAdmin: isAdmin ?? this.isAdmin,
      sportType: sportType ?? this.sportType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserEntity &&
        other.id == id &&
        other.email == email &&
        other.fullName == fullName &&
        other.phoneNumber == phoneNumber &&
        other.avatarUrl == avatarUrl &&
        other.isLessonPro == isLessonPro &&
        other.isStudent == isStudent &&
        other.isAdmin == isAdmin &&
        other.sportType == sportType &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      email,
      fullName,
      phoneNumber,
      avatarUrl,
      isLessonPro,
      isStudent,
      isAdmin,
      sportType,
      createdAt,
      updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserEntity(id: $id, email: $email, fullName: $fullName, phoneNumber: $phoneNumber, avatarUrl: $avatarUrl, isLessonPro: $isLessonPro, isStudent: $isStudent, isAdmin: $isAdmin, sportType: $sportType, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}