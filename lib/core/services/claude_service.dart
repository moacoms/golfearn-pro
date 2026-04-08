import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClaudeService {
  static const String _model = 'claude-haiku-4-5-20251001';

  late final String _proxyUrl;
  late final String _anonKey;

  ClaudeService() {
    final supabaseUrl = const String.fromEnvironment('SUPABASE_URL').isNotEmpty
        ? const String.fromEnvironment('SUPABASE_URL')
        : (dotenv.env['SUPABASE_URL'] ?? '');
    _anonKey = Supabase.instance.client.rest.headers['apikey'] ?? '';
    _proxyUrl = '$supabaseUrl/functions/v1/claude-proxy';
  }

  /// 스윙 분석 요청
  Future<String> analyzeSwing({
    required String videoUrl,
    String? additionalContext,
  }) async {
    try {
      final data = await _callClaude(
        prompt: _buildSwingAnalysisPrompt(videoUrl, additionalContext),
        maxTokens: 1000,
      );
      return data['content'][0]['text'];
    } catch (e) {
      throw Exception('Claude API 호출 실패: $e');
    }
  }

  /// 레슨 노트 작성 도우미
  Future<String> generateLessonNote({
    required String studentName,
    required String lessonContent,
    String? improvements,
  }) async {
    try {
      final data = await _callClaude(
        prompt: _buildLessonNotePrompt(studentName, lessonContent, improvements),
        maxTokens: 500,
      );
      return data['content'][0]['text'];
    } catch (e) {
      throw Exception('Claude API 호출 실패: $e');
    }
  }

  /// 구조화된 레슨 노트 자동 생성
  Future<Map<String, dynamic>> generateStructuredLessonNote({
    required String studentName,
    String? studentLevel,
    String? studentGoal,
    int? averageScore,
    int? totalLessonCount,
    int? golfMonths,
    String? previousNotes,
    String? briefInput,
  }) async {
    try {
      // 레벨별 맞춤 지시
      String levelContext = '';
      switch (studentLevel) {
        case '입문':
          levelContext = '이 학생은 골프를 처음 배우는 입문자입니다. 기본기(그립, 어드레스, 스윙 기초)에 집중하고, 용어를 쉽게 설명하세요. 작은 성취도 크게 격려해주세요.';
          break;
        case '초급':
          levelContext = '이 학생은 기본기를 익힌 초급자입니다. 일관성 있는 스윙 만들기, 아이언 정확도, 기본 어프로치에 집중하세요.';
          break;
        case '중급':
          levelContext = '이 학생은 중급자입니다. 코스 매니지먼트, 다양한 샷(페이드/드로우), 숏게임 정밀도, 멘탈 관리에 집중하세요.';
          break;
        case '상급':
          levelContext = '이 학생은 상급자입니다. 세밀한 기술 조정, 경기 전략, 프리샷 루틴, 특수 상황 대처에 집중하세요.';
          break;
        default:
          levelContext = '';
      }

      final prompt = '''
당신은 경험 많은 골프 레슨프로의 레슨 노트 작성 어시스턴트입니다.
프로가 입력한 키워드와 학생 정보를 바탕으로, 실제 레슨에서 있었을 법한 구체적인 노트를 작성해주세요.

## 학생 프로필
- 이름: $studentName
${studentLevel != null ? '- 레벨: $studentLevel' : ''}
${averageScore != null ? '- 평균 스코어: ${averageScore}타' : ''}
${totalLessonCount != null ? '- 누적 레슨 횟수: ${totalLessonCount}회' : ''}
${golfMonths != null ? '- 골프 경력: ${golfMonths}개월' : ''}
${studentGoal != null ? '- 학생 목표: $studentGoal' : ''}

${levelContext.isNotEmpty ? '## 레벨 맞춤 지시\n$levelContext\n' : ''}
${previousNotes != null ? '## 최근 레슨 기록 (이 내용과 이어지도록 작성)\n$previousNotes\n' : ''}
${briefInput != null && briefInput.isNotEmpty ? '## 오늘 레슨 키워드 (프로가 입력)\n$briefInput\n\n이 키워드를 중심으로 구체적인 레슨 노트를 작성하세요.' : '## 참고\n학생의 레벨과 목표에 맞는 일반적인 레슨 노트를 작성하세요.'}

## 작성 규칙
1. 이전 레슨 기록이 있으면 반드시 연속성을 유지하세요 (이전 숙제 확인, 진전 언급)
2. 학생 레벨에 맞는 난이도와 용어를 사용하세요
3. 구체적인 드릴이나 연습 방법을 포함하세요 (예: "하프스윙 50회" 등 숫자 포함)
4. 과제는 집에서 할 수 있는 실천 가능한 내용으로 작성하세요
5. 전문적이면서도 따뜻하고 격려하는 톤으로 작성하세요

## 응답 형식
반드시 아래 JSON 형식으로만 응답하세요. 코드블록(```) 없이 순수 JSON만 출력하세요.
각 항목은 간결하게 1-2문장으로 작성하세요.

{
  "manual_note": "오늘 레슨 내용 요약 (2-3문장)",
  "key_points": ["핵심 포인트 1", "핵심 포인트 2"],
  "improvements": ["개선할 점 1", "개선할 점 2"],
  "homework": "연습 과제 (드릴명과 횟수)",
  "next_focus": "다음 레슨 포커스 (1문장)"
}
''';

      final data = await _callClaude(prompt: prompt, maxTokens: 1500);
      final text = data['content'][0]['text'] as String;

      // JSON 추출 시도
      String jsonStr = text
          .replaceAll(RegExp(r'```json\s*'), '')
          .replaceAll(RegExp(r'```\s*'), '')
          .trim();

      // JSON 객체 부분만 추출 (앞뒤 텍스트 제거)
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(jsonStr);
      if (jsonMatch != null) {
        jsonStr = jsonMatch.group(0)!;
      }

      try {
        return jsonDecode(jsonStr) as Map<String, dynamic>;
      } catch (_) {
        // JSON 파싱 실패 시 기본 구조로 반환
        return {
          'manual_note': text.length > 200 ? text.substring(0, 200) : text,
          'key_points': <String>[],
          'improvements': <String>[],
          'homework': '',
          'next_focus': '',
        };
      }
    } catch (e) {
      throw Exception('AI 노트 생성 실패: $e');
    }
  }

  /// Supabase Edge Function 프록시를 통해 Claude API 호출
  Future<Map<String, dynamic>> _callClaude({
    required String prompt,
    int maxTokens = 500,
  }) async {
    final response = await http.post(
      Uri.parse(_proxyUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_anonKey',
      },
      body: jsonEncode({
        'model': _model,
        'max_tokens': maxTokens,
        'messages': [
          {'role': 'user', 'content': prompt}
        ],
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception('API 키가 유효하지 않습니다');
    } else {
      throw Exception('API 호출 실패: ${response.statusCode} - ${response.body}');
    }
  }

  String _buildSwingAnalysisPrompt(String videoUrl, String? context) {
    return '''
골프 스윙 영상을 분석해주세요.

영상 URL: $videoUrl
${context != null ? '추가 정보: $context' : ''}

다음 항목을 포함하여 분석해주세요:
1. 어드레스 자세
2. 백스윙
3. 다운스윙
4. 임팩트
5. 팔로우스루

각 항목에 대해 장점과 개선점을 제시해주세요.
''';
  }

  String _buildLessonNotePrompt(String studentName, String content, String? improvements) {
    return '''
레슨 노트를 작성해주세요.

학생: $studentName
오늘 레슨 내용: $content
${improvements != null ? '개선 사항: $improvements' : ''}

전문적이고 격려하는 톤으로 작성해주세요.
''';
  }
}
