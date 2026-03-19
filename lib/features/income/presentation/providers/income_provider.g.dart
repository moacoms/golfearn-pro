// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'income_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(incomeRepository)
final incomeRepositoryProvider = IncomeRepositoryProvider._();

final class IncomeRepositoryProvider
    extends
        $FunctionalProvider<
          IncomeRepositoryImpl,
          IncomeRepositoryImpl,
          IncomeRepositoryImpl
        >
    with $Provider<IncomeRepositoryImpl> {
  IncomeRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'incomeRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$incomeRepositoryHash();

  @$internal
  @override
  $ProviderElement<IncomeRepositoryImpl> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  IncomeRepositoryImpl create(Ref ref) {
    return incomeRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IncomeRepositoryImpl value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IncomeRepositoryImpl>(value),
    );
  }
}

String _$incomeRepositoryHash() => r'2b39c8ed709300a48a23d856a8c42b712e7ee115';

/// 선택된 월

@ProviderFor(SelectedMonth)
final selectedMonthProvider = SelectedMonthProvider._();

/// 선택된 월
final class SelectedMonthProvider
    extends $NotifierProvider<SelectedMonth, DateTime> {
  /// 선택된 월
  SelectedMonthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedMonthProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedMonthHash();

  @$internal
  @override
  SelectedMonth create() => SelectedMonth();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime>(value),
    );
  }
}

String _$selectedMonthHash() => r'5628b740223391c568384165eecf2e0c5ada2829';

/// 선택된 월

abstract class _$SelectedMonth extends $Notifier<DateTime> {
  DateTime build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<DateTime, DateTime>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DateTime, DateTime>,
              DateTime,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// 선택된 월의 수입 기록

@ProviderFor(monthlyIncomeRecords)
final monthlyIncomeRecordsProvider = MonthlyIncomeRecordsProvider._();

/// 선택된 월의 수입 기록

final class MonthlyIncomeRecordsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<IncomeEntity>>,
          List<IncomeEntity>,
          FutureOr<List<IncomeEntity>>
        >
    with
        $FutureModifier<List<IncomeEntity>>,
        $FutureProvider<List<IncomeEntity>> {
  /// 선택된 월의 수입 기록
  MonthlyIncomeRecordsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'monthlyIncomeRecordsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$monthlyIncomeRecordsHash();

  @$internal
  @override
  $FutureProviderElement<List<IncomeEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<IncomeEntity>> create(Ref ref) {
    return monthlyIncomeRecords(ref);
  }
}

String _$monthlyIncomeRecordsHash() =>
    r'137bd40799c3fb13b55c76807dfcbc69031b1e19';

/// 이번 달 총 수입

@ProviderFor(monthlyTotalIncome)
final monthlyTotalIncomeProvider = MonthlyTotalIncomeProvider._();

/// 이번 달 총 수입

final class MonthlyTotalIncomeProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// 이번 달 총 수입
  MonthlyTotalIncomeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'monthlyTotalIncomeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$monthlyTotalIncomeHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return monthlyTotalIncome(ref);
  }
}

String _$monthlyTotalIncomeHash() =>
    r'55aa1d32f429501a751964d16af55628c3568014';
