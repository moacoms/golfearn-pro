// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(scheduleRepository)
final scheduleRepositoryProvider = ScheduleRepositoryProvider._();

final class ScheduleRepositoryProvider
    extends
        $FunctionalProvider<
          ScheduleRepositoryImpl,
          ScheduleRepositoryImpl,
          ScheduleRepositoryImpl
        >
    with $Provider<ScheduleRepositoryImpl> {
  ScheduleRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'scheduleRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$scheduleRepositoryHash();

  @$internal
  @override
  $ProviderElement<ScheduleRepositoryImpl> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ScheduleRepositoryImpl create(Ref ref) {
    return scheduleRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ScheduleRepositoryImpl value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ScheduleRepositoryImpl>(value),
    );
  }
}

String _$scheduleRepositoryHash() =>
    r'00390812fc1b1d21c22532d3bb927f8f815b7978';

/// 선택된 날짜

@ProviderFor(SelectedDate)
final selectedDateProvider = SelectedDateProvider._();

/// 선택된 날짜
final class SelectedDateProvider
    extends $NotifierProvider<SelectedDate, DateTime> {
  /// 선택된 날짜
  SelectedDateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedDateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedDateHash();

  @$internal
  @override
  SelectedDate create() => SelectedDate();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime>(value),
    );
  }
}

String _$selectedDateHash() => r'587eebf9e6a68e26118fe99ebcf13d6a94f2ff77';

/// 선택된 날짜

abstract class _$SelectedDate extends $Notifier<DateTime> {
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

/// 선택된 주의 시작일 (월요일)

@ProviderFor(selectedWeekStart)
final selectedWeekStartProvider = SelectedWeekStartProvider._();

/// 선택된 주의 시작일 (월요일)

final class SelectedWeekStartProvider
    extends $FunctionalProvider<DateTime, DateTime, DateTime>
    with $Provider<DateTime> {
  /// 선택된 주의 시작일 (월요일)
  SelectedWeekStartProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedWeekStartProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedWeekStartHash();

  @$internal
  @override
  $ProviderElement<DateTime> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DateTime create(Ref ref) {
    return selectedWeekStart(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime>(value),
    );
  }
}

String _$selectedWeekStartHash() => r'4e10886da1d9db3152ae17939c011cf006b270ad';

/// 주간 스케줄

@ProviderFor(weeklySchedules)
final weeklySchedulesProvider = WeeklySchedulesProvider._();

/// 주간 스케줄

final class WeeklySchedulesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ScheduleEntity>>,
          List<ScheduleEntity>,
          FutureOr<List<ScheduleEntity>>
        >
    with
        $FutureModifier<List<ScheduleEntity>>,
        $FutureProvider<List<ScheduleEntity>> {
  /// 주간 스케줄
  WeeklySchedulesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'weeklySchedulesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$weeklySchedulesHash();

  @$internal
  @override
  $FutureProviderElement<List<ScheduleEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ScheduleEntity>> create(Ref ref) {
    return weeklySchedules(ref);
  }
}

String _$weeklySchedulesHash() => r'78c80f0171d13e117942b26205c09b231bca0bd3';

/// 선택된 날짜의 스케줄

@ProviderFor(dailySchedules)
final dailySchedulesProvider = DailySchedulesProvider._();

/// 선택된 날짜의 스케줄

final class DailySchedulesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ScheduleEntity>>,
          AsyncValue<List<ScheduleEntity>>,
          AsyncValue<List<ScheduleEntity>>
        >
    with $Provider<AsyncValue<List<ScheduleEntity>>> {
  /// 선택된 날짜의 스케줄
  DailySchedulesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dailySchedulesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dailySchedulesHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<List<ScheduleEntity>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<List<ScheduleEntity>> create(Ref ref) {
    return dailySchedules(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<ScheduleEntity>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<ScheduleEntity>>>(
        value,
      ),
    );
  }
}

String _$dailySchedulesHash() => r'e6c89c204666effa8817cbe7739b26ddf8f9e06d';

/// 오늘의 스케줄

@ProviderFor(todaySchedules)
final todaySchedulesProvider = TodaySchedulesProvider._();

/// 오늘의 스케줄

final class TodaySchedulesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ScheduleEntity>>,
          List<ScheduleEntity>,
          FutureOr<List<ScheduleEntity>>
        >
    with
        $FutureModifier<List<ScheduleEntity>>,
        $FutureProvider<List<ScheduleEntity>> {
  /// 오늘의 스케줄
  TodaySchedulesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todaySchedulesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todaySchedulesHash();

  @$internal
  @override
  $FutureProviderElement<List<ScheduleEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ScheduleEntity>> create(Ref ref) {
    return todaySchedules(ref);
  }
}

String _$todaySchedulesHash() => r'1dac2b375130e34e057971cdfb537f27f33f1344';

/// 이번 주 레슨 횟수

@ProviderFor(weeklyLessonCount)
final weeklyLessonCountProvider = WeeklyLessonCountProvider._();

/// 이번 주 레슨 횟수

final class WeeklyLessonCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// 이번 주 레슨 횟수
  WeeklyLessonCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'weeklyLessonCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$weeklyLessonCountHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return weeklyLessonCount(ref);
  }
}

String _$weeklyLessonCountHash() => r'9cb626c99f2f657f8f27f355a80a727cf7450a6b';
