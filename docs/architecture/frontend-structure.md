# Frontend 구조

## 디렉토리 역할

```
frontend/src/
├── main.jsx          ← React 앱 엔트리포인트 (건드리지 않음)
├── App.jsx           ← 라우터 설정
├── components/       ← 재사용 가능한 UI 컴포넌트
├── pages/            ← 라우트 단위 페이지 컴포넌트
├── hooks/            ← 커스텀 React 훅
├── services/         ← API 클라이언트
├── store/            ← Zustand 전역 상태
└── utils/            ← 순수 함수 유틸리티
```

## 컴포넌트 계층

```
App.jsx (라우터)
└── pages/
    └── UserListPage.jsx
        ├── components/UserCard.jsx     ← 재사용 가능
        ├── components/UserForm.jsx     ← 재사용 가능
        └── hooks/useUsers.js           ← 해당 페이지 전용 훅
```

## 각 디렉토리 규칙

### `pages/`

- 라우트 1개 = 파일 1개
- 페이지 이름: `<도메인>Page.jsx` (예: `UserListPage.jsx`, `LoginPage.jsx`)
- API 호출은 직접 하지 않고 커스텀 훅 위임

```jsx
// pages/UserListPage.jsx
import { useUsers } from '../hooks/useUsers'
import { UserCard } from '../components/UserCard'

export default function UserListPage() {
  const { users, isLoading, error } = useUsers()

  if (isLoading) return <div>로딩 중...</div>
  if (error) return <div>오류: {error.message}</div>

  return (
    <div>
      {users.map(user => <UserCard key={user.id} user={user} />)}
    </div>
  )
}
```

### `components/`

- 재사용 가능한 UI 단위
- props로만 데이터 받음 (API 직접 호출 금지)
- 파일명: PascalCase (`UserCard.jsx`)

```jsx
// components/UserCard.jsx
export function UserCard({ user }) {
  return (
    <div className="user-card">
      <h3>{user.name}</h3>
      <p>{user.email}</p>
    </div>
  )
}
```

### `hooks/`

- API 호출, 상태 관리 로직 담당
- 파일명: camelCase, `use` 접두사 (`useUsers.js`)
- `services/api.js`를 통해 API 호출

```js
// hooks/useUsers.js
import { useState, useEffect } from 'react'
import api from '../services/api'

export function useUsers() {
  const [users, setUsers] = useState([])
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState(null)

  useEffect(() => {
    api.get('/users')
      .then(res => setUsers(res.data))
      .catch(err => setError(err))
      .finally(() => setIsLoading(false))
  }, [])

  return { users, isLoading, error }
}
```

### `services/`

- axios 인스턴스 설정 (`api.js`)
- API 호출 함수 모음 (도메인별 파일 분리 가능)

### `store/`

- Zustand 전역 상태 (로그인 사용자 정보, 토스트 메시지 등)
- 서버 상태(API 데이터)는 훅으로 관리, Zustand는 클라이언트 전용 상태만

## 상태 관리 원칙

```
로컬 UI 상태 (모달 열림/닫힘)  → useState
서버 데이터 (API 응답)          → 커스텀 훅 (useXxx)
전역 클라이언트 상태 (로그인)   → Zustand store
```

→ 상세 결정 기준: [docs/frontend/state-management.md](../frontend/state-management.md)
