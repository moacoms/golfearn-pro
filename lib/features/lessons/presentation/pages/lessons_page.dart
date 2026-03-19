import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../students/presentation/providers/student_provider.dart';
import '../../../students/domain/entities/student_entity.dart';
import '../../domain/entities/lesson_note_entity.dart';
import '../providers/lesson_note_provider.dart';
import 'lesson_note_form_page.dart';

class LessonsPage extends ConsumerWidget {
  const LessonsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(lessonNotesProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '레슨 노트',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewNote(context, ref),
        backgroundColor: const Color(0xFF10B981),
        child: const Icon(Icons.note_add, color: Colors.white),
      ),
      body: notesAsync.when(
        data: (notes) {
          if (notes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.note_outlined, size: 64.w, color: Colors.grey[400]),
                  SizedBox(height: 16.h),
                  Text(
                    '작성된 레슨 노트가 없습니다',
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '레슨 후 노트를 작성해보세요',
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(lessonNotesProvider),
            child: ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: notes.length,
              itemBuilder: (context, index) => _buildNoteCard(context, ref, notes[index]),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48.w, color: Colors.red[300]),
              SizedBox(height: 16.h),
              Text('레슨 노트를 불러올 수 없습니다', style: TextStyle(fontSize: 16.sp, color: Colors.grey[600])),
              TextButton(
                onPressed: () => ref.invalidate(lessonNotesProvider),
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoteCard(BuildContext context, WidgetRef ref, LessonNoteEntity note) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => LessonNoteFormPage(note: note),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18.r,
                    backgroundColor: const Color(0xFF10B981).withOpacity(0.1),
                    child: Icon(Icons.note, size: 18.w, color: const Color(0xFF10B981)),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          note.title ?? '레슨 노트',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          '${note.studentName ?? "학생"} | ${_formatDate(note.lessonDate)}',
                          style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'delete') {
                        await ref.read(lessonNoteRepositoryProvider).deleteLessonNote(note.id);
                        ref.invalidate(lessonNotesProvider);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'delete', child: Text('삭제', style: TextStyle(color: Colors.red))),
                    ],
                  ),
                ],
              ),
              if (note.content != null && note.content!.isNotEmpty) ...[
                SizedBox(height: 12.h),
                Text(
                  note.content!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[700], height: 1.4),
                ),
              ],
              if (note.improvement != null && note.improvement!.isNotEmpty) ...[
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(Icons.trending_up, size: 14.w, color: Colors.green),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        '개선: ${note.improvement!}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12.sp, color: Colors.green[700]),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _showNewNote(BuildContext context, WidgetRef ref) async {
    try {
      final user = ref.read(currentUserProvider);
      if (user == null) return;

      final repo = ref.read(studentRepositoryProvider);
      final students = await repo.getStudents(user.id);

      if (!context.mounted) return;

      if (students.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('먼저 학생을 등록해주세요'), backgroundColor: Colors.orange),
        );
        return;
      }
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const LessonNoteFormPage()),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('학생 목록을 불러올 수 없습니다: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
