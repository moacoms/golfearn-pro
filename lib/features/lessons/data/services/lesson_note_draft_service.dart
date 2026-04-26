import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// 레슨 노트 폼의 작성 도중 상태를 로컬에 임시 저장.
/// - 신규 작성: `lesson_note_draft_new`
/// - 기존 노트 수정: `lesson_note_draft_edit_{noteId}`
/// 저장 성공 시 호출자가 [clear]로 정리.
class LessonNoteDraftService {
  LessonNoteDraftService._();

  static const _versionKey = '__version';
  static const _currentVersion = 1;

  static const _newKey = 'lesson_note_draft_new';
  static String _editKey(String noteId) => 'lesson_note_draft_edit_$noteId';

  static String _keyFor(String? noteId) =>
      noteId == null ? _newKey : _editKey(noteId);

  static Future<void> save({
    String? noteId,
    required Map<String, dynamic> draft,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = {...draft, _versionKey: _currentVersion};
    await prefs.setString(_keyFor(noteId), jsonEncode(payload));
  }

  static Future<Map<String, dynamic>?> load({String? noteId}) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyFor(noteId));
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      if (decoded[_versionKey] != _currentVersion) return null;
      decoded.remove(_versionKey);
      return decoded;
    } catch (_) {
      return null;
    }
  }

  static Future<void> clear({String? noteId}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyFor(noteId));
  }
}
