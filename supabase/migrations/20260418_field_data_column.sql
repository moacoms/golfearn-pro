-- 필드 레슨 노트: 홀별 샷 데이터를 JSONB로 저장
-- 실행: Supabase Dashboard → SQL Editor → 전체 붙여넣기 → Run
-- 일자: 2026-04-18

ALTER TABLE lesson_notes ADD COLUMN IF NOT EXISTS field_data JSONB DEFAULT NULL;

-- field_data가 NULL이면 일반 노트, 값이 있으면 필드 레슨 노트.
-- JSON 구조: { course_type, course_name, total_score, total_putts,
--              routine_check, review_notes, holes: [...] }
