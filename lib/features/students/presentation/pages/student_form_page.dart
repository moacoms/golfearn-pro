import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/database_constants.dart';
import '../../../../core/constants/sport_constants.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/student_entity.dart';
import '../providers/student_provider.dart';
import '../../../../core/theme/app_theme.dart';

class StudentFormPage extends ConsumerStatefulWidget {
  final StudentEntity? student; // null이면 신규 등록

  const StudentFormPage({super.key, this.student});

  @override
  ConsumerState<StudentFormPage> createState() => _StudentFormPageState();
}

class _StudentFormPageState extends ConsumerState<StudentFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _memoController;
  late final TextEditingController _goalController;
  late final TextEditingController _scoreController;
  late final TextEditingController _lessonCountController;
  late final TextEditingController _groupNameController;

  String? _selectedLevel;
  String? _selectedGender;
  DateTime? _birthDate;
  DateTime? _startedGolfAt;
  String? _selectedFamilyStudentId;
  bool _isLoading = false;

  bool get isEditing => widget.student != null;

  @override
  void initState() {
    super.initState();
    final s = widget.student;
    _nameController = TextEditingController(text: s?.studentName ?? '');
    _phoneController = TextEditingController(text: s?.studentPhone ?? '');
    _emailController = TextEditingController(text: s?.studentEmail ?? '');
    _memoController = TextEditingController(text: s?.studentMemo ?? '');
    _goalController = TextEditingController(text: s?.goal ?? '');
    _scoreController = TextEditingController(
      text: s?.averageScore != null ? s!.averageScore.toString() : '',
    );
    _lessonCountController = TextEditingController(
      text: s?.totalLessonCount != null && s!.totalLessonCount > 0
          ? s.totalLessonCount.toString()
          : '',
    );
    _groupNameController = TextEditingController(text: s?.groupName ?? '');
    _selectedLevel = s?.currentLevel;
    _selectedGender = s?.gender;
    _birthDate = s?.birthDate;
    _startedGolfAt = s?.startedGolfAt;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _memoController.dispose();
    _goalController.dispose();
    _scoreController.dispose();
    _lessonCountController.dispose();
    _groupNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sportType = ref.watch(currentSportTypeProvider);
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          isEditing ? '학생 정보 수정' : '학생 등록',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 기본 정보 섹션
              _buildSectionTitle('기본 정보'),
              SizedBox(height: 12.h),
              _buildTextField(
                controller: _nameController,
                label: '이름 *',
                hint: '학생 이름을 입력하세요',
                maxLength: 50,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '이름을 입력해주세요';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12.h),
              _buildTextField(
                controller: _phoneController,
                label: '전화번호',
                hint: '010-0000-0000',
                maxLength: 13,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final cleaned = value.replaceAll('-', '');
                    if (!RegExp(r'^01[0-9]\d{7,8}$').hasMatch(cleaned)) {
                      return '올바른 전화번호를 입력해주세요';
                    }
                  }
                  return null;
                },
              ),
              SizedBox(height: 12.h),
              _buildTextField(
                controller: _emailController,
                label: '이메일',
                hint: 'email@example.com',
                maxLength: 100,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (!RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$').hasMatch(value)) {
                      return '올바른 이메일 형식을 입력해주세요';
                    }
                  }
                  return null;
                },
              ),

              SizedBox(height: 12.h),
              _buildTextField(
                controller: _groupNameController,
                label: '그룹',
                hint: '예: A반, 오전반, VIP',
                maxLength: 30,
              ),
              SizedBox(height: 12.h),
              // 가족 연결
              _buildFamilySelector(),

              SizedBox(height: 24.h),

              // 종목 정보 섹션 (동적)
              _buildSectionTitle(SportConstants.studentInfoSectionTitle(sportType)),
              SizedBox(height: 12.h),
              _buildDropdown(
                label: '레벨',
                value: _selectedLevel,
                items: DatabaseConstants.studentLevels,
                onChanged: (value) => setState(() => _selectedLevel = value),
              ),
              SizedBox(height: 12.h),
              _buildTextField(
                controller: _goalController,
                label: '목표',
                hint: SportConstants.goalHint(sportType),
                maxLength: 200,
              ),
              if (SportConstants.scoreLabel(sportType) != null) ...[
                SizedBox(height: 12.h),
                _buildTextField(
                  controller: _scoreController,
                  label: SportConstants.scoreLabel(sportType)!,
                  hint: '숫자로 입력',
                  keyboardType: TextInputType.number,
                ),
              ],
              SizedBox(height: 12.h),
              _buildDatePicker(
                label: SportConstants.startDateLabel(sportType),
                value: _startedGolfAt,
                onChanged: (date) => setState(() => _startedGolfAt = date),
              ),

              SizedBox(height: 24.h),

              // 개인 정보 섹션
              _buildSectionTitle('개인 정보'),
              SizedBox(height: 12.h),
              _buildDropdown(
                label: '성별',
                value: _selectedGender,
                items: const ['남성', '여성'],
                onChanged: (value) => setState(() => _selectedGender = value),
              ),
              SizedBox(height: 12.h),
              _buildDatePicker(
                label: '생년월일',
                value: _birthDate,
                onChanged: (date) => setState(() => _birthDate = date),
              ),

              SizedBox(height: 12.h),
              _buildTextField(
                controller: _lessonCountController,
                label: '총 레슨 횟수',
                hint: '기존 레슨 횟수를 입력하세요',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final num = int.tryParse(value);
                    if (num == null || num < 0) return '0 이상의 숫자를 입력해주세요';
                  }
                  return null;
                },
              ),

              SizedBox(height: 24.h),

              // 메모 섹션
              _buildSectionTitle('메모'),
              SizedBox(height: 12.h),
              _buildTextField(
                controller: _memoController,
                label: '메모',
                hint: '학생에 대한 메모를 입력하세요',
                maxLines: 4,
                maxLength: 500,
              ),

              SizedBox(height: 32.h),

              // 저장 버튼
              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveStudent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    disabledBackgroundColor: Colors.grey[300],
                  ),
                  child: _isLoading
                      ? SizedBox(
                          width: 24.w,
                          height: 24.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : Text(
                          isEditing ? '수정 완료' : '학생 등록',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      ),
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? value,
    required ValueChanged<DateTime?> onChanged,
  }) {
    final controller = TextEditingController(
      text: value != null
          ? '${value.year}${value.month.toString().padLeft(2, '0')}${value.day.toString().padLeft(2, '0')}'
          : '',
    );

    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      maxLength: 8,
      decoration: InputDecoration(
        labelText: '$label (예: 19840315)',
        hintText: 'YYYYMMDD',
        filled: true,
        fillColor: Colors.white,
        counterText: '',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        suffixIcon: Icon(Icons.cake_outlined, size: 20.w, color: Colors.grey[500]),
      ),
      style: TextStyle(fontSize: 14.sp),
      validator: (v) {
        if (v == null || v.isEmpty) return null; // 선택사항
        if (v.length != 8) return '8자리로 입력해주세요 (예: 19840315)';
        final year = int.tryParse(v.substring(0, 4));
        final month = int.tryParse(v.substring(4, 6));
        final day = int.tryParse(v.substring(6, 8));
        if (year == null || month == null || day == null) return '올바른 날짜를 입력해주세요';
        if (year < 1930 || year > DateTime.now().year) return '올바른 연도를 입력해주세요';
        if (month < 1 || month > 12) return '올바른 월을 입력해주세요';
        if (day < 1 || day > 31) return '올바른 일을 입력해주세요';
        return null;
      },
      onChanged: (v) {
        if (v.length == 8) {
          final year = int.tryParse(v.substring(0, 4));
          final month = int.tryParse(v.substring(4, 6));
          final day = int.tryParse(v.substring(6, 8));
          if (year != null && month != null && day != null &&
              month >= 1 && month <= 12 && day >= 1 && day <= 31) {
            onChanged(DateTime(year, month, day));
          }
        } else if (v.isEmpty) {
          onChanged(null);
        }
      },
    );
  }

  Widget _buildFamilySelector() {
    final studentsAsync = ref.watch(studentsProvider);
    return studentsAsync.when(
      data: (students) {
        // 편집 중이면 자기 자신 제외
        final others = isEditing
            ? students.where((s) => s.id != widget.student!.id).toList()
            : students;
        if (others.isEmpty) return const SizedBox.shrink();
        return DropdownButtonFormField<String>(
          value: _selectedFamilyStudentId,
          hint: const Text('가족 연결 (선택사항)'),
          items: [
            const DropdownMenuItem(value: null, child: Text('없음')),
            ...others.map((s) => DropdownMenuItem(
              value: s.id,
              child: Text('${s.studentName}${s.groupName != null ? ' (${s.groupName})' : ''}'),
            )),
          ],
          onChanged: (v) => setState(() => _selectedFamilyStudentId = v),
          decoration: InputDecoration(
            labelText: '가족 연결',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Future<void> _saveStudent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = ref.read(currentUserProvider);
      if (user == null) throw Exception('로그인이 필요합니다');

      final repo = ref.read(studentRepositoryProvider);
      final score = _scoreController.text.isNotEmpty
          ? int.tryParse(_scoreController.text)
          : null;
      final lessonCount = _lessonCountController.text.isNotEmpty
          ? int.tryParse(_lessonCountController.text)
          : null;

      // 가족 연결 처리: 선택한 학생의 family_group_id를 가져오거나 새로 생성
      String? familyGroupId;
      if (_selectedFamilyStudentId != null) {
        final familyStudent = await repo.getStudent(_selectedFamilyStudentId!);
        if (familyStudent.familyGroupId != null) {
          familyGroupId = familyStudent.familyGroupId;
        } else {
          // 새 UUID 생성하여 양쪽에 설정
          familyGroupId = const Uuid().v4();
          await repo.updateStudent(_selectedFamilyStudentId!, {
            'family_group_id': familyGroupId,
          });
        }
      }

      final groupName = _groupNameController.text.trim().isEmpty
          ? null : _groupNameController.text.trim();

      if (isEditing) {
        final phone = _phoneController.text.trim();
        final email = _emailController.text.trim();
        final memo = _memoController.text.trim();
        final goal = _goalController.text.trim();

        final updateData = <String, dynamic>{
          'student_name': _nameController.text.trim(),
          'student_phone': phone.isEmpty ? null : phone,
          'student_email': email.isEmpty ? null : email,
          'student_memo': memo.isEmpty ? null : memo,
          'current_level': _selectedLevel,
          'goal': goal.isEmpty ? null : goal,
          'average_score': score,
          'birth_date': _birthDate?.toIso8601String().split('T').first,
          'gender': _selectedGender,
          'started_golf_at': _startedGolfAt?.toIso8601String().split('T').first,
          'group_name': groupName,
          if (familyGroupId != null) 'family_group_id': familyGroupId,
          if (lessonCount != null) 'total_lesson_count': lessonCount,
        };

        await repo.updateStudent(widget.student!.id, updateData);
      } else {
        final newStudent = await repo.createStudent(
          proId: user.id,
          studentName: _nameController.text.trim(),
          studentPhone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
          studentEmail: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
          studentMemo: _memoController.text.trim().isEmpty ? null : _memoController.text.trim(),
          currentLevel: _selectedLevel,
          goal: _goalController.text.trim().isEmpty ? null : _goalController.text.trim(),
          averageScore: score,
          birthDate: _birthDate,
          gender: _selectedGender,
          startedGolfAt: _startedGolfAt,
          groupName: groupName,
        );

        // 새 학생에게도 familyGroupId 설정 (가족 연결한 경우)
        if (familyGroupId != null) {
          await repo.updateStudent(newStudent.id, {
            'family_group_id': familyGroupId,
          });
        }
      }

      // 목록 새로고침
      ref.invalidate(studentsProvider);
      ref.invalidate(studentCountProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? '학생 정보가 수정되었습니다' : '학생이 등록되었습니다'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
        context.pop();
      }
    } catch (e, stackTrace) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('일시적인 오류가 발생했습니다. 다시 시도해주세요.'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
