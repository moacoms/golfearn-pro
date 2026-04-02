class IncomeEntity {
  final String id;
  final String proId;
  final String? studentId;
  final String? packageId;
  final String category; // lesson, package, other
  final int amount;
  final DateTime incomeDate;
  final String? description;
  final String paymentMethod; // cash, card, transfer, other
  final String? studentName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const IncomeEntity({
    required this.id,
    required this.proId,
    this.studentId,
    this.packageId,
    this.category = 'lesson',
    required this.amount,
    required this.incomeDate,
    this.description,
    this.paymentMethod = 'cash',
    this.studentName,
    this.createdAt,
    this.updatedAt,
  });

  String get categoryLabel {
    switch (category) {
      case 'lesson': return '레슨비';
      case 'package': return '패키지';
      case 'other': return '기타';
      default: return category;
    }
  }

  String get paymentMethodLabel {
    switch (paymentMethod) {
      case 'cash': return '현금';
      case 'card': return '카드';
      case 'transfer': return '계좌이체';
      case 'other': return '기타';
      default: return paymentMethod;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is IncomeEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
