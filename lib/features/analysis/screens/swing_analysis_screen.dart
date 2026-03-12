import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/claude_service.dart';

class SwingAnalysisScreen extends ConsumerStatefulWidget {
  const SwingAnalysisScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SwingAnalysisScreen> createState() => _SwingAnalysisScreenState();
}

class _SwingAnalysisScreenState extends ConsumerState<SwingAnalysisScreen> {
  late final ClaudeService _claudeService;
  bool _isAnalyzing = false;
  String? _analysisResult;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    try {
      _claudeService = ClaudeService();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  Future<void> _testAnalysis() async {
    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
      _analysisResult = null;
    });

    try {
      // 테스트용 분석 요청
      final result = await _claudeService.generateLessonNote(
        studentName: "홍길동",
        lessonContent: "오늘은 백스윙 자세를 중점적으로 연습했습니다.",
        improvements: "탑 포지션에서 오버스윙 교정 필요",
      );

      setState(() {
        _analysisResult = result;
        _isAnalyzing = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isAnalyzing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 스윙 분석'),
        backgroundColor: const Color(0xFF10B981),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '⚠️ API 키 오류',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '해결 방법:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Text('1. .env 파일을 열어주세요'),
                    const Text('2. ANTHROPIC_API_KEY=실제_API_키 형식으로 입력'),
                    const Text('3. API 키는 https://console.anthropic.com 에서 발급'),
                    const Text('4. 앱을 재시작하세요'),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isAnalyzing ? null : _testAnalysis,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isAnalyzing
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'API 테스트',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
            ),
            if (_analysisResult != null) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '✅ API 연결 성공!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Claude API 응답:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(_analysisResult!),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📌 사용 방법',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text('1. 학생의 스윙 영상을 업로드'),
                    Text('2. AI가 자동으로 영상 분석'),
                    Text('3. 어드레스, 백스윙, 임팩트 등 상세 피드백 제공'),
                    Text('4. 개선점과 연습 방법 제안'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}