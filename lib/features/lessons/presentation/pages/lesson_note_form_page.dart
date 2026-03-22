import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/sport_constants.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../students/presentation/providers/student_provider.dart';
import '../../domain/entities/lesson_note_entity.dart';
import '../providers/lesson_note_provider.dart';

class LessonNoteFormPage extends ConsumerStatefulWidget {
  final LessonNoteEntity? note;

  const LessonNoteFormPage({super.key, this.note});

  @override
  ConsumerState<LessonNoteFormPage> createState() => _LessonNoteFormPageState();
}

class _LessonNoteFormPageState extends ConsumerState<LessonNoteFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late final TextEditingController _improvementController;
  late final TextEditingController _homeworkController;

  String? _selectedStudentId;
  DateTime _lessonDate = DateTime.now();
  bool _isLoading = false;

  bool get isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();
    final n = widget.note;
    _titleController = TextEditingController(text: n?.title ?? '');
    _contentController = TextEditingController(text: n?.content ?? '');
    _improvementController = TextEditingController(text: n?.improvement ?? '');
    _homeworkController = TextEditingController(text: n?.homework ?? '');
    if (n != null) {
      _selectedStudentId = n.studentId;
      _lessonDate = n.lessonDate;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _improvementController.dispose();
    _homeworkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final studentsAsync = ref.watch(studentsProvider);
    final sportType = ref.watch(currentSportTypeProvider);
    final hints = SportConstants.noteHints(sportType);

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
                color: _isLoading ? Colors.grey : const Color(0xFF10B981),
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
              SizedBox(height: 12.h),

              // 레슨 날짜
              GestureDetector(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _lessonDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(primary: Color(0xFF10B981)),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (date != null) setState(() => _lessonDate = date);
                },
                child: InputDecorator(
                  decoration: _inputDecoration('레슨 날짜').copyWith(
                    suffixIcon: Icon(Icons.calendar_today, size: 20.w, color: Colors.grey[500]),
                  ),
                  child: Text(
                    '${_lessonDate.year}년 ${_lessonDate.month}월 ${_lessonDate.day}일',
                    style: TextStyle(fontSize: 14.sp),
                  ),
                ),
              ),
              SizedBox(height: 12.h),

              // 제목
              TextFormField(
                controller: _titleController,
                decoration: _inputDecoration('제목').copyWith(hintText: hints['title']),
              ),
              SizedBox(height: 16.h),

              // 레슨 내용
              _buildSectionTitle('레슨 내용'),
              SizedBox(height: 8.h),
              TextFormField(
                controller: _contentController,
                maxLines: 6,
                decoration: _inputDecoration('').copyWith(
                  hintText: hints['content'],
                ),
              ),
              SizedBox(height: 16.h),

              // 개선 사항
              _buildSectionTitle('개선 사항'),
              SizedBox(height: 8.h),
              TextFormField(
                controller: _improvementController,
                maxLines: 3,
                decoration: _inputDecoration('').copyWith(
                  hintText: hints['improvement'],
                ),
              ),
              SizedBox(height: 16.h),

              // 과제
              _buildSectionTitle('과제 / 숙제'),
              SizedBox(height: 8.h),
              TextFormField(
                controller: _homeworkController,
                maxLines: 3,
                decoration: _inputDecoration('').copyWith(
                  hintText: hints['homework'],
                ),
              ),
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
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
        borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
    );
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
          'title': _titleController.text.trim().isEmpty ? null : _titleController.text.trim(),
          'content': _contentController.text.trim().isEmpty ? null : _contentController.text.trim(),
          'improvement': _improvementController.text.trim().isEmpty ? null : _improvementController.text.trim(),
          'homework': _homeworkController.text.trim().isEmpty ? null : _homeworkController.text.trim(),
          'lesson_date': _lessonDate.toIso8601String().split('T').first,
        });
      } else {
        await repo.createLessonNote(
          proId: user.id,
          studentId: _selectedStudentId!,
          lessonDate: _lessonDate,
          title: _titleController.text.trim().isEmpty ? null : _titleController.text.trim(),
          content: _contentController.text.trim().isEmpty ? null : _contentController.text.trim(),
          improvement: _improvementController.text.trim().isEmpty ? null : _improvementController.text.trim(),
          homework: _homeworkController.text.trim().isEmpty ? null : _homeworkController.text.trim(),
        );
      }

      ref.invalidate(lessonNotesProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? '노트가 수정되었습니다' : '노트가 저장되었습니다'),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
