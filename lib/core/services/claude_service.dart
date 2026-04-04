import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ClaudeService {
  static const String _model = 'claude-haiku-4-5-20251001';

  late final String _proxyUrl;
  late final String _anonKey;

  ClaudeService() {
    final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
    _anonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
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
    String? lessonType,
    String? previousNotes,
    String? briefInput,
  }) async {
    try {
      final prompt = '''
당신은 골프 레슨프로의 레슨 노트 작성을 도와주는 AI입니다.
아래 정보를 바탕으로 레슨 노트를 작성해주세요.

## 학생 정보
- 이름: $studentName
${studentLevel != null ? '- 레벨: $studentLevel' : ''}
${studentGoal != null ? '- 목표: $studentGoal' : ''}
${lessonType != null ? '- 레슨 타입: $lessonType' : ''}
${previousNotes != null ? '\n## 이전 레슨 기록\n$previousNotes' : ''}
${briefInput != null && briefInput.isNotEmpty ? '\n## 프로의 간단 메모\n$briefInput' : ''}

## 응답 형식
반드시 아래 JSON 형식으로만 응답하세요. 다른 텍스트 없이 JSON만 출력하세요.

{
  "manual_note": "오늘 레슨 내용 요약 (2-3문장)",
  "key_points": ["핵심 포인트 1", "핵심 포인트 2", "핵심 포인트 3"],
  "improvements": ["개선할 점 1", "개선할 점 2"],
  "homework": "다음 레슨까지 연습할 과제",
  "next_focus": "다음 레슨에서 집중할 내용"
}

전문적이면서도 따뜻하고 격려하는 톤으로 작성해주세요.
학생의 레벨과 목표에 맞는 구체적인 내용을 포함하세요.
''';

      final data = await _callClaude(prompt: prompt, maxTokens: 800);
      final text = data['content'][0]['text'] as String;
      final jsonStr = text
          .replaceAll(RegExp(r'```json\s*'), '')
          .replaceAll(RegExp(r'```\s*'), '')
          .trim();
      return jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (e) {
      if (e.toString().contains('FormatException')) {
        throw Exception('AI 응답 형식 오류. 다시 시도해주세요.');
      }
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
