import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/sport_constants.dart';
import '../../../../core/services/claude_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../students/presentation/providers/student_provider.dart';
import '../../domain/entities/lesson_note_entity.dart';
import '../providers/lesson_note_provider.dart';
import '../../../../core/theme/app_theme.dart';

class LessonNoteFormPage extends ConsumerStatefulWidget {
  final LessonNoteEntity? note;

  const LessonNoteFormPage({super.key, this.note});

  @override
  ConsumerState<LessonNoteFormPage> createState() => _LessonNoteFormPageState();
}

class _LessonNoteFormPageState extends ConsumerState<LessonNoteFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _noteController;
  late final TextEditingController _homeworkController;
  late final TextEditingController _nextFocusController;
  late final TextEditingController _keyPointsController;
  late final TextEditingController _improvementsController;

  late final TextEditingController _aiBriefController;
  String? _selectedStudentId;
  bool _isLoading = false;
  bool _isAiGenerating = false;

  bool get isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();
    final n = widget.note;
    _noteController = TextEditingController(text: n?.manualNote ?? '');
    _homeworkController = TextEditingController(text: n?.homework ?? '');
    _nextFocusController = TextEditingController(text: n?.nextFocus ?? '');
    _keyPointsController = TextEditingController(
      text: n?.keyPoints?.join('\n') ?? '',
    );
    _improvementsController = TextEditingController(
      text: n?.improvements?.join('\n') ?? '',
    );
    _aiBriefController = TextEditingController();
    if (n != null) {
      _selectedStudentId = n.studentId;
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    _homeworkController.dispose();
    _nextFocusController.dispose();
    _keyPointsController.dispose();
    _improvementsController.dispose();
    _aiBriefController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final studentsAsync = ref.watch(studentsProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          isEditing ? '노트 수정' : '레슨 노트 작성',
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveNote,
            child: Text(
              '저장',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: _isLoading ? Colors.grey : AppTheme.primaryColor,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 학생 선택
              studentsAsync.when(
                data: (students) {
                  return DropdownButtonFormField<String>(
                    value: _selectedStudentId,
                    hint: const Text('학생 선택'),
                    items: students.map((s) {
                      return DropdownMenuItem(value: s.id, child: Text(s.studentName));
                    }).toList(),
                    onChanged: isEditing ? null : (v) => setState(() => _selectedStudentId = v),
                    validator: (v) => v == null ? '학생을 선택해주세요' : null,
                    decoration: _inputDecoration('학생 *'),
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => const Text('학생 목록 로드 실패'),
              ),
              SizedBox(height: 16.h),

              // AI 간단 메모 + 생성 버튼
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: AppTheme.primaryColor.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.auto_awesome_rounded, size: 18.w, color: AppTheme.accentGold),
                        SizedBox(width: 8.w),
                        Text(
                          'AI 노트 생성',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    TextFormField(
                      controller: _aiBriefController,
                      maxLines: 2,
                      decoration: _inputDecoration('').copyWith(
                        hintText: '오늘 레슨 키워드 입력 (예: 드라이버 슬라이스 교정, 그립 변경)',
                        hintStyle: TextStyle(fontSize: 13.sp, color: Colors.grey[400]),
                        fillColor: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    _buildAiGenerateButton(),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              // 레슨 내용
              _buildSectionTitle('레슨 내용'),
              SizedBox(height: 8.h),
              TextFormField(
                controller: _noteController,
                maxLines: 6,
                decoration: _inputDecoration('').copyWith(
                  hintText: '오늘 레슨 내용을 기록하세요',
                ),
              ),
              SizedBox(height: 16.h),

              // 개선 사항 (줄바꿈으로 여러 항목)
              _buildSectionTitle('개선 사항'),
              SizedBox(height: 8.h),
              TextFormField(
                controller: _improvementsController,
                maxLines: 3,
                decoration: _inputDecoration('').copyWith(
                  hintText: '개선할 점을 줄바꿈으로 구분하여 입력',
                ),
              ),
              SizedBox(height: 16.h),

              // 핵심 포인트 (줄바꿈으로 여러 항목)
              _buildSectionTitle('핵심 포인트'),
              SizedBox(height: 8.h),
              TextFormField(
                controller: _keyPointsController,
                maxLines: 3,
                decoration: _inputDecoration('').copyWith(
                  hintText: '핵심 포인트를 줄바꿈으로 구분하여 입력',
                ),
              ),
              SizedBox(height: 16.h),

              // 과제 / 숙제
              _buildSectionTitle('과제 / 숙제'),
              SizedBox(height: 8.h),
              TextFormField(
                controller: _homeworkController,
                maxLines: 3,
                decoration: _inputDecoration('').copyWith(
                  hintText: '다음 레슨까지 연습할 내용',
                ),
              ),
              SizedBox(height: 16.h),

              // 다음 레슨 포커스
              _buildSectionTitle('다음 레슨 포커스'),
              SizedBox(height: 8.h),
              TextFormField(
                controller: _nextFocusController,
                maxLines: 2,
                decoration: _inputDecoration('').copyWith(
                  hintText: '다음 레슨에서 집중할 내용',
                ),
              ),
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAiGenerateButton() {
    return GestureDetector(
      onTap: _isAiGenerating || _selectedStudentId == null ? null : _generateWithAi,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          gradient: _selectedStudentId != null
              ? AppTheme.primaryGradient
              : const LinearGradient(colors: [Color(0xFF9CA3AF), Color(0xFFD1D5DB)]),
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: _selectedStudentId != null ? AppTheme.elevatedShadow : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isAiGenerating) ...[
              SizedBox(
                width: 20.w, height: 20.w,
                child: const CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'AI가 노트를 작성 중...',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ] else ...[
              Icon(Icons.auto_awesome_rounded, size: 22.w, color: AppTheme.accentGold),
              SizedBox(width: 10.w),
              Text(
                'AI 레슨 노트 자동 생성',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _generateWithAi() async {
    if (_selectedStudentId == null) return;

    setState(() => _isAiGenerating = true);

    try {
      // 학생 정보 가져오기
      final student = await ref.read(studentRepositoryProvider)
          .getStudent(_selectedStudentId!);

      // 이전 레슨 노트 가져오기 (최근 3개)
      final user = ref.read(currentUserProvider);
      String? previousNotes;
      if (user != null) {
        try {
          final notes = await ref.read(lessonNoteRepositoryProvider)
              .getStudentNotes(user.id, _selectedStudentId!);
          if (notes.isNotEmpty) {
            final recent = notes.take(3).map((n) =>
              '- ${n.manualNote ?? ""} / 과제: ${n.homework ?? "없음"}'
            ).join('\n');
            previousNotes = recent;
          }
        } catch (_) {}
      }

      final claude = ClaudeService();
      final briefText = _aiBriefController.text.trim();
      final result = await claude.generateStructuredLessonNote(
        studentName: student.studentName,
        studentLevel: student.currentLevel,
        studentGoal: student.goal,
        averageScore: student.averageScore,
        totalLessonCount: student.totalLessonCount,
        golfMonths: student.startedGolfAt != null
            ? DateTime.now().difference(student.startedGolfAt!).inDays ~/ 30
            : null,
        previousNotes: previousNotes,
        briefInput: briefText.isNotEmpty ? briefText : null,
      );

      if (mounted) {
        setState(() {
          if (result['manual_note'] != null) {
            _noteController.text = result['manual_note'];
          }
          if (result['key_points'] != null) {
            _keyPointsController.text = (result['key_points'] as List).join('\n');
          }
          if (result['improvements'] != null) {
            _improvementsController.text = (result['improvements'] as List).join('\n');
          }
          if (result['homework'] != null) {
            _homeworkController.text = result['homework'];
          }
          if (result['next_focus'] != null) {
            _nextFocusController.text = result['next_focus'];
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('AI 노트가 생성되었습니다. 수정 후 저장하세요!'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
      }
    } catch (e, stackTrace) {
      print('========== AI 레슨 노트 생성 에러 ==========');
      print('studentId: $_selectedStudentId');
      print('에러: $e');
      print('스택: $stackTrace');
      print('============================================');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('AI 생성 실패: ${e.toString().replaceAll("Exception: ", "")}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isAiGenerating = false);
    }
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.black),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label.isNotEmpty ? label : null,
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
    );
  }

  /// 텍스트를 줄바꿈으로 분리하여 리스트로 변환
  List<String>? _textToList(String text) {
    if (text.trim().isEmpty) return null;
    return text
        .split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedStudentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('학생을 선택해주세요'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = ref.read(currentUserProvider);
      if (user == null) throw Exception('로그인이 필요합니다');

      final repo = ref.read(lessonNoteRepositoryProvider);

      if (isEditing) {
        await repo.updateLessonNote(widget.note!.id, {
          'manual_note': _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
          'homework': _homeworkController.text.trim().isEmpty ? null : _homeworkController.text.trim(),
          'next_focus': _nextFocusController.text.trim().isEmpty ? null : _nextFocusController.text.trim(),
          'key_points': _textToList(_keyPointsController.text),
          'improvements': _textToList(_improvementsController.text),
        });
      } else {
        await repo.createLessonNote(
          proId: user.id,
          studentId: _selectedStudentId!,
          manualNote: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
          homework: _homeworkController.text.trim().isEmpty ? null : _homeworkController.text.trim(),
          nextFocus: _nextFocusController.text.trim().isEmpty ? null : _nextFocusController.text.trim(),
          keyPoints: _textToList(_keyPointsController.text),
          improvements: _textToList(_improvementsController.text),
        );
      }

      ref.invalidate(lessonNotesProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? '노트가 수정되었습니다' : '노트가 저장되었습니다'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장 실패: ${e.toString().replaceAll('Exception: ', '')}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
