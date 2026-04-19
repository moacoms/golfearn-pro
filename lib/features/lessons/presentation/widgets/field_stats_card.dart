import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:golfearn_pro/core/constants/golf_field_constants.dart';
import 'package:golfearn_pro/core/theme/app_theme.dart';

class FieldStatsCard extends StatelessWidget {
  const FieldStatsCard({super.key, required this.fieldData});

  final Map<String, dynamic> fieldData;

  @override
  Widget build(BuildContext context) {
    final analysis = _analyzeAllHoles();

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: AppTheme.cardShadow,
      ),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('통계 분석', Icons.analytics),
          SizedBox(height: 16.h),
          _buildMissShotTop3(analysis.resultCounts),
          SizedBox(height: 16.h),
          _buildCauseTop3(analysis.causeCounts),
          SizedBox(height: 16.h),
          _buildClubMissRate(analysis.clubStats),
          SizedBox(height: 16.h),
          _buildLieSuccessRate(analysis.lieStats),
          if (_isFullRound()) ...[SizedBox(height: 16.h), _buildFrontVsBack()],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20.sp, color: AppTheme.primaryLight),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildSubSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: AppTheme.textPrimary,
      ),
    );
  }

  Widget _buildMissShotTop3(Map<String, int> resultCounts) {
    final missResults = Map<String, int>.from(resultCounts)
      ..removeWhere(
        (key, _) => GolfFieldConstants.fairwayHitResults.contains(key),
      );

    final sorted = missResults.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top3 = sorted.take(3).toList();

    if (top3.isEmpty) {
      return _buildEmptySection('미스 샷 Top 3', '샷 데이터가 없습니다');
    }

    final maxCount = top3.isNotEmpty ? top3.first.value.toDouble() : 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSubSectionTitle('미스 샷 Top 3'),
        SizedBox(height: 8.h),
        ...top3.map(
          (entry) => _buildBarRow(
            GolfFieldConstants.shotResults[entry.key] ?? entry.key,
            entry.value,
            maxCount,
            AppTheme.errorColor,
          ),
        ),
      ],
    );
  }

  Widget _buildCauseTop3(Map<String, int> causeCounts) {
    final sorted = causeCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top3 = sorted.take(3).toList();

    if (top3.isEmpty) {
      return _buildEmptySection('원인 Top 3', '원인 데이터가 없습니다');
    }

    final maxCount = top3.isNotEmpty ? top3.first.value.toDouble() : 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSubSectionTitle('원인 Top 3'),
        SizedBox(height: 8.h),
        ...top3.map(
          (entry) => _buildBarRow(
            GolfFieldConstants.shotCauses[entry.key] ?? entry.key,
            entry.value,
            maxCount,
            AppTheme.warningColor,
          ),
        ),
      ],
    );
  }

  Widget _buildClubMissRate(Map<String, _ClubStat> clubStats) {
    if (clubStats.isEmpty) {
      return _buildEmptySection('클럽별 미스율', '클럽 데이터가 없습니다');
    }

    final entries = clubStats.entries.toList()
      ..sort((a, b) => b.value.missRate.compareTo(a.value.missRate));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSubSectionTitle('클럽별 미스율'),
        SizedBox(height: 8.h),
        ...entries.map((entry) {
          final rate = entry.value.missRate;
          return _buildBarRow(
            GolfFieldConstants.clubs[entry.key] ?? entry.key,
            (rate * 100).round(),
            100,
            _missRateColor(rate),
            suffix: '%',
          );
        }),
      ],
    );
  }

  Widget _buildLieSuccessRate(Map<String, _LieStat> lieStats) {
    if (lieStats.isEmpty) {
      return _buildEmptySection('라이별 성공률', '라이 데이터가 없습니다');
    }

    final entries = lieStats.entries.toList()
      ..sort((a, b) => b.value.successRate.compareTo(a.value.successRate));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSubSectionTitle('라이별 성공률'),
        SizedBox(height: 8.h),
        ...entries.map((entry) {
          final rate = entry.value.successRate;
          return _buildBarRow(
            GolfFieldConstants.lies[entry.key] ?? entry.key,
            (rate * 100).round(),
            100,
            _successRateColor(rate),
            suffix: '%',
          );
        }),
      ],
    );
  }

  Widget _buildFrontVsBack() {
    final holes = List<Map<String, dynamic>>.from(fieldData['holes'] as List);
    if (holes.length < 18) return const SizedBox.shrink();

    final frontScore = _sumScores(holes.sublist(0, 9));
    final backScore = _sumScores(holes.sublist(9, 18));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSubSectionTitle('전반 vs 후반'),
        SizedBox(height: 8.h),
        Row(
          children: [
            _buildHalfScoreChip('전반', frontScore),
            SizedBox(width: 12.w),
            _buildHalfScoreChip('후반', backScore),
            SizedBox(width: 12.w),
            _buildDiffChip(frontScore, backScore),
          ],
        ),
      ],
    );
  }

  Widget _buildHalfScoreChip(String label, int score) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppTheme.primaryLight.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              '$score',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiffChip(int frontScore, int backScore) {
    final diff = backScore - frontScore;
    final diffLabel = diff > 0 ? '+$diff' : '$diff';
    final isBetter = diff < 0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: (isBetter ? AppTheme.successColor : AppTheme.errorColor)
            .withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        children: [
          Text(
            '차이',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            diffLabel,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: isBetter ? AppTheme.successColor : AppTheme.errorColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarRow(
    String label,
    int value,
    double maxValue,
    Color color, {
    String suffix = '회',
  }) {
    final ratio = maxValue > 0 ? value / maxValue : 0.0;

    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          SizedBox(
            width: 80.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 16.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: ratio.clamp(0.0, 1.0),
                  child: Container(
                    height: 16.h,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          SizedBox(
            width: 40.w,
            child: Text(
              '$value$suffix',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySection(String title, String message) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSubSectionTitle(title),
        SizedBox(height: 8.h),
        Text(
          message,
          style: TextStyle(fontSize: 13.sp, color: AppTheme.textMuted),
        ),
      ],
    );
  }

  Color _missRateColor(double rate) {
    if (rate >= 0.7) return AppTheme.errorColor;
    if (rate >= 0.4) return AppTheme.warningColor;
    return AppTheme.successColor;
  }

  Color _successRateColor(double rate) {
    if (rate >= 0.7) return AppTheme.successColor;
    if (rate >= 0.4) return AppTheme.warningColor;
    return AppTheme.errorColor;
  }

  bool _isFullRound() => (fieldData['course_type'] as String? ?? '') == 'full';

  int _sumScores(List<Map<String, dynamic>> holes) {
    var total = 0;
    for (final hole in holes) {
      total += (hole['score'] as int?) ?? 0;
    }
    return total;
  }

  _AnalysisResult _analyzeAllHoles() {
    final holes = List<Map<String, dynamic>>.from(fieldData['holes'] as List);

    final resultCounts = <String, int>{};
    final causeCounts = <String, int>{};
    final clubStats = <String, _ClubStat>{};
    final lieStats = <String, _LieStat>{};

    for (final hole in holes) {
      final shots = List<Map<String, dynamic>>.from(
        hole['shots'] as List? ?? [],
      );

      for (final shot in shots) {
        final result = shot['result'] as String? ?? '';
        final club = shot['club'] as String? ?? '';
        final lie = shot['lie'] as String? ?? '';
        final causes = List<String>.from(shot['causes'] as List? ?? <String>[]);
        final shotType = shot['shot_type'] as String? ?? '';

        if (result.isNotEmpty) {
          resultCounts[result] = (resultCounts[result] ?? 0) + 1;
        }

        for (final cause in causes) {
          causeCounts[cause] = (causeCounts[cause] ?? 0) + 1;
        }

        if (club.isNotEmpty && shotType != 'putt') {
          final stat = clubStats[club] ?? const _ClubStat();
          final isGood = GolfFieldConstants.fairwayHitResults.contains(result);
          clubStats[club] = _ClubStat(
            total: stat.total + 1,
            misses: stat.misses + (isGood ? 0 : 1),
          );
        }

        if (lie.isNotEmpty && shotType != 'putt') {
          final stat = lieStats[lie] ?? const _LieStat();
          final isGood = GolfFieldConstants.fairwayHitResults.contains(result);
          lieStats[lie] = _LieStat(
            total: stat.total + 1,
            successes: stat.successes + (isGood ? 1 : 0),
          );
        }
      }
    }

    return _AnalysisResult(
      resultCounts: resultCounts,
      causeCounts: causeCounts,
      clubStats: clubStats,
      lieStats: lieStats,
    );
  }
}

class _AnalysisResult {
  const _AnalysisResult({
    required this.resultCounts,
    required this.causeCounts,
    required this.clubStats,
    required this.lieStats,
  });

  final Map<String, int> resultCounts;
  final Map<String, int> causeCounts;
  final Map<String, _ClubStat> clubStats;
  final Map<String, _LieStat> lieStats;
}

class _ClubStat {
  const _ClubStat({this.total = 0, this.misses = 0});

  final int total;
  final int misses;

  double get missRate => total > 0 ? misses / total : 0.0;
}

class _LieStat {
  const _LieStat({this.total = 0, this.successes = 0});

  final int total;
  final int successes;

  double get successRate => total > 0 ? successes / total : 0.0;
}
