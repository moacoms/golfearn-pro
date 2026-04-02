import '../../domain/entities/income_entity.dart';

class IncomeModel {
  final String id;
  final String proId;
  final String? studentId;
  final String? packageId;
  final String category; // DB: income_type
  final int amount;
  final DateTime incomeDate; // DB: payment_date
  final String? description; // DB: memo
  final String paymentMethod;
  final bool taxIncluded;
  final String? studentName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const IncomeModel({
    required this.id,
    required this.proId,
    this.studentId,
    this.packageId,
    this.category = 'lesson',
    required this.amount,
    required this.incomeDate,
    this.description,
    this.paymentMethod = 'cash',
    this.taxIncluded = false,
    this.studentName,
    this.createdAt,
    this.updatedAt,
  });

  factory IncomeModel.fromJson(Map<String, dynamic> json) {
    String? name;
    if (json['lesson_students'] != null && json['lesson_students'] is Map) {
      name = json['lesson_students']['student_name'] as String?;
    }

    return IncomeModel(
      id: json['id'] as String,
      proId: json['pro_id'] as String,
      studentId: json['student_id'] as String?,
      packageId: json['package_id'] as String?,
      category: json['income_type'] as String? ?? 'lesson',
      amount: json['amount'] as int,
      incomeDate: DateTime.parse(json['payment_date'] as String),
      description: json['memo'] as String?,
      paymentMethod: json['payment_method'] as String? ?? 'cash',
      taxIncluded: json['tax_included'] as bool? ?? false,
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
      'income_type': category,
      'amount': amount,
      'payment_date': incomeDate.toIso8601String().split('T').first,
      'memo': description,
      'payment_method': paymentMethod,
      'tax_included': taxIncluded,
    };
  }

  IncomeEntity toEntity() {
    return IncomeEntity(
      id: id,
      proId: proId,
      studentId: studentId,
      packageId: packageId,
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
