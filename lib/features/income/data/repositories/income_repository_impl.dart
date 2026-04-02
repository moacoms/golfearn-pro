import '../../../../core/constants/database_constants.dart';
import '../../../../core/services/supabase_service.dart';
import '../../domain/entities/income_entity.dart';
import '../models/income_model.dart';

class IncomeRepositoryImpl {
  final SupabaseService _supabaseService;

  IncomeRepositoryImpl(this._supabaseService);

  Future<List<IncomeEntity>> getIncomeRecords(String proId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
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
      print('수입 기록 조회 실패: $e');
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
      throw Exception('수입 기록 등록 실패: $e');
    }
  }

  Future<List<IncomeEntity>> getStudentIncomeRecords(String studentId) async {
    try {
      final response = await _supabaseService.client
          .from(DatabaseConstants.proIncomeRecords)
          .select('*, lesson_students(student_name)')
          .eq('student_id', studentId)
          .order('payment_date', ascending: false);
      final list = List<Map<String, dynamic>>.from(response);
      return list.map((json) => IncomeModel.fromJson(json).toEntity()).toList();
    } catch (e) {
      print('학생 수입 기록 조회 실패: $e');
      return [];
    }
  }

  Future<void> deleteIncomeRecord(String recordId) async {
    try {
      await _supabaseService.client
          .from(DatabaseConstants.proIncomeRecords)
          .delete()
          .eq('id', recordId);
    } catch (e) {
      throw Exception('수입 기록 삭제 실패: $e');
    }
  }

  Future<int> getMonthlyIncome(String proId) async {
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
