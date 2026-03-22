import 'package:flutter/material.dart';

/// 스포츠 종목 열거형
enum SportType {
  golf,
  tennis,
  badminton,
  swimming,
  pilatesYoga,
  other,
}

/// 스포츠 종목별 설정 정의
class SportConstants {
  SportConstants._();

  /// DB 문자열 → SportType 변환
  static SportType fromString(String? value) {
    switch (value) {
      case 'golf':
        return SportType.golf;
      case 'tennis':
        return SportType.tennis;
      case 'badminton':
        return SportType.badminton;
      case 'swimming':
        return SportType.swimming;
      case 'pilates_yoga':
        return SportType.pilatesYoga;
      case 'other':
        return SportType.other;
      default:
        return SportType.golf;
    }
  }

  /// SportType → DB 문자열 변환
  static String toDbString(SportType type) {
    switch (type) {
      case SportType.golf:
        return 'golf';
      case SportType.tennis:
        return 'tennis';
      case SportType.badminton:
        return 'badminton';
      case SportType.swimming:
        return 'swimming';
      case SportType.pilatesYoga:
        return 'pilates_yoga';
      case SportType.other:
        return 'other';
    }
  }

  /// 종목 한글 이름
  static String label(SportType type) {
    switch (type) {
      case SportType.golf:
        return '골프';
      case SportType.tennis:
        return '테니스';
      case SportType.badminton:
        return '배드민턴';
      case SportType.swimming:
        return '수영';
      case SportType.pilatesYoga:
        return '필라테스/요가';
      case SportType.other:
        return '기타';
    }
  }

  /// 종목 아이콘
  static IconData icon(SportType type) {
    switch (type) {
      case SportType.golf:
        return Icons.sports_golf;
      case SportType.tennis:
        return Icons.sports_tennis;
      case SportType.badminton:
        return Icons.sports_tennis; // 배드민턴 전용 아이콘 없음
      case SportType.swimming:
        return Icons.pool;
      case SportType.pilatesYoga:
        return Icons.fitness_center;
      case SportType.other:
        return Icons.sports;
    }
  }

  /// 종목별 레슨 타입 목록 (key: DB값, value: 표시 텍스트)
  static Map<String, String> lessonTypes(SportType type) {
    switch (type) {
      case SportType.golf:
        return {
          'regular': '일반',
          'playing': '필드',
          'short_game': '숏게임',
          'putting': '퍼팅',
        };
      case SportType.tennis:
        return {
          'forehand': '포핸드',
          'backhand': '백핸드',
          'serve': '서브',
          'match': '경기',
        };
      case SportType.badminton:
        return {
          'basic': '기본기',
          'smash': '스매시',
          'defense': '수비',
          'match': '경기',
        };
      case SportType.swimming:
        return {
          'freestyle': '자유형',
          'backstroke': '배영',
          'breaststroke': '평영',
          'butterfly': '접영',
        };
      case SportType.pilatesYoga:
        return {
          'mat': '매트',
          'equipment': '기구',
          'personal': '개인',
          'group': '그룹',
        };
      case SportType.other:
        return {
          'regular': '일반',
          'practice': '연습',
          'match': '실전',
          'group': '그룹',
        };
    }
  }

  /// 레슨 타입 DB값 → 한글 라벨 변환
  static String lessonTypeLabel(SportType type, String? lessonTypeKey) {
    if (lessonTypeKey == null) return '일반 레슨';
    final types = lessonTypes(type);
    return types[lessonTypeKey] ?? lessonTypeKey;
  }

