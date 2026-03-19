class PackageEntity {
  final String id;
  final String proId;
  final String studentId;
  final String packageName;
  final String packageType; // count(횟수제), period(기간제)
  final int totalCount;
  final int usedCount;
  final int remainingCount;
  final int price;
  final DateTime? startDate;
  final DateTime? endDate;
  final String status; // active, expired, completed, cancelled
  final String paymentStatus; // pending, partial, paid
  final int? paidAmount;
  final String? paymentMethod;
  final String? studentName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PackageEntity({
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

  /// 남은 횟수 비율 (0.0 ~ 1.0)
  double get remainingRatio =>
      totalCount > 0 ? remainingCount / totalCount : 0;

  /// 패키지 사용 가능 여부
  bool get isUsable => status == 'active' && remainingCount > 0;

  String get statusLabel {
    switch (status) {
      case 'active': return '사용중';
      case 'expired': return '만료';
      case 'completed': return '소진';
      case 'cancelled': return '취소';
      default: return status;
    }
  }

  String get paymentStatusLabel {
    switch (paymentStatus) {
      case 'pending': return '미결제';
      case 'partial': return '부분결제';
      case 'paid': return '결제완료';
      default: return paymentStatus;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PackageEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
