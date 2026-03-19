// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'package_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(packageRepository)
final packageRepositoryProvider = PackageRepositoryProvider._();

final class PackageRepositoryProvider
    extends
        $FunctionalProvider<
          PackageRepositoryImpl,
          PackageRepositoryImpl,
          PackageRepositoryImpl
        >
    with $Provider<PackageRepositoryImpl> {
  PackageRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'packageRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$packageRepositoryHash();

  @$internal
  @override
  $ProviderElement<PackageRepositoryImpl> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PackageRepositoryImpl create(Ref ref) {
    return packageRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PackageRepositoryImpl value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PackageRepositoryImpl>(value),
    );
  }
}

String _$packageRepositoryHash() => r'0fcc6b222560ddbf98cd3a12bdc79306b91ac21e';

/// 전체 패키지 목록

@ProviderFor(packages)
final packagesProvider = PackagesProvider._();

/// 전체 패키지 목록

final class PackagesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PackageEntity>>,
          List<PackageEntity>,
          FutureOr<List<PackageEntity>>
        >
    with
        $FutureModifier<List<PackageEntity>>,
        $FutureProvider<List<PackageEntity>> {
  /// 전체 패키지 목록
  PackagesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'packagesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$packagesHash();

  @$internal
  @override
  $FutureProviderElement<List<PackageEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PackageEntity>> create(Ref ref) {
    return packages(ref);
  }
}

String _$packagesHash() => r'3c04318dfa4ee8c86dfb8ed858d7b7eb3dd4d6bd';

/// 특정 학생의 활성 패키지

@ProviderFor(studentActivePackages)
final studentActivePackagesProvider = StudentActivePackagesFamily._();

/// 특정 학생의 활성 패키지

final class StudentActivePackagesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PackageEntity>>,
          List<PackageEntity>,
          FutureOr<List<PackageEntity>>
        >
    with
        $FutureModifier<List<PackageEntity>>,
        $FutureProvider<List<PackageEntity>> {
  /// 특정 학생의 활성 패키지
  StudentActivePackagesProvider._({
    required StudentActivePackagesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'studentActivePackagesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$studentActivePackagesHash();

  @override
  String toString() {
    return r'studentActivePackagesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<PackageEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PackageEntity>> create(Ref ref) {
    final argument = this.argument as String;
    return studentActivePackages(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is StudentActivePackagesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$studentActivePackagesHash() =>
    r'38ec258446377a35751acbdb6e3a4d87ae708f75';

/// 특정 학생의 활성 패키지

final class StudentActivePackagesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<PackageEntity>>, String> {
  StudentActivePackagesFamily._()
    : super(
        retry: null,
        name: r'studentActivePackagesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 특정 학생의 활성 패키지

  StudentActivePackagesProvider call(String studentId) =>
      StudentActivePackagesProvider._(argument: studentId, from: this);

  @override
  String toString() => r'studentActivePackagesProvider';
}
