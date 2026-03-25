import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/database_constants.dart';
import '../../domain/entities/student_entity.dart';
import '../providers/student_provider.dart';

class StudentsListPage extends ConsumerWidget {
  const StudentsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(filteredStudentsProvider);
    final searchQuery = ref.watch(studentSearchQueryProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '학생 관리',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => context.push('/students/new'),
            icon: Icon(
              Icons.person_add,
              color: const Color(0xFF10B981),
              size: 24.w,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 검색바
          Container(
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
            child: TextField(
              onChanged: (value) {
                ref.read(studentSearchQueryProvider.notifier).update(value);
              },
              decoration: InputDecoration(
                hintText: '이름, 전화번호, 이메일로 검색',
                hintStyle: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[400],
                ),
                prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              ),
            ),
          ),

          // 학생 목록
          Expanded(
            child: studentsAsync.when(
              data: (students) {
                if (students.isEmpty) {
                  return _buildEmptyState(context, searchQuery.isNotEmpty);
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(studentsProvider);
                  },
                  child: ListView.builder(
                    padding: EdgeInsets.all(16.w),
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      return _buildStudentCard(context, students[index]);
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48.w, color: Colors.red[300]),
                    SizedBox(height: 16.h),
                    Text(
                      '학생 목록을 불러올 수 없습니다',
                      style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 8.h),
                    TextButton(
                      onPressed: () => ref.invalidate(studentsProvider),
                      child: const Text('다시 시도'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isSearching) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearching ? Icons.search_off : Icons.people_outline,
            size: 64.w,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16.h),
          Text(
            isSearching ? '검색 결과가 없습니다' : '등록된 학생이 없습니다',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8.h),
          if (!isSearching)
            ElevatedButton.icon(
              onPressed: () => context.push('/students/new'),
              icon: const Icon(Icons.person_add),
              label: const Text('첫 학생 등록하기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(BuildContext context, StudentEntity student) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: InkWell(
        onTap: () => context.push('/students/${student.id}'),
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              // 아바타
              CircleAvatar(
                radius: 24.r,
                backgroundColor: const Color(0xFF10B981).withOpacity(0.1),
                child: Text(
                  student.studentName.isNotEmpty ? student.studentName[0] : '?',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF10B981),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              // 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            student.studentName,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (student.userId != null) ...[
                          SizedBox(width: 6.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.link, size: 10.w, color: Colors.blue),
                                SizedBox(width: 3.w),
                                Text(
                                  '앱 연결됨',
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        if (student.currentLevel != null) ...[
                          SizedBox(width: 6.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: _getLevelColor(student.currentLevel!).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              student.currentLevel!,
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: _getLevelColor(student.currentLevel!),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        if (student.studentPhone != null) ...[
                          Icon(Icons.phone, size: 14.w, color: Colors.grey[500]),
                          SizedBox(width: 4.w),
                          Text(
                            student.studentPhone!,
                            style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
                          ),
                          SizedBox(width: 12.w),
                        ],
                        Icon(Icons.sports_golf, size: 14.w, color: Colors.grey[500]),
                        SizedBox(width: 4.w),
                        Text(
                          '레슨 ${student.totalLessonCount}회',
                          style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case '입문':
        return Colors.blue;
      case '초급':
        return Colors.green;
      case '중급':
        return Colors.orange;
      case '상급':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
