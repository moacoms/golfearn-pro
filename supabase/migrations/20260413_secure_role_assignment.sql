-- 보안: 회원가입 프로 역할 클라이언트 자가 지정 차단
-- 실행: Supabase 대시보드 → SQL Editor → 아래 전체를 붙여넣고 Run
-- 일자: 2026-04-13

-- =====================================================
-- 1. handle_new_user 트리거: 항상 학생으로 시작
-- =====================================================
-- 클라이언트 metadata의 is_lesson_pro/is_student는 무시.
-- 프로 전환은 별도 경로(레슨프로 전환 페이지)를 통해서만 가능.

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, full_name, is_lesson_pro, is_student, created_at, updated_at)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'full_name', ''),
    false,  -- 강제: 신규 가입은 절대 프로 아님
    true,   -- 강제: 신규 가입은 항상 학생
    now(),
    now()
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

-- 트리거가 이미 있다면 재생성 불필요. 없다면 아래 활성화:
-- drop trigger if exists on_auth_user_created on auth.users;
-- create trigger on_auth_user_created
--   after insert on auth.users
--   for each row execute function public.handle_new_user();

-- =====================================================
-- 2. RLS 정책: profiles 자가 update 시 권한 필드 변경 차단
-- =====================================================
-- 사용자가 자기 profiles 행을 update할 때 is_lesson_pro/is_student를
-- 임의로 바꾸지 못하도록 차단. 프로 전환은 보안 함수로만 가능.

alter table public.profiles enable row level security;

-- 기존 update 정책이 있다면 제거
drop policy if exists "profiles_self_update" on public.profiles;

-- 자기 행만 update 가능하되, 권한 필드는 기존값 유지해야 함
create policy "profiles_self_update"
on public.profiles
for update
using (auth.uid() = id)
with check (
  auth.uid() = id
  and is_lesson_pro = (select is_lesson_pro from public.profiles where id = auth.uid())
  and is_student    = (select is_student    from public.profiles where id = auth.uid())
);

-- 본인 row 조회
drop policy if exists "profiles_self_select" on public.profiles;
create policy "profiles_self_select"
on public.profiles
for select
using (true);  -- 학생이 프로 목록 조회 등이 필요하므로 전체 select 허용

-- =====================================================
-- 3. 프로 전환용 보안 함수 (security definer로 권한 변경 허용)
-- =====================================================
-- 클라이언트는 이 함수만 호출. 함수 내에서 is_lesson_pro=true 설정.
-- 기존 클라이언트 코드(registerAsLessonPro)는 이 함수 호출로 대체 가능.

create or replace function public.promote_to_lesson_pro(
  p_full_name text,
  p_phone text,
  p_introduction text default null,
  p_experience_years int default null
)
returns public.profiles
language plpgsql
security definer
set search_path = public
as $$
declare
  result public.profiles;
begin
  if auth.uid() is null then
    raise exception 'authentication required';
  end if;

  update public.profiles
  set
    full_name = coalesce(p_full_name, full_name),
    pro_phone = coalesce(p_phone, pro_phone),
    pro_introduction = coalesce(p_introduction, pro_introduction),
    pro_experience_years = coalesce(p_experience_years, pro_experience_years),
    is_lesson_pro = true,
    is_student = false,
    updated_at = now()
  where id = auth.uid()
  returning * into result;

  return result;
end;
$$;

-- 인증된 사용자만 호출 가능
revoke all on function public.promote_to_lesson_pro(text, text, text, int) from public;
grant execute on function public.promote_to_lesson_pro(text, text, text, int) to authenticated;
