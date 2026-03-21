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
          .select()
          .eq('pro_id', proId);

      if (startDate != null) {
        query = query.gte('income_date', startDate.toIso8601String().split('T').first);
      }
      if (endDate != null) {
        query = query.lte('income_date', endDate.toIso8601String().split('T').first);
      }

      final response = await query.order('income_date', ascending: false);
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
    String? scheduleId,
    String category = 'lesson',
    required int amount,
    required DateTime incomeDate,
    String? description,
    String paymentMethod = 'cash',
  }) async {
    try {
      final data = {
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

      data.removeWhere((key, value) => value == null);

      final response = await _supabaseService.client
          .from(DatabaseConstants.proIncomeRecords)
          .insert(data)
          .select()
          .single();

      return IncomeModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('수입 기록 등록 실패: $e');
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
