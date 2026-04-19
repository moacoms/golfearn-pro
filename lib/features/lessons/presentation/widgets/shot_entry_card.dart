import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:golfearn_pro/core/constants/golf_field_constants.dart';
import 'package:golfearn_pro/core/theme/app_theme.dart';

/// 퍼팅 전용 결과 옵션 (일반 샷 결과와 다름)
const Map<String, String> _puttResults = {
  'short': '짧음',
  'long': '길음',
  'straight': '스트레이트',
  'pull': '풀',
  'push': '푸시',
};

class ShotEntryCard extends StatelessWidget {
  const ShotEntryCard({
    super.key,
    required this.shotType,
    required this.shotData,
    required this.onChanged,
  });

  /// 'tee', 'second', 'approach', 'putt'
  final String shotType;

  /// Contains `result`, `causes`, `club`, and `lie` fields.
  final Map<String, dynamic> shotData;

  /// 변경 시 새로운 Map을 전달 (immutability)
  final void Function(Map<String, dynamic>) onChanged;

  static const _chipColor = AppTheme.primaryLight;

  bool get _isPutt => shotType == 'putt';

  String get _selectedClub =>
      (shotData['club'] as String?) ?? (_isPutt ? 'putter' : '');

  String get _selectedLie => (shotData['lie'] as String?) ?? '';

  String get _selectedResult => (shotData['result'] as String?) ?? '';

  List<String> get _selectedCauses =>
      List<String>.from((shotData['causes'] as List?) ?? <String>[]);

  Map<String, dynamic> _emitUpdated(String key, dynamic value) {
    final updated = Map<String, dynamic>.from(shotData);
    updated[key] = value;
    return updated;
  }

  @override
  Widget build(BuildContext context) {
    final shotLabel =
        GolfFieldConstants.shotTypes[shotType] ?? shotType;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            shotLabel,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 8.h),

          // Club selector
          if (!_isPutt) _buildClubDropdown(),
          if (!_isPutt) SizedBox(height: 8.h),

          // Lie selector (non-putt only)
          if (!_isPutt) ...[
            _buildSectionTitle('라이'),
            SizedBox(height: 4.h),
            _buildLieChips(),
            SizedBox(height: 8.h),
          ],

          // Shot result
          _buildSectionTitle('결과'),
          SizedBox(height: 4.h),
          _buildResultChips(),
          SizedBox(height: 8.h),

          // Cause / fault (multi-select)
          _buildSectionTitle('원인'),
          SizedBox(height: 4.h),
          _buildCauseChips(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        color: Colors.grey[700],
      ),
    );
  }

  Widget _buildClubDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedClub.isEmpty ? null : _selectedClub,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: '클럽 선택',
        labelStyle: TextStyle(fontSize: 13.sp),
        contentPadding:
            EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        isDense: true,
      ),
      items: GolfFieldConstants.clubs.entries
          .where((e) => e.key != 'putter')
          .map(
            (e) => DropdownMenuItem(
              value: e.key,
              child: Text(e.value, style: TextStyle(fontSize: 13.sp)),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value != null) {
          onChanged(_emitUpdated('club', value));
        }
      },
    );
  }

  Widget _buildLieChips() {
    return Wrap(
      spacing: 6.w,
      runSpacing: 4.h,
      children: GolfFieldConstants.lies.entries.map((entry) {
        final isSelected = _selectedLie == entry.key;
        return ChoiceChip(
          label: Text(
            entry.value,
            style: TextStyle(
              fontSize: 12.sp,
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
          ),
          selected: isSelected,
          selectedColor: _chipColor,
          backgroundColor: Colors.grey[100],
          visualDensity: VisualDensity.compact,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          onSelected: (selected) {
            final newLie = selected ? entry.key : '';
            onChanged(_emitUpdated('lie', newLie));
          },
        );
      }).toList(),
    );
  }

  Widget _buildResultChips() {
    final results = _isPutt ? _puttResults : GolfFieldConstants.shotResults;

    return Wrap(
      spacing: 6.w,
      runSpacing: 4.h,
      children: results.entries.map((entry) {
        final isSelected = _selectedResult == entry.key;
        return ChoiceChip(
          label: Text(
            entry.value,
            style: TextStyle(
              fontSize: 12.sp,
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
          ),
          selected: isSelected,
          selectedColor: _chipColor,
          backgroundColor: Colors.grey[100],
          visualDensity: VisualDensity.compact,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          onSelected: (selected) {
            final newResult = selected ? entry.key : '';
            onChanged(_emitUpdated('result', newResult));
          },
        );
      }).toList(),
    );
  }

  Widget _buildCauseChips() {
    return Wrap(
      spacing: 6.w,
      runSpacing: 4.h,
      children: GolfFieldConstants.shotCauses.entries.map((entry) {
        final causes = _selectedCauses;
        final isSelected = causes.contains(entry.key);
        return FilterChip(
          label: Text(
            entry.value,
            style: TextStyle(
              fontSize: 12.sp,
              color: isSelected ? _chipColor : Colors.grey[700],
            ),
          ),
          selected: isSelected,
          selectedColor: _chipColor.withValues(alpha: 0.15),
          backgroundColor: Colors.grey[100],
          checkmarkColor: _chipColor,
          visualDensity: VisualDensity.compact,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          onSelected: (selected) {
            final newCauses = selected
                ? [...causes, entry.key]
                : causes.where((c) => c != entry.key).toList();
            onChanged(_emitUpdated('causes', newCauses));
          },
        );
      }).toList(),
    );
  }
}
