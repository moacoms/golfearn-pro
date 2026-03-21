import '../../domain/entities/package_entity.dart';

class PackageModel {
  final String id;
  final String proId;
  final String studentId;
  final String packageName;
  final String packageType;
  final int totalCount;
  final int usedCount;
  final int remainingCount;
  final int price;
  final DateTime? startDate;
  final DateTime? endDate;
  final String status;
  final String paymentStatus;
  final int? paidAmount;
  final String? paymentMethod;
  final String? studentName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PackageModel({
    required this.id,
    required this.proId,
    required this.studentId,
    required this.packageName,
    this.packageType = 'count',
    required this.totalCount,
    this.usedCount = 0,
    required this.remainingCount,
    required this.price,
    this.startDate,
    this.endDate,
    this.status = 'active',
    this.paymentStatus = 'pending',
    this.paidAmount,
    this.paymentMethod,
    this.studentName,
    this.createdAt,
    this.updatedAt,
  });

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    String? name = json['student_name'] as String?;
    if (name == null && json['lesson_students'] != null) {
      name = json['lesson_students']['student_name'] as String?;
    }

    return PackageModel(
      id: json['id'] as String,
      proId: json['pro_id'] as String,
      studentId: json['student_id'] as String,
      packageName: json['package_name'] as String? ?? '레슨 패키지',
      packageType: json['package_type'] as String? ?? 'count',
      totalCount: json['total_count'] as int? ?? 0,
      usedCount: json['used_count'] as int? ?? 0,
      remainingCount: json['remaining_count'] as int? ?? 0,
      price: json['price'] as int? ?? 0,
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'] as String)
          : null,
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      status: json['status'] as String? ?? 'active',
      paymentStatus: json['payment_status'] as String? ?? 'pending',
      paidAmount: json['paid_amount'] as int?,
      paymentMethod: json['payment_method'] as String?,
      studentName: name,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  PackageEntity toEntity() {
    return PackageEntity(
      id: id,
      proId: proId,
      studentId: studentId,
      packageName: packageName,
      packageType: packageType,
      totalCount: totalCount,
      usedCount: usedCount,
      remainingCount: remainingCount,
      price: price,
      startDate: startDate,
      endDate: endDate,
      status: status,
      paymentStatus: paymentStatus,
      paidAmount: paidAmount,
      paymentMethod: paymentMethod,
      studentName: studentName,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
