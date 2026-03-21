import '../../domain/entities/income_entity.dart';

class IncomeModel {
  final String id;
  final String proId;
  final String? studentId;
  final String? packageId;
  final String? scheduleId;
  final String category;
  final int amount;
  final DateTime incomeDate;
  final String? description;
  final String paymentMethod;
  final String? studentName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const IncomeModel({
    required this.id,
    required this.proId,
    this.studentId,
    this.packageId,
    this.scheduleId,
    this.category = 'lesson',
    required this.amount,
    required this.incomeDate,
    this.description,
    this.paymentMethod = 'cash',
    this.studentName,
    this.createdAt,
    this.updatedAt,
  });

  factory IncomeModel.fromJson(Map<String, dynamic> json) {
    String? name = json['student_name'] as String?;
    if (name == null && json['lesson_students'] != null) {
      name = json['lesson_students']['student_name'] as String?;
    }

    return IncomeModel(
      id: json['id'] as String,
      proId: json['pro_id'] as String,
      studentId: json['student_id'] as String?,
      packageId: json['package_id'] as String?,
      scheduleId: json['schedule_id'] as String?,
      category: json['category'] as String? ?? 'lesson',
      amount: json['amount'] as int,
      incomeDate: DateTime.parse(json['income_date'] as String),
      description: json['description'] as String?,
      paymentMethod: json['payment_method'] as String? ?? 'cash',
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
      if (studentId != null) 'student_id': studentId,
      if (packageId != null) 'package_id': packageId,
      if (scheduleId != null) 'schedule_id': scheduleId,
      'category': category,
      'amount': amount,
      'income_date': incomeDate.toIso8601String().split('T').first,
      'description': description,
      'payment_method': paymentMethod,
    };
  }

  IncomeEntity toEntity() {
    return IncomeEntity(
      id: id,
      proId: proId,
      studentId: studentId,
      packageId: packageId,
      scheduleId: scheduleId,
      category: category,
      amount: amount,
      incomeDate: incomeDate,
      description: description,
      paymentMethod: paymentMethod,
      studentName: studentName,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
