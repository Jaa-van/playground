# React 컴포넌트 규칙

## 파일 & 디렉토리 명명

| 항목 | 규칙 | 예시 |
|------|------|------|
| 컴포넌트 파일 | PascalCase + `.jsx` | `UserCard.jsx` |
| 커스텀 훅 파일 | camelCase + `.js`, `use` 접두사 | `useUsers.js` |
| 유틸 함수 파일 | camelCase + `.js` | `formatDate.js` |
| 페이지 컴포넌트 | `<도메인>Page.jsx` | `UserListPage.jsx` |
| 스토어 파일 | `use<도메인>Store.js` | `useAuthStore.js` |

## 컴포넌트 기본 구조

```jsx
// components/UserCard.jsx

// 1. import (외부 라이브러리 → 내부 모듈 순서)
import { useState } from 'react'
import { formatDate } from '../utils/formatDate'

// 2. 컴포넌트 (named export 권장)
export function UserCard({ user, onEdit }) {
  const [isExpanded, setIsExpanded] = useState(false)

  return (
    <div className="user-card">
      <h3>{user.name}</h3>
      <p>{user.email}</p>
      {isExpanded && <p>가입일: {formatDate(user.created_at)}</p>}
      <button onClick={() => setIsExpanded(!isExpanded)}>
        {isExpanded ? '접기' : '더보기'}
      </button>
      <button onClick={() => onEdit(user.id)}>수정</button>
    </div>
  )
}
```

## Props 규칙

```jsx
// 이벤트 핸들러 props는 on 접두사
<UserCard onEdit={handleEdit} onDelete={handleDelete} />

// boolean props는 단독으로 (=true 생략)
<UserCard isAdmin />
// 동일: <UserCard isAdmin={true} />

// JSDoc으로 props 문서화 (TypeScript 없을 때)
/**
 * @param {{ user: {id: number, name: string, email: string}, onEdit: (id: number) => void }} props
 */
export function UserCard({ user, onEdit }) { ... }
```

## 조건부 렌더링

```jsx
// 단순 show/hide
{isLoading && <Spinner />}

// if/else
{isLoading ? <Spinner /> : <UserList users={users} />}

// 복잡한 조건 → 변수로 분리
const content = (() => {
  if (isLoading) return <Spinner />
  if (error) return <ErrorMessage message={error.message} />
  return <UserList users={users} />
})()

return <div>{content}</div>
```

## 리스트 렌더링

```jsx
// key는 항상 안정적인 ID 사용 (index 사용 금지)
{users.map(user => (
  <UserCard key={user.id} user={user} />
))}
```

## 이벤트 핸들러

```jsx
// 인라인 함수는 단순한 경우만
<button onClick={() => setIsOpen(true)}>열기</button>

// 로직이 있으면 함수로 분리
function handleSubmit(e) {
  e.preventDefault()
  // 처리 로직
}

<form onSubmit={handleSubmit}>
```

## 금지 사항

```jsx
// console.log 커밋 금지
console.log(user)  // ❌

// props 직접 변경 금지
props.user.name = "새이름"  // ❌

// 직접 API 호출 금지 (훅을 통해)
fetch('/api/v1/users')  // ❌ in component
```
