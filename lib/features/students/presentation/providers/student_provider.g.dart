// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// StudentRepository 프로바이더

@ProviderFor(studentRepository)
final studentRepositoryProvider = StudentRepositoryProvider._();

/// StudentRepository 프로바이더

final class StudentRepositoryProvider
    extends
        $FunctionalProvider<
          StudentRepositoryImpl,
          StudentRepositoryImpl,
          StudentRepositoryImpl
        >
    with $Provider<StudentRepositoryImpl> {
  /// StudentRepository 프로바이더
  StudentRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'studentRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$studentRepositoryHash();

  @$internal
  @override
  $ProviderElement<StudentRepositoryImpl> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  StudentRepositoryImpl create(Ref ref) {
    return studentRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StudentRepositoryImpl value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StudentRepositoryImpl>(value),
    );
  }
}

String _$studentRepositoryHash() => r'2b0ec353ad4cb47c8ed7cae91a60d0e90e33b27c';

/// 학생 목록 프로바이더

@ProviderFor(students)
final studentsProvider = StudentsProvider._();

/// 학생 목록 프로바이더

final class StudentsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<StudentEntity>>,
          List<StudentEntity>,
          FutureOr<List<StudentEntity>>
        >
    with
        $FutureModifier<List<StudentEntity>>,
        $FutureProvider<List<StudentEntity>> {
  /// 학생 목록 프로바이더
  StudentsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'studentsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$studentsHash();

  @$internal
  @override
  $FutureProviderElement<List<StudentEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<StudentEntity>> create(Ref ref) {
    return students(ref);
  }
}

String _$studentsHash() => r'180129a6612e31dc6fda2cfd78ef3e80d3e6a624';

/// 학생 상세 프로바이더

@ProviderFor(studentDetail)
final studentDetailProvider = StudentDetailFamily._();

/// 학생 상세 프로바이더

final class StudentDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<StudentEntity>,
          StudentEntity,
          FutureOr<StudentEntity>
        >
    with $FutureModifier<StudentEntity>, $FutureProvider<StudentEntity> {
  /// 학생 상세 프로바이더
  StudentDetailProvider._({
    required StudentDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'studentDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$studentDetailHash();

  @override
  String toString() {
    return r'studentDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<StudentEntity> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<StudentEntity> create(Ref ref) {
    final argument = this.argument as String;
    return studentDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is StudentDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$studentDetailHash() => r'28c06d58d1aa07cfa8cb6ba3283fb90a30f4cf6c';

/// 학생 상세 프로바이더

final class StudentDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<StudentEntity>, String> {
  StudentDetailFamily._()
    : super(
        retry: null,
        name: r'studentDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 학생 상세 프로바이더

  StudentDetailProvider call(String studentId) =>
      StudentDetailProvider._(argument: studentId, from: this);

  @override
  String toString() => r'studentDetailProvider';
}

/// 학생 수 프로바이더

@ProviderFor(studentCount)
final studentCountProvider = StudentCountProvider._();

/// 학생 수 프로바이더

final class StudentCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// 학생 수 프로바이더
  StudentCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'studentCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$studentCountHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return studentCount(ref);
  }
}

String _$studentCountHash() => r'bddad23a66c4954947987340051e39d04655b92c';

/// 학생 검색 필터

@ProviderFor(StudentSearchQuery)
final studentSearchQueryProvider = StudentSearchQueryProvider._();

/// 학생 검색 필터
final class StudentSearchQueryProvider
    extends $NotifierProvider<StudentSearchQuery, String> {
  /// 학생 검색 필터
  StudentSearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'studentSearchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$studentSearchQueryHash();

  @$internal
  @override
  StudentSearchQuery create() => StudentSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$studentSearchQueryHash() =>
    r'f8960760abbb7a77b679c59109b5efb0a4587f66';

/// 학생 검색 필터

abstract class _$StudentSearchQuery extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// 필터된 학생 목록

@ProviderFor(filteredStudents)
final filteredStudentsProvider = FilteredStudentsProvider._();

/// 필터된 학생 목록

final class FilteredStudentsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<StudentEntity>>,
          AsyncValue<List<StudentEntity>>,
          AsyncValue<List<StudentEntity>>
        >
    with $Provider<AsyncValue<List<StudentEntity>>> {
  /// 필터된 학생 목록
  FilteredStudentsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredStudentsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredStudentsHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<List<StudentEntity>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<List<StudentEntity>> create(Ref ref) {
    return filteredStudents(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<StudentEntity>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<StudentEntity>>>(
        value,
      ),
    );
  }
}

String _$filteredStudentsHash() => r'914f3207c9492d1d76fb5814b1784eeb58ed43f1';
