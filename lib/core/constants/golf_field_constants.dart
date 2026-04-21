class GolfFieldConstants {
  GolfFieldConstants._();

  // 코스 타입
  static const Map<String, String> courseTypes = {
    'full': '18홀',
    'front_9': '전반 9홀',
    'back_9': '후반 9홀',
    'nine_double': '9홀 x 2',
  };

  static int holeCount(String courseType) {
    if (courseType == 'full' || courseType == 'nine_double') return 18;
    return 9;
  }

  // 그린 위치 (한국 골프장은 좌/우 그린 운영이 많음)
  static const Map<String, String> greenSides = {
    'left': '좌그린',
    'right': '우그린',
  };

  // 샷 유형
  static const Map<String, String> shotTypes = {
    'tee': '티샷',
    'second': '2nd 샷',
    'approach': '어프로치',
    'putt': '퍼팅',
  };

  // 샷 결과
  static const Map<String, String> shotResults = {
    'straight': '스트레이트',
    'hook': '훅',
    'slice': '슬라이스',
    'top': '탑',
    'fat': '뒤땅',
    'shank': '생크',
    'push': '푸시',
    'pull': '풀',
    'fade': '페이드',
    'draw': '드로우',
    'short': '짧음',
    'long': '길음',
  };

  // 샷 원인/결함
  static const Map<String, String> shotCauses = {
    'head_up': '헤드업',
    'early_release': '얼리릴리즈',
    'over_swing': '오버스윙',
    'sway': '스웨이',
    'reverse_pivot': '리버스피봇',
    'casting': '캐스팅',
    'grip': '그립',
    'alignment': '얼라인먼트',
    'balance': '밸런스',
    'tempo': '템포',
  };

  // 클럽
  static const Map<String, String> clubs = {
    'driver': '드라이버',
    '3w': '3W',
    '5w': '5W',
    'utility': '유틸리티',
    '3i': '3I',
    '4i': '4I',
    '5i': '5I',
    '6i': '6I',
    '7i': '7I',
    '8i': '8I',
    '9i': '9I',
    'pw': 'PW',
    'aw': 'AW',
    'sw': 'SW',
    'lw': 'LW',
    'putter': '퍼터',
  };

  // 라이 (볼이 놓인 위치/경사)
  static const Map<String, String> lies = {
    'tee_box': '티박스',
    'fairway': '페어웨이',
    'rough': '러프',
    'deep_rough': '딥러프',
    'bunker': '벙커',
    'green': '그린',
    'uphill': '오르막',
    'downhill': '내리막',
    'side_hill': '옆경사',
  };

  // 스코어 라벨
  static const Map<String, String> scoreLabels = {
    'hole_in_one': '홀인원',
    'albatross': '알바트로스',
    'eagle': '이글',
    'birdie': '버디',
    'par': '파',
    'bogey': '보기',
    'double_bogey': '더블보기',
    'triple_plus': '트리플보기+',
  };

  // 프리샷 루틴 체크 항목
  static const Map<String, String> routineChecks = {
    'pre_shot_routine': '프리샷 루틴 수행',
    'alignment_check': '얼라인먼트 체크',
    'tempo_consistent': '일정한 템포 유지',
  };

  // 스코어 라벨 → 파 대비 숫자
  static int scoreToRelativePar(String label) {
    return switch (label) {
      'hole_in_one' => -4,
      'albatross' => -3,
      'eagle' => -2,
      'birdie' => -1,
      'par' => 0,
      'bogey' => 1,
      'double_bogey' => 2,
      'triple_plus' => 3,
      _ => 0,
    };
  }

  // 파 + 스코어 라벨 → 실제 타수
  static int scoreFromLabel(String label, int par) =>
      par + scoreToRelativePar(label);

  // 스코어 라벨의 색상 힌트 (UI에서 사용)
  static String scoreColor(String label) {
    return switch (label) {
      'hole_in_one' || 'albatross' || 'eagle' => 'gold',
      'birdie' => 'red',
      'par' => 'green',
      'bogey' => 'blue',
      'double_bogey' || 'triple_plus' => 'grey',
      _ => 'grey',
    };
  }

  // 페어웨이 안착으로 간주하는 티샷 결과
  static const fairwayHitResults = {
    'straight',
    'fade',
    'draw',
  };

  // 기본 홀 데이터 생성
  // round: nine_double 에서 1차/2차 구분. 일반 코스는 null.
  static Map<String, dynamic> createEmptyHole(int holeNumber, {int? round}) {
    return {
      'hole_number': holeNumber,
      'round_number': ?round,
      'par': 4,
      'score': 4,
      'score_label': 'par',
      'putts': 2,
      'memo': '',
      'green_side': null,
      'shots': <Map<String, dynamic>>[],
    };
  }

  // 기본 샷 데이터 생성
  static Map<String, dynamic> createEmptyShot(String shotType) {
    return {
      'shot_type': shotType,
      'result': '',
      'causes': <String>[],
      'club': shotType == 'putt' ? 'putter' : '',
      'lie': shotType == 'tee' ? 'tee_box' : '',
    };
  }

  // 기본 필드 데이터 생성
  static Map<String, dynamic> createEmptyFieldData(String courseType) {
    return {
      'course_type': courseType,
      'course_name': '',
      'total_score': 0,
      'total_putts': 0,
      'routine_check': {
        for (final key in routineChecks.keys) key: false,
      },
      'review_notes': '',
      'holes': _generateHoles(courseType),
    };
  }

  static List<Map<String, dynamic>> _generateHoles(String courseType) {
    switch (courseType) {
      case 'front_9':
        return List.generate(9, (i) => createEmptyHole(i + 1));
      case 'back_9':
        return List.generate(9, (i) => createEmptyHole(i + 10));
      case 'nine_double':
        return [
          for (var round = 1; round <= 2; round++)
            for (var h = 1; h <= 9; h++) createEmptyHole(h, round: round),
        ];
      case 'full':
      default:
        return List.generate(18, (i) => createEmptyHole(i + 1));
    }
  }
}
