# F4 Scope Fidelity Check — Standalone Admin Route

기준 플랜: `.sisyphus/plans/timetable-admin-standalone-route.md`
기준 범위: route composition 수정만 허용

## 검토 방법
- `git diff HEAD~4 --stat`
- `git diff HEAD~4 --name-only`
- 수정 파일별 diff 직접 검토
- Guardrails 재검증(라우터/레이아웃/에디터모드/CRUD/스플래시/멀티미디어-헤더-푸터)

## 수정 파일 목록(전수 검토)
1. `.gitignore`
2. `.sisyphus/drafts/plan-priority-review.md`
3. `.sisyphus/evidence/f1-plan-compliance.md`
4. `.sisyphus/evidence/f2-code-quality.md`
5. `.sisyphus/evidence/f3-manual-qa.md`
6. `.sisyphus/evidence/f4-scope-fidelity.md`
7. `.sisyphus/plans/multimedia-gsheets-dependency-removal.md`
8. `.sisyphus/plans/timetable-data-source-management.md`
9. `coverage/lcov.info`
10. `lib/common/layout/default_layout.dart`
11. `lib/common/util/route/router.dart`
12. `lib/timetable/admin/timetable_admin_screen.dart`
13. `prompts/jank_mitigation_plan.md`
14. `prompts/test_results/adb_shell_top_-H-p.txt` (삭제)
15. `prompts/test_results/dart_devtools_2025-11-26_13_55_10.398.json` (삭제)
16. `prompts/test_results/dart_devtools_2025-11-26_13_59_18.367.json` (삭제)
17. `prompts/test_results/dumpsys_gfxinfo.txt` (삭제)
18. `test/common/util/route/router_timetable_admin_test.dart`
19. `test/timetable/admin/timetable_admin_screen_test.dart`

---

## Guardrails 점검 결과

### 1) ShellRoute 도입 금지
- 결과: **준수**
- 근거: `lib/**`에서 `ShellRoute` 문자열 검색 결과 없음.

### 2) DefaultLayout 전면 개편 금지
- 결과: **준수**
- 근거: `lib/common/layout/default_layout.dart` 변경은 settings 버튼 네비게이션 1건(`go -> push`)만 존재.

### 3) editor mode 규칙(5회 탭, 30분 타이머) 변경 금지
- 결과: **준수**
- 근거: `lib/common/util/app_editor_mode.dart` 변경 없음. 규칙(5 taps, 30min timer) 유지.

### 4) CRUD/validation 비즈니스 로직 변경 금지
- 결과: **준수**
- 근거: `lib/timetable/admin/timetable_admin_screen.dart` 변경은 AppBar 뒤로가기(leading) 추가 + `go_router` import + no-op `dispose` 추가에 한정. CRUD/validation 메서드 본문 변경 없음.

### 5) `/home`, `/test`는 기존처럼 DefaultLayout 유지
- 결과: **준수**
- 근거: `lib/common/util/route/router.dart`에서 `/home`, `/test` builder는 `DefaultLayout(...)` 그대로 유지.

### 6) multimedia/header/footer 레이아웃 변경 금지
- 결과: **준수**
- 근거: `git diff HEAD~4 -- lib/multimedia lib/header lib/footer` 결과 변경 없음.

### 7) SplashScreen 동작 변경 금지
- 결과: **준수**
- 근거: `lib/common/view/splash_screen.dart` 변경 없음. 라우터 내 `/`, `/reinit`, `/splash`도 기존 구성 유지.

---

## 승인 범위 적합성(핵심)
- `router.dart`: `/admin/timetable`만 `DefaultLayout(midChild: TimetableAdminScreen())` → `const TimetableAdminScreen()`으로 변경됨.
- `default_layout.dart`: 숨김 settings 버튼만 `context.push('/admin/timetable')`로 변경됨.
- `timetable_admin_screen.dart`: 안전한 뒤로가기(pop 우선, 불가 시 `/home`) 추가됨.

위 3건은 모두 승인된 route composition 범위 안의 변경이다.

## 최종 판정

**VERDICT: scope-clean**

추가 remediation 필요 없음.
