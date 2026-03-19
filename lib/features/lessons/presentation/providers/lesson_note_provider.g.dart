// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson_note_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(lessonNoteRepository)
final lessonNoteRepositoryProvider = LessonNoteRepositoryProvider._();

final class LessonNoteRepositoryProvider
    extends
        $FunctionalProvider<
          LessonNoteRepositoryImpl,
          LessonNoteRepositoryImpl,
          LessonNoteRepositoryImpl
        >
    with $Provider<LessonNoteRepositoryImpl> {
  LessonNoteRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lessonNoteRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lessonNoteRepositoryHash();

  @$internal
  @override
  $ProviderElement<LessonNoteRepositoryImpl> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LessonNoteRepositoryImpl create(Ref ref) {
    return lessonNoteRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LessonNoteRepositoryImpl value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LessonNoteRepositoryImpl>(value),
    );
  }
}

String _$lessonNoteRepositoryHash() =>
    r'e18141e7248018262f0322c90dbb9096b8265ec3';

/// 전체 레슨 노트 목록

@ProviderFor(lessonNotes)
final lessonNotesProvider = LessonNotesProvider._();

/// 전체 레슨 노트 목록

final class LessonNotesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<LessonNoteEntity>>,
          List<LessonNoteEntity>,
          FutureOr<List<LessonNoteEntity>>
        >
    with
        $FutureModifier<List<LessonNoteEntity>>,
        $FutureProvider<List<LessonNoteEntity>> {
  /// 전체 레슨 노트 목록
  LessonNotesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lessonNotesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lessonNotesHash();

  @$internal
  @override
  $FutureProviderElement<List<LessonNoteEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<LessonNoteEntity>> create(Ref ref) {
    return lessonNotes(ref);
  }
}

String _$lessonNotesHash() => r'db85d19de836f7d510f560510dd65f67771d30fe';

/// 특정 학생의 레슨 노트

@ProviderFor(studentNotes)
final studentNotesProvider = StudentNotesFamily._();

/// 특정 학생의 레슨 노트

final class StudentNotesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<LessonNoteEntity>>,
          List<LessonNoteEntity>,
          FutureOr<List<LessonNoteEntity>>
        >
    with
        $FutureModifier<List<LessonNoteEntity>>,
        $FutureProvider<List<LessonNoteEntity>> {
  /// 특정 학생의 레슨 노트
  StudentNotesProvider._({
    required StudentNotesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'studentNotesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$studentNotesHash();

  @override
  String toString() {
    return r'studentNotesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<LessonNoteEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<LessonNoteEntity>> create(Ref ref) {
    final argument = this.argument as String;
    return studentNotes(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is StudentNotesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$studentNotesHash() => r'9146d7c35a37454252f2a97aef2792edf677ef39';

/// 특정 학생의 레슨 노트

final class StudentNotesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<LessonNoteEntity>>, String> {
  StudentNotesFamily._()
    : super(
        retry: null,
        name: r'studentNotesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 특정 학생의 레슨 노트

  StudentNotesProvider call(String studentId) =>
      StudentNotesProvider._(argument: studentId, from: this);

  @override
  String toString() => r'studentNotesProvider';
}
