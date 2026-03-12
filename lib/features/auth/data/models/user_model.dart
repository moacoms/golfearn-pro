import '../../domain/entities/user_entity.dart';

class UserModel {
  final String id;
  final String email;
  final String? fullName;
  final String? phoneNumber;
  final String? avatarUrl;
  final bool isLessonPro;
  final bool isStudent;
  final bool isAdmin;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.phoneNumber,
    this.avatarUrl,
    this.isLessonPro = false,
    this.isStudent = false,
    this.isAdmin = false,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      phoneNumber: json['phone_number'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      isLessonPro: json['is_lesson_pro'] as bool? ?? false,
      isStudent: json['is_student'] as bool? ?? false,
      isAdmin: json['is_admin'] as bool? ?? false,
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
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'avatar_url': avatarUrl,
      'is_lesson_pro': isLessonPro,
      'is_student': isStudent,
      'is_admin': isAdmin,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

extension UserModelX on UserModel {
  UserEntity toEntity() => UserEntity(
        id: id,
        email: email,
        fullName: fullName,
        phoneNumber: phoneNumber,
        avatarUrl: avatarUrl,
        isLessonPro: isLessonPro,
        isStudent: isStudent,
        isAdmin: isAdmin,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}