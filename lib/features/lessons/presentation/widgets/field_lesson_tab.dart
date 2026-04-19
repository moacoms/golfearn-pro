import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:golfearn_pro/core/constants/golf_field_constants.dart';
import 'package:golfearn_pro/core/theme/app_theme.dart';

import './hole_card.dart';
import './score_summary_card.dart';
import './field_stats_card.dart';

class FieldLessonTab extends StatefulWidget {
  const FieldLessonTab({
    super.key,
    this.initialFieldData,
    required this.onFieldDataChanged,
  });

  final Map<String, dynamic>? initialFieldData;
  final void Function(Map<String, dynamic>?) onFieldDataChanged;

  @override
  State<FieldLessonTab> createState() => _FieldLessonTabState();
}

class _FieldLessonTabState extends State<FieldLessonTab> {
  late Map<String, dynamic> _fieldData;

  String get _courseType => (_fieldData['course_type'] as String?) ?? 'full';

  List<Map<String, dynamic>> get _holes =>
      List<Map<String, dynamic>>.from(_fieldData['holes'] as List);

  Map<String, dynamic> get _routineCheck =>
      Map<String, dynamic>.from(_fieldData['routine_check'] as Map? ?? {});

  bool get _hasAnyHoleData => _holes.any(
    (hole) =>
        ((hole['shots'] as List?)?.isNotEmpty ?? false) ||
        (hole['score'] as int? ?? 0) > 0,
  );

  @override
  void initState() {
    super.initState();
    _fieldData = widget.initialFieldData != null
        ? Map<String, dynamic>.from(widget.initialFieldData!)
        : GolfFieldConstants.createEmptyFieldData('full');
  }

  void _updateFieldData(Map<String, dynamic> updated) {
    setState(() {
      _fieldData = updated;
    });
    widget.onFieldDataChanged(_fieldData);
  }

  void _onCourseTypeChanged(String courseType) {
    if (courseType == _courseType) return;
    final newData = GolfFieldConstants.createEmptyFieldData(courseType);
    final updated = {
      ...newData,
      'course_name': _fieldData['course_name'] ?? '',
      'review_notes': _fieldData['review_notes'] ?? '',
    };
    _updateFieldData(updated);
  }

  void _onCourseNameChanged(String name) {
    _updateFieldData({..._fieldData, 'course_name': name});
  }

  void _onRoutineToggled(String key, bool value) {
    final updatedRoutine = {..._routineCheck, key: value};
    _updateFieldData({..._fieldData, 'routine_check': updatedRoutine});
  }

  void _onHoleChanged(int index, Map<String, dynamic> updatedHole) {
    final updatedHoles = [..._holes];
    updatedHoles[index] = updatedHole;

    var totalScore = 0;
    var totalPutts = 0;
    for (final hole in updatedHoles) {
      totalScore += (hole['score'] as int?) ?? 0;
      totalPutts += (hole['putts'] as int?) ?? 0;
    }

    _updateFieldData({
      ..._fieldData,
      'holes': updatedHoles,
      'total_score': totalScore,
      'total_putts': totalPutts,
    });
  }

  void _onReviewNotesChanged(String notes) {
    _updateFieldData({..._fieldData, 'review_notes': notes});
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCourseTypeSelector(),
          SizedBox(height: 12.h),
          _buildCourseNameField(),
          SizedBox(height: 16.h),
          _buildRoutineSection(),
          SizedBox(height: 16.h),
          ScoreSummaryCard(fieldData: _fieldData),
          SizedBox(height: 16.h),
          _buildHoleCards(),
          if (_hasAnyHoleData) ...[
            SizedBox(height: 16.h),
            FieldStatsCard(fieldData: _fieldData),
          ],
          SizedBox(height: 16.h),
          _buildReviewNotesField(),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildCourseTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '코스 타입',
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: GolfFieldConstants.courseTypes.entries.map((entry) {
            final isSelected = _courseType == entry.key;
            return Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: ChoiceChip(
                label: Text(
                  entry.value,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: isSelected ? Colors.white : AppTheme.textSecondary,
                  ),
                ),
                selected: isSelected,
                selectedColor: AppTheme.primaryLight,
                backgroundColor: AppTheme.surfaceElevated,
                onSelected: (_) => _onCourseTypeChanged(entry.key),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCourseNameField() {
    return TextField(
      controller: TextEditingController.fromValue(
        TextEditingValue(
          text: (_fieldData['course_name'] as String?) ?? '',
          selection: TextSelection.collapsed(
            offset: ((_fieldData['course_name'] as String?) ?? '').length,
          ),
        ),
      ),
      decoration: InputDecoration(
        hintText: '코스명 (예: 고양CC)',
        prefixIcon: Icon(
          Icons.place_outlined,
          size: 20.sp,
          color: AppTheme.textMuted,
        ),
      ),
      style: TextStyle(fontSize: 14.sp),
      onChanged: _onCourseNameChanged,
    );
  }

  Widget _buildRoutineSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: AppTheme.cardShadow,
      ),
      padding: EdgeInsets.all(12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '프리샷 루틴 체크',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          ...GolfFieldConstants.routineChecks.entries.map((entry) {
            final isChecked = (_routineCheck[entry.key] as bool?) ?? false;
            return CheckboxListTile(
              title: Text(entry.value, style: TextStyle(fontSize: 14.sp)),
              value: isChecked,
              activeColor: AppTheme.primaryLight,
              dense: true,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (value) =>
                  _onRoutineToggled(entry.key, value ?? false),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHoleCards() {
    final holes = _holes;
    return Column(
      children: List.generate(holes.length, (index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: HoleCard(
            holeData: holes[index],
            onChanged: (updated) => _onHoleChanged(index, updated),
          ),
        );
      }),
    );
  }

  Widget _buildReviewNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '핵심 복습 메모',
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: TextEditingController.fromValue(
            TextEditingValue(
              text: (_fieldData['review_notes'] as String?) ?? '',
              selection: TextSelection.collapsed(
                offset: ((_fieldData['review_notes'] as String?) ?? '').length,
              ),
            ),
          ),
          decoration: InputDecoration(
            hintText: '핵심 복습 메모 (오늘의 레슨 요약, 다음 연습 포인트 등)',
            alignLabelWithHint: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          maxLines: 4,
          maxLength: 1000,
          style: TextStyle(fontSize: 14.sp),
          onChanged: _onReviewNotesChanged,
        ),
      ],
    );
  }
}
