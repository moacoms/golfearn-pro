import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:golfearn_pro/core/constants/golf_field_constants.dart';
import 'package:golfearn_pro/core/theme/app_theme.dart';
import 'package:golfearn_pro/features/lessons/presentation/widgets/shot_entry_card.dart';

class HoleCard extends StatelessWidget {
  const HoleCard({
    super.key,
    required this.holeData,
    required this.onChanged,
  });

  final Map<String, dynamic> holeData;
  final void Function(Map<String, dynamic>) onChanged;

  static const _parOptions = [3, 4, 5];
  static const _maxPutts = 6;
  static const _memoMaxLength = 200;

  int get _holeNumber => holeData['hole_number'] as int;
  int? get _roundNumber => holeData['round_number'] as int?;
  int get _par => holeData['par'] as int;
  int get _score => holeData['score'] as int;
  String get _scoreLabel => holeData['score_label'] as String? ?? '';
  int get _putts => holeData['putts'] as int? ?? 0;
  String get _memo => holeData['memo'] as String? ?? '';
  String? get _greenSide => holeData['green_side'] as String?;

  List<Map<String, dynamic>> get _shots {
    final raw = holeData['shots'] as List<dynamic>?;
    if (raw == null || raw.isEmpty) return [];
    return raw.cast<Map<String, dynamic>>();
  }

  // -- helpers ---------------------------------------------------------------

  String _buildTitle() {
    final roundSuffix = _roundNumber != null ? ' ($_roundNumber\uCC28)' : '';
    final greenSuffix = _greenSide != null
        ? ' \u00B7 ${GolfFieldConstants.greenSides[_greenSide] ?? ''}'
        : '';
    final base = '$_holeNumber\uBC88\uD640$roundSuffix$greenSuffix Par $_par';
    if (_scoreLabel.isEmpty) return base;

    final label =
        GolfFieldConstants.scoreLabels[_scoreLabel] ?? _scoreLabel;
    final relative = GolfFieldConstants.scoreToRelativePar(_scoreLabel);
    final sign = relative > 0
        ? '+'
        : relative < 0
            ? ''
            : '\u00B1';
    return '$base \u2014 $label ($sign$relative)';
  }

  Color _chipColorForLabel(String label) {
    final hint = GolfFieldConstants.scoreColor(label);
    return switch (hint) {
      'gold' => const Color(0xFFD4A853),
      'red' => const Color(0xFFDC2626),
      'green' => AppTheme.primaryColor,
      'blue' => const Color(0xFF3B82F6),
      _ => const Color(0xFF9CA3AF),
    };
  }

  Map<String, dynamic> _updated(Map<String, Object?> changes) {
    return {...holeData, ...changes};
  }

  List<Map<String, dynamic>> _defaultShots(int par) {
    if (par == 3) {
      return [
        GolfFieldConstants.createEmptyShot('tee'),
        GolfFieldConstants.createEmptyShot('approach'),
        GolfFieldConstants.createEmptyShot('putt'),
      ];
    }
    return [
      GolfFieldConstants.createEmptyShot('tee'),
      GolfFieldConstants.createEmptyShot('second'),
      GolfFieldConstants.createEmptyShot('approach'),
      GolfFieldConstants.createEmptyShot('putt'),
    ];
  }

  List<Map<String, dynamic>> _ensureShots(int par) {
    final existing = _shots;
    if (existing.isEmpty) return _defaultShots(par);
    if (par == 3) {
      return existing
          .where((s) => s['shot_type'] != 'second')
          .toList();
    }
    final hasSecond =
        existing.any((s) => s['shot_type'] == 'second');
    if (!hasSecond) {
      final teeIndex =
          existing.indexWhere((s) => s['shot_type'] == 'tee');
      final insertAt = teeIndex >= 0 ? teeIndex + 1 : 1;
      return [
        ...existing.sublist(0, insertAt),
        GolfFieldConstants.createEmptyShot('second'),
        ...existing.sublist(insertAt),
      ];
    }
    return existing;
  }

  // -- callbacks -------------------------------------------------------------

  void _onParChanged(int newPar) {
    final shots = _ensureShots(newPar);
    final newScore = _scoreLabel.isNotEmpty
        ? GolfFieldConstants.scoreFromLabel(_scoreLabel, newPar)
        : newPar;
    onChanged(_updated({
      'par': newPar,
      'score': newScore,
      'shots': shots,
    }));
  }

  void _onScoreLabelChanged(String label) {
    onChanged(_updated({
      'score_label': label,
      'score': GolfFieldConstants.scoreFromLabel(label, _par),
    }));
  }

  void _onPuttsChanged(int delta) {
    final next = (_putts + delta).clamp(0, _maxPutts);
    onChanged(_updated({'putts': next}));
  }