  /// 종목별 레슨노트 힌트 텍스트
  static Map<String, String> noteHints(SportType type) {
    switch (type) {
      case SportType.golf:
        return {
          'title': '예: 드라이버 스윙 교정',
          'content': '오늘 레슨에서 진행한 내용을 작성하세요...',
          'improvement': '학생의 스윙, 자세 등 개선된 점이나 앞으로 개선할 점...',
          'homework': '다음 레슨까지 연습할 내용...',
        };
      case SportType.tennis:
        return {
          'title': '예: 포핸드 폼 체크',
          'content': '오늘 레슨에서 진행한 내용을 작성하세요...',
          'improvement': '폼 체크, 전략 등 개선된 점이나 앞으로 개선할 점...',
          'homework': '다음 레슨까지 연습할 내용...',
        };
      case SportType.badminton:
        return {
          'title': '예: 스매시 자세 교정',
          'content': '오늘 레슨에서 진행한 내용을 작성하세요...',
          'improvement': '폼, 풋워크 등 개선된 점이나 앞으로 개선할 점...',
          'homework': '다음 레슨까지 연습할 내용...',
        };
      case SportType.swimming:
        return {
          'title': '예: 자유형 호흡법 교정',
          'content': '오늘 레슨에서 진행한 내용을 작성하세요...',
          'improvement': '자세, 호흡 등 개선된 점이나 앞으로 개선할 점...',
          'homework': '다음 레슨까지 연습할 내용...',
        };
      case SportType.pilatesYoga:
        return {
          'title': '예: 코어 강화 프로그램',
          'content': '오늘 레슨에서 진행한 내용을 작성하세요...',
          'improvement': '동작, 호흡 등 개선된 점이나 앞으로 개선할 점...',
          'homework': '다음 레슨까지 연습할 내용...',
        };
      case SportType.other:
        return {
          'title': '예: 기본기 교정',
          'content': '오늘 레슨에서 진행한 내용을 작성하세요...',
          'improvement': '개선된 점이나 앞으로 개선할 점...',
          'homework': '다음 레슨까지 연습할 내용...',
        };
    }
  }

  /// 종목별 학생 정보 섹션 타이틀
  static String studentInfoSectionTitle(SportType type) {
    switch (type) {
      case SportType.golf:
        return '골프 정보';
      case SportType.tennis:
        return '테니스 정보';
      case SportType.badminton:
        return '배드민턴 정보';
      case SportType.swimming:
        return '수영 정보';
      case SportType.pilatesYoga:
        return '필라테스/요가 정보';
      case SportType.other:
        return '레슨 정보';
    }
  }

  /// 종목별 점수/기록 라벨 (골프: 평균 스코어, 수영: 기록 등)
  static String? scoreLabel(SportType type) {
    switch (type) {
      case SportType.golf:
        return '평균 스코어';
      case SportType.swimming:
        return '기록 (초)';
      default:
        return null;
    }
  }

  /// 종목별 시작일 라벨
  static String startDateLabel(SportType type) {
    return '${label(type)} 시작일';
  }

  /// 종목별 목표 힌트
  static String goalHint(SportType type) {
    switch (type) {
      case SportType.golf:
        return '예: 100타 깨기, 드라이버 비거리 향상';
      case SportType.tennis:
        return '예: 서브 속도 향상, 대회 출전';
      case SportType.badminton:
        return '예: 스매시 강화, 풋워크 개선';
      case SportType.swimming:
        return '예: 자유형 50m 기록 단축';
      case SportType.pilatesYoga:
        return '예: 유연성 향상, 코어 강화';
      case SportType.other:
        return '예: 기본기 향상';
    }
  }

  /// 종목별 장소 힌트
  static String locationHint(SportType type) {
    switch (type) {
      case SportType.golf:
        return '예: 강남 골프존';
      case SportType.tennis:
        return '예: OO 테니스장';
      case SportType.badminton:
        return '예: OO 체육관';
      case SportType.swimming:
        return '예: OO 수영장';
      case SportType.pilatesYoga:
        return '예: OO 스튜디오';
      case SportType.other:
        return '예: 레슨 장소';
    }
  }

  /// 선택 가능한 모든 종목 목록
  static List<SportType> get allTypes => SportType.values;
}
