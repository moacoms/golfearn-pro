/// 데이터베이스 테이블 및 컬럼 상수
/// 기존 Golfearn 프로젝트의 Supabase 스키마와 동일
class DatabaseConstants {
  // 테이블 이름
  static const String profiles = 'profiles';
  static const String lessonStudents = 'lesson_students';
  static const String lessonPackages = 'lesson_packages';
  static const String lessonSchedules = 'lesson_schedules';
  static const String lessonNotes = 'lesson_notes';
  static const String proIncomeRecords = 'pro_income_records';
  static const String proNotificationSettings = 'pro_notification_settings';
  
  // profiles 테이블 컬럼
  static const String profileId = 'id';
  static const String profileFullName = 'full_name';
  static const String profileAvatarUrl = 'avatar_url';
  static const String profileIsAdmin = 'is_admin';
  static const String profileIsLessonPro = 'is_lesson_pro';
  static const String profileIsStudent = 'is_student';
  static const String profileProCertification = 'pro_certification';
  static const String profileProExperienceYears = 'pro_experience_years';
  static const String profileProSpecialties = 'pro_specialties';
  static const String profileProIntroduction = 'pro_introduction';
  static const String profileProMonthlyFee = 'pro_monthly_fee';
  static const String profileProLocation = 'pro_location';
  static const String profileProPhone = 'pro_phone';
  
  // lesson_students 테이블 컬럼
  static const String studentId = 'id';
  static const String studentProId = 'pro_id';
  static const String studentUserId = 'user_id';
  static const String studentName = 'student_name';
  static const String studentPhone = 'student_phone';
  static const String studentEmail = 'student_email';
  static const String studentMemo = 'student_memo';
  static const String studentCurrentLevel = 'current_level';
  static const String studentGoal = 'goal';
  static const String studentBirthDate = 'birth_date';
  static const String studentGender = 'gender';
  static const String studentStartedGolfAt = 'started_golf_at';
  static const String studentAverageScore = 'average_score';
  static const String studentTotalLessonCount = 'total_lesson_count';
  static const String studentLastLessonAt = 'last_lesson_at';
  static const String studentIsActive = 'is_active';
  
  // lesson_packages 테이블 컬럼
  static const String packageId = 'id';
  static const String packageProId = 'pro_id';
  static const String packageStudentId = 'student_id';
  static const String packageName = 'package_name';
  static const String packageType = 'package_type';
  static const String packageTotalCount = 'total_count';
  static const String packageUsedCount = 'used_count';
  static const String packageRemainingCount = 'remaining_count';
  static const String packagePrice = 'price';
  static const String packageStartDate = 'start_date';
  static const String packageEndDate = 'end_date';
  static const String packageStatus = 'status';
  static const String packagePaymentStatus = 'payment_status';
  static const String packagePaidAmount = 'paid_amount';
  static const String packagePaymentMethod = 'payment_method';
  
  // lesson_schedules 테이블 컬럼
  static const String scheduleId = 'id';
  static const String scheduleProId = 'pro_id';
  static const String scheduleStudentId = 'student_id';
  static const String schedulePackageId = 'package_id';
  static const String scheduleLessonDate = 'lesson_date';
  static const String scheduleLessonTime = 'lesson_time';
  static const String scheduleDurationMinutes = 'duration_minutes';
  static const String scheduleStatus = 'status';
  static const String scheduleLocation = 'location';
  static const String scheduleLessonType = 'lesson_type';
  static const String scheduleMemo = 'memo';
  
  // 학생 레벨 옵션
  static const List<String> studentLevels = ['입문', '초급', '중급', '상급'];
  
  // 패키지 타입
  static const String packageTypeCount = 'count'; // 횟수제
  static const String packageTypePeriod = 'period'; // 기간제
  
  // 패키지 상태
  static const String packageStatusActive = 'active';
  static const String packageStatusExpired = 'expired';
  static const String packageStatusCompleted = 'completed';
  static const String packageStatusCancelled = 'cancelled';
  
  // 결제 상태
  static const String paymentStatusPending = 'pending';
  static const String paymentStatusPartial = 'partial';
  static const String paymentStatusPaid = 'paid';
  
  // 스케줄 상태
  static const String scheduleStatusScheduled = 'scheduled';
  static const String scheduleStatusCompleted = 'completed';
  static const String scheduleStatusCancelled = 'cancelled';
  static const String scheduleStatusNoShow = 'no_show';
  
  // 레슨 타입
  static const String lessonTypeRegular = 'regular';
  static const String lessonTypePlaying = 'playing';
  static const String lessonTypeShortGame = 'short_game';
  static const String lessonTypePutting = 'putting';
}