  void _onShotChanged(int index, Map<String, dynamic> newShot) {
    final shots = List<Map<String, dynamic>>.from(_shots);
    final updated = [
      ...shots.sublist(0, index),
      newShot,
      ...shots.sublist(index + 1),
    ];
    onChanged(_updated({'shots': updated}));
  }

  void _onMemoChanged(String value) {
    onChanged(_updated({'memo': value}));
  }

  void _onGreenSideChanged(String? side) {
    onChanged(_updated({'green_side': side}));
  }

  // -- build -----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final shots = _ensureShots(_par);

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        side: BorderSide(color: AppTheme.borderColor, width: 0.5),
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: 12.w),
        childrenPadding: EdgeInsets.symmetric(horizontal: 12.w),
        title: Text(
          _buildTitle(),
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [
          _buildParSelector(context),
          Divider(height: 16.h),
          _buildGreenSideSelector(context),
          Divider(height: 16.h),
          _buildScoreSelector(context),
          Divider(height: 16.h),
          _buildPuttsCounter(context),
          Divider(height: 16.h),
          ...List.generate(shots.length, (i) {
            return Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: ShotEntryCard(
                shotType: shots[i]['shot_type'] as String? ?? 'tee',
                shotData: shots[i],
                onChanged: (newShot) => _onShotChanged(i, newShot),
              ),
            );
          }),
          Divider(height: 8.h),
          _buildMemoField(context),
          SizedBox(height: 12.h),
        ],
      ),
    );
  }

  Widget _buildParSelector(BuildContext context) {
    return Row(
      children: [
        Text(
          'Par',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: AppTheme.textSecondary,
          ),
        ),
        SizedBox(width: 12.w),
        ..._parOptions.map((p) {
          final isSelected = p == _par;
          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: ChoiceChip(
              label: Text('Par $p'),
              selected: isSelected,
              selectedColor: AppTheme.primaryColor,
              labelStyle: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : AppTheme.textPrimary,
              ),
              onSelected: (_) => _onParChanged(p),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildScoreSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '\uC2A4\uCF54\uC5B4',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: AppTheme.textSecondary,
          ),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 6.w,
          runSpacing: 6.h,
          children:
              GolfFieldConstants.scoreLabels.entries.map((entry) {
            final isSelected = entry.key == _scoreLabel;
            final chipColor = _chipColorForLabel(entry.key);
            return ChoiceChip(
              label: Text(entry.value),
              selected: isSelected,
              selectedColor: chipColor,
              labelStyle: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : chipColor,
              ),
              side: isSelected
                  ? BorderSide.none
                  : BorderSide(color: chipColor.withOpacity(0.4)),
              onSelected: (_) => _onScoreLabelChanged(entry.key),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGreenSideSelector(BuildContext context) {
    return Row(
      children: [
        Text(
          '\uADF8\uB9B0',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: AppTheme.textSecondary,
          ),
        ),
        SizedBox(width: 12.w),
        ...GolfFieldConstants.greenSides.entries.map((entry) {
          final isSelected = entry.key == _greenSide;
          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: ChoiceChip(
              label: Text(entry.value),
              selected: isSelected,
              selectedColor: AppTheme.primaryColor,
              labelStyle: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : AppTheme.textPrimary,
              ),
              onSelected: (selected) =>
                  _onGreenSideChanged(selected ? entry.key : null),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPuttsCounter(BuildContext context) {
    return Row(
      children: [
        Text(
          '\uD37C\uD2B8',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: AppTheme.textSecondary,
          ),
        ),
        const Spacer(),
        _counterButton(
          icon: Icons.remove,
          enabled: _putts > 0,
          onTap: () => _onPuttsChanged(-1),
        ),
        SizedBox(
          width: 36.w,
          child: Text(
            '$_putts',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        _counterButton(
          icon: Icons.add,
          enabled: _putts < _maxPutts,
          onTap: () => _onPuttsChanged(1),
        ),
      ],
    );
  }

  Widget _counterButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 32.w,
        height: 32.w,
        decoration: BoxDecoration(
          color: enabled
              ? AppTheme.primaryColor.withOpacity(0.1)
              : AppTheme.borderColor,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(
          icon,
          size: 18.sp,
          color: enabled ? AppTheme.primaryColor : AppTheme.textMuted,
        ),
      ),
    );
  }

  Widget _buildMemoField(BuildContext context) {
    return TextField(
      controller: TextEditingController(text: _memo),
      maxLength: _memoMaxLength,
      maxLines: 1,
      style: TextStyle(fontSize: 13.sp),
      decoration: InputDecoration(
        hintText: '\uD640 \uBA54\uBAA8',
        counterText: '',
        isDense: true,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 12.w,
          vertical: 10.h,
        ),
      ),
      onChanged: _onMemoChanged,
    );
  }
}
