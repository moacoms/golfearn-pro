import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/income_repository_impl.dart';
import '../../domain/entities/income_entity.dart';

part 'income_provider.g.dart';

@riverpod
IncomeRepositoryImpl incomeRepository(Ref ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return IncomeRepositoryImpl(supabaseService);
}

/// 선택된 월
@riverpod
class SelectedMonth extends _$SelectedMonth {
  @override
  DateTime build() => DateTime.now();

  void update(DateTime month) => state = month;
}

/// 선택된 월의 수입 기록
@riverpod
Future<List<IncomeEntity>> monthlyIncomeRecords(Ref ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final repo = ref.watch(incomeRepositoryProvider);
  final month = ref.watch(selectedMonthProvider);
  final start = DateTime(month.year, month.month, 1);
  final end = DateTime(month.year, month.month + 1, 0);
  return repo.getIncomeRecords(user.id, startDate: start, endDate: end);
}

/// 학생별 결제 내역
@riverpod
Future<List<IncomeEntity>> studentIncomeRecords(Ref ref, String studentId) async {
  final repo = ref.watch(incomeRepositoryProvider);
  return repo.getStudentIncomeRecords(studentId);
}

/// 이번 달 총 수입
@riverpod
Future<int> monthlyTotalIncome(Ref ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return 0;
  final repo = ref.watch(incomeRepositoryProvider);
  return repo.getMonthlyIncome(user.id);
}
