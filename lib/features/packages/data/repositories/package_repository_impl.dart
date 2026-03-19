import '../../../../core/constants/database_constants.dart';
import '../../../../core/services/supabase_service.dart';
import '../../domain/entities/package_entity.dart';
import '../models/package_model.dart';

class PackageRepositoryImpl {
  final SupabaseService _supabaseService;

  PackageRepositoryImpl(this._supabaseService);

  /// 전체 패키지 목록 조회
  Future<List<PackageEntity>> getPackages(String proId) async {
    try {
      final response = await _supabaseService.client
          .from(DatabaseConstants.lessonPackages)
          .select('*, lesson_students(student_name)')
          .eq(DatabaseConstants.packageProId, proId)
          .order('created_at', ascending: false);

      final list = List<Map<String, dynamic>>.from(response);
      return list.map((json) => PackageModel.fromJson(json).toEntity()).toList();
    } catch (e) {
      print('패키지 조회 실패: $e');
      return [];
    }
  }

  /// 특정 학생의 활성 패키지 조회
  Future<List<PackageEntity>> getActivePackages(String proId, String studentId) async {
    try {
      final response = await _supabaseService.client
          .from(DatabaseConstants.lessonPackages)
          .select('*, lesson_students(student_name)')
          .eq(DatabaseConstants.packageProId, proId)
          .eq(DatabaseConstants.packageStudentId, studentId)
          .eq(DatabaseConstants.packageStatus, 'active')
          .order('created_at', ascending: false);

      final list = List<Map<String, dynamic>>.from(response);
      return list.map((json) => PackageModel.fromJson(json).toEntity()).toList();
    } catch (e) {
      print('학생 패키지 조회 실패: $e');
      return [];
    }
  }

  /// 패키지 생성
  Future<PackageEntity> createPackage({
    required String proId,
    required String studentId,
    required String packageName,
    String packageType = 'count',
    required int totalCount,
    required int price,
    DateTime? startDate,
    DateTime? endDate,
    String paymentStatus = 'pending',
    int? paidAmount,
    String? paymentMethod,
  }) async {
    try {
      final data = {
        'pro_id': proId,
        'student_id': studentId,
        'package_name': packageName,
        'package_type': packageType,
        'total_count': totalCount,
        'used_count': 0,
        'remaining_count': totalCount,
        'price': price,
        'start_date': (startDate ?? DateTime.now()).toIso8601String().split('T').first,
        'status': 'active',
        'payment_status': paymentStatus,
      };

      if (endDate != null) data['end_date'] = endDate.toIso8601String().split('T').first;
      if (paidAmount != null) data['paid_amount'] = paidAmount;
      if (paymentMethod != null) data['payment_method'] = paymentMethod;

      final response = await _supabaseService.client
          .from(DatabaseConstants.lessonPackages)
          .insert(data)
          .select('*, lesson_students(student_name)')
          .single();

      return PackageModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('패키지 생성 실패: $e');
    }
  }

  /// 레슨 1회 차감 (레슨 완료 시 호출)
  Future<PackageEntity?> deductLesson(String packageId) async {
    try {
      // 현재 패키지 정보 조회
      final current = await _supabaseService.client
          .from(DatabaseConstants.lessonPackages)
          .select()
          .eq(DatabaseConstants.packageId, packageId)
          .single();

      final usedCount = (current['used_count'] as int? ?? 0) + 1;
      final remainingCount = (current['remaining_count'] as int? ?? 1) - 1;

      final updateData = {
        'used_count': usedCount,
        'remaining_count': remainingCount < 0 ? 0 : remainingCount,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // 남은 횟수가 0이면 completed로 변경
      if (remainingCount <= 0) {
        updateData['status'] = 'completed';
      }

      final response = await _supabaseService.client
          .from(DatabaseConstants.lessonPackages)
          .update(updateData)
          .eq(DatabaseConstants.packageId, packageId)
          .select('*, lesson_students(student_name)')
          .single();

      return PackageModel.fromJson(response).toEntity();
    } catch (e) {
      print('레슨 차감 실패: $e');
      return null;
    }
  }

  /// 패키지 삭제 (취소)
  Future<void> cancelPackage(String packageId) async {
    try {
      await _supabaseService.client
          .from(DatabaseConstants.lessonPackages)
          .update({
            'status': 'cancelled',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq(DatabaseConstants.packageId, packageId);
    } catch (e) {
      throw Exception('패키지 취소 실패: $e');
    }
  }
}
