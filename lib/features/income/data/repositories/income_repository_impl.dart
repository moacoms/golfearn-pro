import '../../../../core/constants/database_constants.dart';
import '../../../../core/services/supabase_service.dart';
import '../../domain/entities/income_entity.dart';
import '../models/income_model.dart';

class IncomeRepositoryImpl {
  final SupabaseService _supabaseService;

  IncomeRepositoryImpl(this._supabaseService);

  String get _currentUserId {
    final uid = _supabaseService.currentUser?.id;
    if (uid == null) throw Exception('인증이 필요합니다.');
    return uid;
  }

  void _verifyProAccess(String proId) {
    if (proId != _currentUserId) {
      throw Exception('접근 권한이 없습니다.');
    }
  }

  Future<List<IncomeEntity>> getIncomeRecords(String proId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _verifyProAccess(proId);
    try {
      var query = _supabaseService.client
          .from(DatabaseConstants.proIncomeRecords)
          .select('*, lesson_students(student_name)')
          .eq('pro_id', proId);

      if (startDate != null) {
        query = query.gte('payment_date', startDate.toIso8601String().split('T').first);
      }
      if (endDate != null) {
        query = query.lte('payment_date', endDate.toIso8601String().split('T').first);
      }

      final response = await query.order('payment_date', ascending: false);
      final list = List<Map<String, dynamic>>.from(response);
      return list.map((json) => IncomeModel.fromJson(json).toEntity()).toList();
    } catch (e) {
      return [];
    }
  }

  Future<IncomeEntity> createIncomeRecord({
    required String proId,
    String? studentId,
    String? packageId,
    String category = 'lesson',
    required int amount,
    required DateTime incomeDate,
    String? description,
    String paymentMethod = 'cash',
  }) async {
    _verifyProAccess(proId);
    try {
      final data = <String, dynamic>{
        'pro_id': proId,
        if (studentId != null) 'student_id': studentId,
        if (packageId != null) 'package_id': packageId,
        'income_type': category,
        'amount': amount,
        'payment_date': incomeDate.toIso8601String().split('T').first,
        'payment_method': paymentMethod,
      };
      if (description != null) data['memo'] = description;

      final response = await _supabaseService.client
          .from(DatabaseConstants.proIncomeRecords)
          .insert(data)
          .select('*, lesson_students(student_name)')
          .single();

      return IncomeModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('수입 기록 등록 실패');
    }
  }

  Future<List<IncomeEntity>> getStudentIncomeRecords(String studentId) async {
    try {
      final response = await _supabaseService.client
          .from(DatabaseConstants.proIncomeRecords)
          .select('*, lesson_students(student_name)')
          .eq('student_id', studentId)
          .eq('pro_id', _currentUserId)
          .order('payment_date', ascending: false);
      final list = List<Map<String, dynamic>>.from(response);
      return list.map((json) => IncomeModel.fromJson(json).toEntity()).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> deleteIncomeRecord(String recordId) async {
    try {
      await _supabaseService.client
          .from(DatabaseConstants.proIncomeRecords)
          .delete()
          .eq('id', recordId)
          .eq('pro_id', _currentUserId);
    } catch (e) {
      throw Exception('수입 기록 삭제 실패');
    }
  }

  Future<int> getMonthlyIncome(String proId) async {
    _verifyProAccess(proId);
    try {
      final now = DateTime.now();
      final monthStart = DateTime(now.year, now.month, 1);
      final monthEnd = DateTime(now.year, now.month + 1, 0);

      final records = await getIncomeRecords(
        proId,
        startDate: monthStart,
        endDate: monthEnd,
      );

      return records.fold<int>(0, (sum, record) => sum + record.amount);
    } catch (e) {
      return 0;
    }
  }
}
