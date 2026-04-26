import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:golfearn_pro/core/constants/golf_field_constants.dart';
import 'package:golfearn_pro/core/theme/app_theme.dart';

class ScoreSummaryCard extends StatelessWidget {
  const ScoreSummaryCard({super.key, required this.fieldData});

  final Map<String, dynamic> fieldData;

  @override
  Widget build(BuildContext context) {
    final stats = _calculateStats();

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: AppTheme.cardShadow,
        border: Border(
          left: BorderSide(color: AppTheme.primaryLight, width: 4.w),
        ),
      ),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(stats),
          SizedBox(height: 12.h),
          _buildScoreRow(stats),
          SizedBox(height: 12.h),
          _buildStatGrid(stats),
          SizedBox(height: 8.h),
          _buildShortGameGrid(stats),
        ],
      ),
    );
  }

  Widget _buildHeader(_SummaryStats stats) {
    final courseName = fieldData['course_name'] as String? ?? '';
    final courseType =
        GolfFieldConstants.courseTypes[fieldData['course_type']] ?? '';

    return Row(
      children: [
        Icon(Icons.golf_course, color: AppTheme.primaryLight, size: 20.sp),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            courseName.isNotEmpty ? courseName : courseType,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScoreRow(_SummaryStats stats) {
    final relativePar = stats.totalScore - stats.totalPar;
    final relativeLabel = relativePar > 0 ? '+$relativePar' : '$relativePar';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${stats.totalScore}',
          style: TextStyle(
            fontSize: 36.sp,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
            height: 1.0,
          ),
        ),
        SizedBox(width: 12.w),
        Padding(
          padding: EdgeInsets.only(bottom: 4.h),
          child: Text(
            'Par ${stats.totalPar} | $relativeLabel',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatGrid(_SummaryStats stats) {
    return Row(
      children: [
        _buildStatItem('퍼트', '${stats.totalPutts}', Icons.sports_golf),
        SizedBox(width: 16.w),
        _buildStatItem(
          '페어웨이 안착률',
          '${stats.fairwayHitRate.toStringAsFixed(1)}%',
          Icons.straighten,
        ),
        SizedBox(width: 16.w),
        _buildStatItem(
          'GIR',
          '${stats.girRate.toStringAsFixed(1)}%',
          Icons.flag,
        ),
      ],
    );
  }

  Widget _buildShortGameGrid(_SummaryStats stats) {
    return Row(
      children: [
        _buildStatItem(
          '샌드세이브',
          stats.sandSaveAttempts > 0
              ? '${stats.sandSaveRate.toStringAsFixed(0)}%'
              : '—',
          Icons.beach_access,
        ),
        SizedBox(width: 16.w),
        _buildStatItem(
          '업앤다운',
          stats.upDownAttempts > 0
              ? '${stats.upDownRate.toStringAsFixed(0)}%'
              : '—',
          Icons.flash_on,
        ),
        SizedBox(width: 16.w),
        _buildStatItem(
          '드라이빙 평균',
          stats.drivingAvgM != null
              ? '${stats.drivingAvgM!.round()}m'
              : '—',
          Icons.golf_course,
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppTheme.primaryLight.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16.sp, color: AppTheme.primaryLight),
            SizedBox(height: 4.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w400,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  _SummaryStats _calculateStats() {
    final holes = List<Map<String, dynamic>>.from(fieldData['holes'] as List);

    var totalScore = 0;
    var totalPar = 0;
    var totalPutts = 0;
    var fairwayEligible = 0;
    var fairwayHits = 0;
    var girCount = 0;
    var sandSaveAttempts = 0;
    var sandSaveMade = 0;
    var upDownAttempts = 0;
    var upDownMade = 0;
    final driveDistances = <int>[];

    for (final hole in holes) {
      final par = hole['par'] as int? ?? 4;
      final score = hole['score'] as int? ?? par;
      final putts = hole['putts'] as int? ?? 0;
      final shots = List<Map<String, dynamic>>.from(
        hole['shots'] as List? ?? [],
      );

      totalScore += score;
      totalPar += par;
      totalPutts += putts;

      if (par >= 4) {
        fairwayEligible++;
        final teeShot = shots.isEmpty
            ? null
            : shots.firstWhere(
                (s) => s['shot_type'] == 'tee',
                orElse: () => <String, dynamic>{},
              );
        final teeResult = teeShot?['result'] as String? ?? '';
        if (GolfFieldConstants.fairwayHitResults.contains(teeResult)) {
          fairwayHits++;
        }
      }

      if (_isGreenInRegulation(shots, par)) {
        girCount++;
      }

      final sandSave = hole['sand_save'] as String?;
      if (sandSave == 'made') {
        sandSaveAttempts++;
        sandSaveMade++;
      } else if (sandSave == 'missed') {
        sandSaveAttempts++;
      }

      final upDown = hole['up_and_down'] as String?;
      if (upDown == 'made') {
        upDownAttempts++;
        upDownMade++;
      } else if (upDown == 'missed') {
        upDownAttempts++;
      }

      // 드라이빙 거리: 티샷 + 드라이버 + distance_m 입력된 경우
      for (final shot in shots) {
        if (shot['shot_type'] == 'tee' &&
            shot['club'] == 'driver' &&
            shot['distance_m'] is int) {
          driveDistances.add(shot['distance_m'] as int);
        }
      }
    }

    final fairwayHitRate = fairwayEligible > 0
        ? (fairwayHits / fairwayEligible) * 100
        : 0.0;
    final girRate = holes.isNotEmpty ? (girCount / holes.length) * 100 : 0.0;
    final sandSaveRate = sandSaveAttempts > 0
        ? (sandSaveMade / sandSaveAttempts) * 100
        : 0.0;
    final upDownRate = upDownAttempts > 0
        ? (upDownMade / upDownAttempts) * 100
        : 0.0;
    final drivingAvgM = driveDistances.isEmpty
        ? null
        : driveDistances.reduce((a, b) => a + b) / driveDistances.length;

    return _SummaryStats(
      totalScore: totalScore,
      totalPar: totalPar,
      totalPutts: totalPutts,
      fairwayHitRate: fairwayHitRate,
      girRate: girRate,
      sandSaveAttempts: sandSaveAttempts,
      sandSaveRate: sandSaveRate,
      upDownAttempts: upDownAttempts,
      upDownRate: upDownRate,
      drivingAvgM: drivingAvgM,
    );
  }

  /// Par 3: tee shot reaches green (shot 1)
  /// Par 4: shot <= 2 reaches green
  /// Par 5: shot <= 3 reaches green
  bool _isGreenInRegulation(List<Map<String, dynamic>> shots, int par) {
    if (shots.isEmpty) return false;

    final girThreshold = par - 2;
    for (var i = 0; i < shots.length && i <= girThreshold; i++) {
      final shot = shots[i];
      final shotType = shot['shot_type'] as String? ?? '';
      final lie = shot['lie'] as String? ?? '';
      if (shotType == 'approach' || lie == 'green') return true;
      if (shotType == 'putt') return true;
    }
    return false;
  }
}

class _SummaryStats {
  const _SummaryStats({
    required this.totalScore,
    required this.totalPar,
    required this.totalPutts,
    required this.fairwayHitRate,
    required this.girRate,
    required this.sandSaveAttempts,
    required this.sandSaveRate,
    required this.upDownAttempts,
    required this.upDownRate,
    required this.drivingAvgM,
  });

  final int totalScore;
  final int totalPar;
  final int totalPutts;
  final double fairwayHitRate;
  final double girRate;
  final int sandSaveAttempts;
  final double sandSaveRate;
  final int upDownAttempts;
  final double upDownRate;
  final double? drivingAvgM;
}
