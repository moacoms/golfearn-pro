import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ClaudeService {
  static const String _baseUrl = 'https://api.anthropic.com/v1';
  static const String _model = 'claude-3-opus-20240229';
  
  late final String _apiKey;

  ClaudeService() {
    // .env 파일에서 API 키 읽기
    _apiKey = dotenv.env['ANTHROPIC_API_KEY'] ?? '';
    if (_apiKey.isEmpty || _apiKey == 'your_claude_api_key_here') {
      throw Exception(
        'Claude API 키가 설정되지 않았습니다.\n'
        '.env 파일에 ANTHROPIC_API_KEY를 설정해주세요.\n'
        'API 키는 https://console.anthropic.com 에서 발급받을 수 있습니다.'
      );
    }
  }

  /// 스윙 분석 요청
  Future<String> analyzeSwing({
    required String videoUrl,
    String? additionalContext,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/messages'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': _model,
          'max_tokens': 1000,
          'messages': [
            {
              'role': 'user',
              'content': _buildSwingAnalysisPrompt(videoUrl, additionalContext),
            }
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['content'][0]['text'];
      } else if (response.statusCode == 401) {
        throw Exception('API 키가 유효하지 않습니다. .env 파일의 ANTHROPIC_API_KEY를 확인해주세요.');
      } else {
        throw Exception('분석 실패: ${response.statusCode} - ${response.body}');
      }
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
      final response = await http.post(
        Uri.parse('$_baseUrl/messages'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': _model,
          'max_tokens': 500,
          'messages': [
            {
              'role': 'user',
              'content': _buildLessonNotePrompt(studentName, lessonContent, improvements),
            }
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['content'][0]['text'];
      } else {
        throw Exception('레슨 노트 생성 실패: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Claude API 호출 실패: $e');
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

      final response = await http.post(
        Uri.parse('$_baseUrl/messages'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': _model,
          'max_tokens': 800,
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['content'][0]['text'] as String;
        // JSON 파싱 (마크다운 코드블록 제거)
        final jsonStr = text
            .replaceAll(RegExp(r'```json\s*'), '')
            .replaceAll(RegExp(r'```\s*'), '')
            .trim();
        return jsonDecode(jsonStr) as Map<String, dynamic>;
      } else if (response.statusCode == 401) {
        throw Exception('API 키가 유효하지 않습니다');
      } else {
        throw Exception('AI 노트 생성 실패: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('FormatException')) {
        throw Exception('AI 응답 형식 오류. 다시 시도해주세요.');
      }
      throw Exception('AI 노트 생성 실패: $e');
    }
  }
}