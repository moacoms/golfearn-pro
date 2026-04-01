import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/services/claude_service.dart';
import '../../../students/presentation/providers/student_provider.dart';
import '../../../students/domain/entities/student_entity.dart';
import '../../../../core/theme/app_theme.dart';

class AnalysisPage extends ConsumerStatefulWidget {
  const AnalysisPage({super.key});

  @override
  ConsumerState<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends ConsumerState<AnalysisPage> {
  ClaudeService? _claudeService;
  String? _initError;
  final _descriptionController = TextEditingController();
  StudentEntity? _selectedStudent;
  bool _isAnalyzing = false;
  String? _analysisResult;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    try {
      _claudeService = ClaudeService();
    } catch (e) {
      _initError = e.toString();
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _requestAnalysis() async {
    if (_claudeService == null) return;
    if (_descriptionController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = '스윙 설명을 입력해주세요.';
      });
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
      _analysisResult = null;
    });

    try {
      final studentInfo = _selectedStudent != null
          ? '학생 이름: ${_selectedStudent!.studentName}\n'
              '레벨: ${_selectedStudent!.currentLevel ?? "미설정"}\n'
              '목표: ${_selectedStudent!.goal ?? "미설정"}\n'
          : '';

      final prompt = '''
골프 레슨프로로서 학생의 스윙을 분석해주세요.

$studentInfo
프로의 스윙 관찰 내용:
${_descriptionController.text}

다음 항목을 포함하여 구조화된 피드백을 제공해주세요:

## 문제점
- 관찰된 스윙의 주요 문제점을 구체적으로 분석

## 교정 방법
- 각 문제점에 대한 교정 방법을 단계별로 설명

## 연습 드릴
- 실전에서 바로 활용 가능한 연습 드릴 제안

전문적이면서도 이해하기 쉬운 한국어로 작성해주세요.
''';

      final result = await _claudeService!.analyzeSwing(
        videoUrl: '',
        additionalContext: prompt,
      );

      setState(() {
        _analysisResult = result;
        _isAnalyzing = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'AI 분석 요청 실패: $e';
        _isAnalyzing = false;
      });
    }
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
          'AI 스윙 분석',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // API key not set warning
            if (_initError != null) ...[
              _buildApiKeyWarning(),
              SizedBox(height: 16.h),
            ],

            // Student selector
            if (_initError == null) ...[
              _buildSectionLabel('학생 선택'),
              SizedBox(height: 8.h),
              _buildStudentSelector(studentsAsync),
              SizedBox(height: 20.h),

              // Swing description input
              _buildSectionLabel('스윙 설명'),
              SizedBox(height: 8.h),
              _buildDescriptionInput(),
              SizedBox(height: 20.h),

              // Submit button
              _buildAnalyzeButton(),
              SizedBox(height: 20.h),

              // Error message
              if (_errorMessage != null) ...[
                _buildErrorMessage(),
                SizedBox(height: 16.h),
              ],

              // Loading indicator
              if (_isAnalyzing) ...[
                _buildLoadingIndicator(),
                SizedBox(height: 16.h),
              ],

              // Analysis result
              if (_analysisResult != null) _buildResultCard(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildApiKeyWarning() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.orange.shade700, size: 24.w),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'AI 분석 기능을 사용하려면 설정에서 API 키를 등록해주세요',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.orange.shade800,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildStudentSelector(AsyncValue<List<StudentEntity>> studentsAsync) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: studentsAsync.when(
        data: (students) {
          return DropdownButtonHideUnderline(
            child: DropdownButton<StudentEntity?>(
              isExpanded: true,
              value: _selectedStudent,
              hint: Text(
                '학생을 선택하세요 (선택사항)',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[500],
                ),
              ),
              items: [
                DropdownMenuItem<StudentEntity?>(
                  value: null,
                  child: Text(
                    '선택 안함',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[500],
                    ),
                  ),
                ),
                ...students.map((student) {
                  final subtitle = [
                    if (student.currentLevel != null) student.currentLevel,
                    if (student.goal != null) student.goal,
                  ].join(' / ');
                  return DropdownMenuItem<StudentEntity?>(
                    value: student,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          student.studentName,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (subtitle.isNotEmpty)
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey[500],
                            ),
                          ),
                      ],
                    ),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedStudent = value;
                });
              },
            ),
          );
        },
        loading: () => Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Row(
            children: [
              SizedBox(
                width: 16.w,
                height: 16.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.primaryColor,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                '학생 목록 불러오는 중...',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
        error: (_, __) => Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Text(
            '학생 목록을 불러올 수 없습니다',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.red[400],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDescriptionInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        controller: _descriptionController,
        maxLines: 6,
        decoration: InputDecoration(
          hintText: '학생의 스윙 문제점이나 관찰 내용을 입력하세요.\n\n'
              '예: 백스윙 시 오른쪽 팔꿈치가 과도하게 벌어지고, '
              '다운스윙에서 얼리 릴리스가 발생합니다. '
              '임팩트 시 체중이동이 부족합니다.',
          hintStyle: TextStyle(
            fontSize: 13.sp,
            color: Colors.grey[400],
          ),
          contentPadding: EdgeInsets.all(16.w),
          border: InputBorder.none,
        ),
        style: TextStyle(
          fontSize: 14.sp,
          color: Colors.black87,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildAnalyzeButton() {
    return SizedBox(
      height: 52.h,
      child: ElevatedButton(
        onPressed: _isAnalyzing ? null : _requestAnalysis,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          disabledBackgroundColor: AppTheme.primaryColor.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome, size: 20.w, color: Colors.white),
            SizedBox(width: 8.w),
            Text(
              '분석 요청',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600, size: 20.w),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.red.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            width: 40.w,
            height: 40.w,
            child: const CircularProgressIndicator(
              color: AppTheme.primaryColor,
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'AI가 스윙을 분석하고 있습니다...',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '잠시만 기다려주세요',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome,
                  size: 20.w, color: AppTheme.primaryColor),
              SizedBox(width: 8.w),
              Text(
                'AI 분석 결과',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const Spacer(),
              if (_selectedStudent != null)
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    _selectedStudent!.studentName,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
            ],
          ),
          Divider(height: 24.h, color: Colors.grey[200]),
          SelectableText(
            _analysisResult!,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.black87,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
