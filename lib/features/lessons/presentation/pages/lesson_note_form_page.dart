import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/claude_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../students/presentation/providers/student_provider.dart';
import '../../data/services/lesson_note_draft_service.dart';
import '../../domain/entities/lesson_note_entity.dart';
import '../providers/lesson_note_provider.dart';
import '../widgets/field_lesson_tab.dart';
import '../../../../core/theme/app_theme.dart';

class LessonNoteFormPage extends ConsumerStatefulWidget {
  final LessonNoteEntity? note;

  const LessonNoteFormPage({super.key, this.note});

  @override
  ConsumerState<LessonNoteFormPage> createState() => _LessonNoteFormPageState();
}

class _LessonNoteFormPageState extends ConsumerState<LessonNoteFormPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _noteController;
  late final TextEditingController _homeworkController;
  late final TextEditingController _nextFocusController;
  late final TextEditingController _keyPointsController;
  late final TextEditingController _improvementsController;

  late final TextEditingController _aiBriefController;
  late final TabController _tabController;
  String? _selectedStudentId;
  Map<String, dynamic>? _fieldData;
  bool _isLoading = false;
  bool _isAiGenerating = false;

  // 드래프트 자동 저장 (디바운스 800ms)
  Timer? _draftDebounce;
  static const _draftDebounceDuration = Duration(milliseconds: 800);
  bool _draftRestoreChecked = false;

  bool get isEditing => widget.note != null;
  String? get _draftNoteId => widget.note?.id;

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
      _fieldData = n.fieldData;
    }
    // 편집 시 필드 데이터가 있으면 필드 레슨 노트 탭으로 시작
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: _fieldData != null ? 1 : 0,
    );

    // 텍스트 변경 시 드래프트 자동 저장 (디바운스)
    _noteController.addListener(_scheduleDraftSave);
    _homeworkController.addListener(_scheduleDraftSave);
    _nextFocusController.addListener(_scheduleDraftSave);
    _keyPointsController.addListener(_scheduleDraftSave);
    _improvementsController.addListener(_scheduleDraftSave);

    // 첫 프레임 후 드래프트 복원 다이얼로그
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeRestoreDraft();
    });
  }

  @override
  void dispose() {
    // 드래프트 디바운스 즉시 flush (마지막 입력 보존)
    if (_draftDebounce?.isActive ?? false) {
      _draftDebounce!.cancel();
      _flushDraft();
    }
    _noteController.removeListener(_scheduleDraftSave);
    _homeworkController.removeListener(_scheduleDraftSave);
    _nextFocusController.removeListener(_scheduleDraftSave);
    _keyPointsController.removeListener(_scheduleDraftSave);
    _improvementsController.removeListener(_scheduleDraftSave);

    _noteController.dispose();
    _homeworkController.dispose();
    _nextFocusController.dispose();
    _keyPointsController.dispose();
    _improvementsController.dispose();
    _aiBriefController.dispose();
    _tabController.dispose();
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
        child: Column(
          children: [
            // 학생 선택 (탭 밖 — 양쪽 탭 공통)
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.w, 16.w, 0),
              child: studentsAsync.when(
                data: (students) {
                  return DropdownButtonFormField<String>(
                    value: _selectedStudentId,
                    hint: const Text('학생 선택'),
                    items: students.map((s) {
                      return DropdownMenuItem(
                          value: s.id, child: Text(s.studentName));
                    }).toList(),
                    onChanged: isEditing
                        ? null
                        : (v) {
                            setState(() => _selectedStudentId = v);
                            _scheduleDraftSave();
                          },
                    validator: (v) => v == null ? '학생을 선택해주세요' : null,
                    decoration: _inputDecoration('학생 *'),
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => const Text('학생 목록 로드 실패'),
              ),
            ),
            SizedBox(height: 12.h),

            // 탭 바
            TabBar(
              controller: _tabController,
              labelColor: AppTheme.primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppTheme.primaryColor,
              labelStyle: TextStyle(
                  fontSize: 14.sp, fontWeight: FontWeight.w600),
              tabs: const [
                Tab(text: '일반 노트'),
                Tab(text: '필드 레슨 노트'),
              ],
            ),

            // 탭 뷰
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 0: 일반 노트 (기존 폼)
                  _buildGeneralNoteTab(),
                  // Tab 1: 필드 레슨 노트
                  FieldLessonTab(
                    initialFieldData: _fieldData,
                    onFieldDataChanged: (data) {
                      setState(() => _fieldData = data);
                      _scheduleDraftSave();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralNoteTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                      maxLength: 200,
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
                maxLength: 2000,
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
                maxLength: 1000,
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
                maxLength: 1000,
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
                maxLength: 1000,
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
                maxLength: 500,
                decoration: _inputDecoration('').copyWith(
                  hintText: '다음 레슨에서 집중할 내용',
                ),
              ),
              SizedBox(height: 32.h),
            ],
          ),
        );
  }

  Widget _buildAiGenerateButton() {
    return FutureBuilder<int>(
      future: _getTodayAiCount(),
      builder: (context, snapshot) {
        final usedCount = snapshot.data ?? 0;
        final remaining = _maxDailyAiUses - usedCount;
        final isLimitReached = remaining <= 0;

        return GestureDetector(
      onTap: _isAiGenerating || _selectedStudentId == null || isLimitReached ? null : _generateWithAi,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          gradient: _selectedStudentId != null && !isLimitReached
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
              Icon(Icons.auto_awesome_rounded, size: 22.w,
                color: isLimitReached ? Colors.grey : AppTheme.accentGold),
              SizedBox(width: 10.w),
              Text(
                isLimitReached
                    ? '오늘 사용 횟수를 모두 소진했습니다'
                    : 'AI 자동 생성 ($remaining/$_maxDailyAiUses)',
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
      },
    );
  }

  static const int _maxDailyAiUses = 3;

  Future<int> _getTodayAiCount() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T').first;
    final savedDate = prefs.getString('ai_note_date') ?? '';
    if (savedDate != today) return 0;
    return prefs.getInt('ai_note_count') ?? 0;
  }

  Future<void> _incrementAiCount() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T').first;
    final savedDate = prefs.getString('ai_note_date') ?? '';
    if (savedDate != today) {
      await prefs.setString('ai_note_date', today);
      await prefs.setInt('ai_note_count', 1);
    } else {
      final count = prefs.getInt('ai_note_count') ?? 0;
      await prefs.setInt('ai_note_count', count + 1);
    }
  }

  Future<void> _generateWithAi() async {
    if (_selectedStudentId == null) return;

    // 하루 사용 횟수 체크
    final todayCount = await _getTodayAiCount();
    if (todayCount >= _maxDailyAiUses) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('AI 생성은 하루 최대 ${_maxDailyAiUses}회까지 가능합니다 (오늘 ${todayCount}회 사용)'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

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
        await _incrementAiCount();
        final remaining = _maxDailyAiUses - (todayCount + 1);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('AI 노트가 생성되었습니다! (오늘 남은 횟수: ${remaining}회)'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
      }
    } catch (e, stackTrace) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('AI 생성에 실패했습니다. 다시 시도해주세요.'),
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

  // -- 드래프트 저장/복원 --

  void _scheduleDraftSave() {
    _draftDebounce?.cancel();
    _draftDebounce = Timer(_draftDebounceDuration, _flushDraft);
  }

  Map<String, dynamic>? _collectDraft() {
    final isEmpty = _noteController.text.trim().isEmpty &&
        _homeworkController.text.trim().isEmpty &&
        _nextFocusController.text.trim().isEmpty &&
        _keyPointsController.text.trim().isEmpty &&
        _improvementsController.text.trim().isEmpty &&
        _selectedStudentId == null &&
        _fieldData == null;
    if (isEmpty) return null;
    return {
      'student_id': _selectedStudentId,
      'manual_note': _noteController.text,
      'homework': _homeworkController.text,
      'next_focus': _nextFocusController.text,
      'key_points': _keyPointsController.text,
      'improvements': _improvementsController.text,
      'field_data': _fieldData,
    };
  }

  Future<void> _flushDraft() async {
    final draft = _collectDraft();
    if (draft == null) {
      await LessonNoteDraftService.clear(noteId: _draftNoteId);
      return;
    }
    await LessonNoteDraftService.save(
      noteId: _draftNoteId,
      draft: draft,
    );
  }

  Future<void> _maybeRestoreDraft() async {
    if (_draftRestoreChecked) return;
    _draftRestoreChecked = true;

    final draft = await LessonNoteDraftService.load(noteId: _draftNoteId);
    if (draft == null || !mounted) return;

    final shouldRestore = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('이전 작성 내용 복원'),
        content: const Text(
          '저장하지 않은 작성 내역이 있습니다.\n복원할까요?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('새로 시작'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('복원'),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (shouldRestore != true) {
      await LessonNoteDraftService.clear(noteId: _draftNoteId);
      return;
    }

    setState(() {
      if (!isEditing) {
        _selectedStudentId = draft['student_id'] as String?;
      }
      _noteController.text = (draft['manual_note'] as String?) ?? '';
      _homeworkController.text = (draft['homework'] as String?) ?? '';
      _nextFocusController.text = (draft['next_focus'] as String?) ?? '';
      _keyPointsController.text = (draft['key_points'] as String?) ?? '';
      _improvementsController.text = (draft['improvements'] as String?) ?? '';
      final restoredField = draft['field_data'];
      _fieldData = restoredField is Map
          ? Map<String, dynamic>.from(restoredField)
          : null;
      if (_fieldData != null) {
        _tabController.animateTo(1);
      }
    });
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
          'field_data': _fieldData,
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
          fieldData: _fieldData,
        );
      }

      ref.invalidate(lessonNotesProvider);

      // 저장 성공 시 드래프트 정리 (디바운스도 취소)
      _draftDebounce?.cancel();
      await LessonNoteDraftService.clear(noteId: _draftNoteId);

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
          const SnackBar(content: Text('저장에 실패했습니다. 다시 시도해주세요.'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
