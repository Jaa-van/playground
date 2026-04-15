# Harness Upstream Workflow

클론된 프로젝트에서 **harness-template 자체를 개선**하는 방법을 설명합니다.

## 개념

```
harness-template (upstream)
    ↓ clone
my-project (origin)
    ↓ 작업 중 마찰/개선점 발견 → HARNESS_FEEDBACK.md에 기록
    ↓ 프로젝트 마무리 시
    ↓ PR
harness-template ← 개선 반영
    ↓ 다음 프로젝트에 전파
next-project
```

---

## 초기 설정 (클론 직후 1회)

```bash
# harness-template을 upstream remote로 등록
git remote add harness https://github.com/your-username/harness-template.git

# 확인
git remote -v
# origin   https://github.com/your-username/my-project.git
# harness  https://github.com/your-username/harness-template.git
```

---

## harness-template 최신 변경사항 받기

다른 프로젝트에서 harness가 업데이트된 경우:

```bash
git fetch harness main

# 변경된 docs/ 파일만 확인
git diff HEAD harness/main -- docs/ CLAUDE.md

# 필요한 파일만 선택적으로 가져오기
git checkout harness/main -- docs/backend/api-conventions.md
```

> 전체 merge는 하지 않습니다 — harness는 문서/규칙 레이어이고, 프로젝트 코드와 충돌합니다.

---

## 개선사항을 harness-template에 PR 보내기

### 1. HARNESS_FEEDBACK.md 정리

프로젝트 마무리 시 `HARNESS_FEEDBACK.md`의 "Template 수정 제안" 섹션을 검토합니다.

### 2. Lesson 파일 작성

`docs/lessons/` 디렉토리의 템플릿을 복사해 작성합니다:

```bash
cp docs/lessons/LESSON-TEMPLATE.md docs/lessons/LESSON-NNN-<slug>.md
```

### 3. harness-template worktree에서 작업

```bash
# harness-template 로컬 클론이 있는 경우
cd ~/harness-template
git checkout -b lessons/from-my-project

# Lesson 파일 복사
cp ~/my-project/docs/lessons/LESSON-NNN-*.md docs/lessons/

# 해당 docs 파일 수정 (api-conventions.md 등)
# ...

git add docs/lessons/ docs/backend/
git commit -m "docs(lessons): add LESSON-NNN <제목>"
git push origin lessons/from-my-project
# → GitHub에서 PR 오픈
```

---

## Lesson 번호 규칙

`docs/lessons/` 디렉토리의 기존 파일 중 가장 큰 번호 + 1을 사용합니다.

```bash
ls docs/lessons/ | grep -oP 'LESSON-\K\d+' | sort -n | tail -1
```

---

## 언제 PR을 보내야 하는가

| 상황 | 액션 |
|------|------|
| 프로젝트에서 반복적으로 같은 문서를 찾아 헤맸다 | LESSON 작성 + 해당 docs 수정 PR |
| 새로운 패턴을 직접 설계해서 잘 작동했다 | 해당 docs에 패턴 추가 PR |
| Agent가 같은 실수를 두 번 했다 | agent-role.md 또는 CLAUDE.md 수정 PR |
| 스캐폴딩 코드가 부족해서 보일러플레이트를 직접 작성했다 | 스캐폴딩 추가 PR |
