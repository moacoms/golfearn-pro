// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// AuthRepository 프로바이더

@ProviderFor(authRepository)
final authRepositoryProvider = AuthRepositoryProvider._();

/// AuthRepository 프로바이더

final class AuthRepositoryProvider
    extends $FunctionalProvider<AuthRepository, AuthRepository, AuthRepository>
    with $Provider<AuthRepository> {
  /// AuthRepository 프로바이더
  AuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<AuthRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRepository>(value),
    );
  }
}

String _$authRepositoryHash() => r'86ed52de15cf9dd8acfa2c2417183a7559358afc';

/// 현재 사용자 프로바이더

@ProviderFor(currentUser)
final currentUserProvider = CurrentUserProvider._();

/// 현재 사용자 프로바이더

final class CurrentUserProvider
    extends $FunctionalProvider<UserEntity?, UserEntity?, UserEntity?>
    with $Provider<UserEntity?> {
  /// 현재 사용자 프로바이더
  CurrentUserProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentUserProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentUserHash();

  @$internal
  @override
  $ProviderElement<UserEntity?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UserEntity? create(Ref ref) {
    return currentUser(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserEntity? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserEntity?>(value),
    );
  }
}

String _$currentUserHash() => r'6ab3e45970be7540e12fccb349af2f860f6ea63c';

/// 인증 상태 스트림 프로바이더

@ProviderFor(authStateChanges)
final authStateChangesProvider = AuthStateChangesProvider._();

/// 인증 상태 스트림 프로바이더

final class AuthStateChangesProvider
    extends
        $FunctionalProvider<
          AsyncValue<UserEntity?>,
          UserEntity?,
          Stream<UserEntity?>
        >
    with $FutureModifier<UserEntity?>, $StreamProvider<UserEntity?> {
  /// 인증 상태 스트림 프로바이더
  AuthStateChangesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authStateChangesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authStateChangesHash();

  @$internal
  @override
  $StreamProviderElement<UserEntity?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<UserEntity?> create(Ref ref) {
    return authStateChanges(ref);
  }
}

String _$authStateChangesHash() => r'7621294cd37ffe2cc1e38ebbd4bb5451dd609c9c';

/// 로그인 상태 프로바이더 (boolean)

@ProviderFor(isAuthenticated)
final isAuthenticatedProvider = IsAuthenticatedProvider._();

/// 로그인 상태 프로바이더 (boolean)

final class IsAuthenticatedProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// 로그인 상태 프로바이더 (boolean)
  IsAuthenticatedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isAuthenticatedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isAuthenticatedHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isAuthenticated(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isAuthenticatedHash() => r'54fa2e7165f29e09a4d03d1f0bf7ae0df72cf5dc';

/// 레슨프로 여부 프로바이더

@ProviderFor(isLessonPro)
final isLessonProProvider = IsLessonProProvider._();

/// 레슨프로 여부 프로바이더

final class IsLessonProProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// 레슨프로 여부 프로바이더
  IsLessonProProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isLessonProProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isLessonProHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isLessonPro(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isLessonProHash() => r'7fa018fa5d58a1c60d29c7d9b47bdb5545d98856';

/// 학생 여부 프로바이더

@ProviderFor(isStudent)
final isStudentProvider = IsStudentProvider._();

/// 학생 여부 프로바이더

final class IsStudentProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// 학생 여부 프로바이더
  IsStudentProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isStudentProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isStudentHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isStudent(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isStudentHash() => r'3d45e2f2e4ab70c8d6f8e950c99c66c77f350597';

/// 관리자 여부 프로바이더

@ProviderFor(isAdmin)
final isAdminProvider = IsAdminProvider._();

/// 관리자 여부 프로바이더

final class IsAdminProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// 관리자 여부 프로바이더
  IsAdminProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isAdminProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isAdminHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isAdmin(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isAdminHash() => r'19ca3c6dcb8fc8d521c9311d750e9b50ce3cb6a5';

/// 현재 사용자의 종목 타입 프로바이더

@ProviderFor(currentSportType)
final currentSportTypeProvider = CurrentSportTypeProvider._();

/// 현재 사용자의 종목 타입 프로바이더

final class CurrentSportTypeProvider
    extends $FunctionalProvider<SportType, SportType, SportType>
    with $Provider<SportType> {
  /// 현재 사용자의 종목 타입 프로바이더
  CurrentSportTypeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentSportTypeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentSportTypeHash();

  @$internal
  @override
  $ProviderElement<SportType> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SportType create(Ref ref) {
    return currentSportType(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SportType value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SportType>(value),
    );
  }
}

String _$currentSportTypeHash() => r'a05cede723d5bc1b96f9dc0bdae35f43f18d8e3f';
