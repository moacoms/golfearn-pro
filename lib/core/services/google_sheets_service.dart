import 'dart:convert';
import 'package:http/http.dart' as http;

/// Google Sheets API 연동 서비스
///
/// 사용 전 필요한 설정:
/// 1. Google Cloud Console에서 프로젝트 생성
/// 2. Google Sheets API 활성화
/// 3. 서비스 계정 키 발급 (또는 OAuth 2.0 설정)
/// 4. .env에 GOOGLE_SHEETS_API_KEY, GOOGLE_SHEETS_SPREADSHEET_ID 추가
///
/// 참고: https://developers.google.com/sheets/api/quickstart
class GoogleSheetsService {
  static const String _baseUrl = 'https://sheets.googleapis.com/v4/spreadsheets';

  final String _apiKey;
  final String _spreadsheetId;

  GoogleSheetsService({
    required String apiKey,
    required String spreadsheetId,
  })  : _apiKey = apiKey,
        _spreadsheetId = spreadsheetId;

  /// 수입 기록을 시트에 추가
  Future<void> appendIncomeRecord({
    required DateTime date,
    required String studentName,
    required String category,
    required int amount,
    required String paymentMethod,
    String? description,
  }) async {
    final row = [
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
      studentName,
      category,
      amount.toString(),
      paymentMethod,
      description ?? '',
    ];
    await _appendRow('수입기록', row);
  }

  /// 학생 데이터를 시트에 동기화
  Future<void> syncStudentData(List<Map<String, dynamic>> students) async {
    final rows = students.map((s) => [
      s['student_name'] ?? '',
      s['student_phone'] ?? '',
      s['student_email'] ?? '',
      s['current_level'] ?? '',
      s['total_lesson_count']?.toString() ?? '0',
      s['group_name'] ?? '',
    ]).toList();

    // 헤더 + 데이터
    final allRows = [
      ['이름', '전화번호', '이메일', '레벨', '레슨횟수', '그룹'],
      ...rows,
    ];

    await _updateSheet('학생목록', allRows);
  }

  /// 월간 수입 요약을 시트에 작성
  Future<void> writeMonthlyReport({
    required int year,
    required int month,
    required int totalIncome,
    required int lessonCount,
    required int studentCount,
    required Map<String, int> categoryBreakdown,
    required Map<String, int> paymentBreakdown,
  }) async {
    final sheetName = '${year}년${month}월';
    final rows = [
      ['월간 수입 리포트', '${year}년 ${month}월'],
      [],
      ['총 수입', '$totalIncome원'],
      ['레슨 건수', '${lessonCount}건'],
      ['학생 수', '${studentCount}명'],
      [],
      ['카테고리별 수입'],
      ...categoryBreakdown.entries.map((e) => [e.key, '${e.value}원']),
      [],
      ['결제수단별 수입'],
      ...paymentBreakdown.entries.map((e) => [e.key, '${e.value}원']),
    ];

    await _updateSheet(sheetName, rows);
  }

  /// 시트에 행 추가 (append)
  Future<void> _appendRow(String sheetName, List<String> row) async {
    final url = '$_baseUrl/$_spreadsheetId/values/$sheetName:append'
        '?valueInputOption=USER_ENTERED&key=$_apiKey';

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'values': [row],
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Google Sheets 추가 실패: ${response.statusCode}');
    }
  }

  /// 시트 전체 업데이트 (덮어쓰기)
  Future<void> _updateSheet(String sheetName, List<List<String>> rows) async {
    final url = '$_baseUrl/$_spreadsheetId/values/$sheetName'
        '?valueInputOption=USER_ENTERED&key=$_apiKey';

    final response = await http.put(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'values': rows,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Google Sheets 업데이트 실패: ${response.statusCode}');
    }
  }

  /// 시트 데이터 읽기
  Future<List<List<String>>> readSheet(String sheetName) async {
    final url = '$_baseUrl/$_spreadsheetId/values/$sheetName?key=$_apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final values = data['values'] as List?;
      if (values == null) return [];
      return values.map((row) => (row as List).map((cell) => cell.toString()).toList()).toList();
    } else {
      throw Exception('Google Sheets 읽기 실패: ${response.statusCode}');
    }
  }
}
