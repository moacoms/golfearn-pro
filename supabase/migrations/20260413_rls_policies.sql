-- 보안: 모든 주요 테이블에 RLS 정책 추가
-- 실행: Supabase 대시보드 → SQL Editor → 아래 전체를 붙여넣고 Run
-- 일자: 2026-04-13
--
-- 정책 원칙
-- - pro_id = auth.uid() 이면 프로는 자기 데이터 전권 (select/insert/update/delete)
-- - 학생은 자기와 연결된 row 만 read-only (lesson_students.user_id = auth.uid() 경유)
-- - pro_income_records 는 학생 접근 불필요 → pro 전용
--
-- 사전 조건: lesson_students, lesson_schedules, lesson_packages, lesson_notes,
--            pro_income_records 테이블에 pro_id 컬럼 존재.
--            lesson_students 에는 user_id (auth.users FK, nullable) 컬럼 존재.

-- =====================================================
-- 공통: 기존 정책 제거 헬퍼 (멱등성 확보)
-- =====================================================

-- =====================================================
-- 1. lesson_students
-- =====================================================
alter table public.lesson_students enable row level security;

drop policy if exists "lesson_students_pro_all" on public.lesson_students;
create policy "lesson_students_pro_all"
on public.lesson_students
for all
using (auth.uid() = pro_id)
with check (auth.uid() = pro_id);

drop policy if exists "lesson_students_self_select" on public.lesson_students;
create policy "lesson_students_self_select"
on public.lesson_students
for select
using (auth.uid() = user_id);

-- =====================================================
-- 2. lesson_schedules
-- =====================================================
alter table public.lesson_schedules enable row level security;

drop policy if exists "lesson_schedules_pro_all" on public.lesson_schedules;
create policy "lesson_schedules_pro_all"
on public.lesson_schedules
for all
using (auth.uid() = pro_id)
with check (auth.uid() = pro_id);

drop policy if exists "lesson_schedules_student_select" on public.lesson_schedules;
create policy "lesson_schedules_student_select"
on public.lesson_schedules
for select
using (
  exists (
    select 1
    from public.lesson_students s
    where s.id = lesson_schedules.student_id
      and s.user_id = auth.uid()
  )
);

-- =====================================================
-- 3. lesson_packages
-- =====================================================
alter table public.lesson_packages enable row level security;

drop policy if exists "lesson_packages_pro_all" on public.lesson_packages;
create policy "lesson_packages_pro_all"
on public.lesson_packages
for all
using (auth.uid() = pro_id)
with check (auth.uid() = pro_id);

drop policy if exists "lesson_packages_student_select" on public.lesson_packages;
create policy "lesson_packages_student_select"
on public.lesson_packages
for select
using (
  exists (
    select 1
    from public.lesson_students s
    where s.id = lesson_packages.student_id
      and s.user_id = auth.uid()
  )
);

-- =====================================================
-- 4. lesson_notes
-- =====================================================
alter table public.lesson_notes enable row level security;

drop policy if exists "lesson_notes_pro_all" on public.lesson_notes;
create policy "lesson_notes_pro_all"
on public.lesson_notes
for all
using (auth.uid() = pro_id)
with check (auth.uid() = pro_id);

drop policy if exists "lesson_notes_student_select" on public.lesson_notes;
create policy "lesson_notes_student_select"
on public.lesson_notes
for select
using (
  exists (
    select 1
    from public.lesson_students s
    where s.id = lesson_notes.student_id
      and s.user_id = auth.uid()
  )
);

-- =====================================================
-- 5. pro_income_records (프로 전용)
-- =====================================================
alter table public.pro_income_records enable row level security;

drop policy if exists "pro_income_records_pro_all" on public.pro_income_records;
create policy "pro_income_records_pro_all"
on public.pro_income_records
for all
using (auth.uid() = pro_id)
with check (auth.uid() = pro_id);

-- =====================================================
-- 검증 쿼리 (실행 후 대시보드에서 확인용)
-- =====================================================
-- select schemaname, tablename, policyname, cmd
-- from pg_policies
-- where schemaname = 'public'
--   and tablename in (
--     'lesson_students','lesson_schedules','lesson_packages',
--     'lesson_notes','pro_income_records'
--   )
-- order by tablename, policyname;
