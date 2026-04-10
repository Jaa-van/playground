# 상태 관리 가이드

## 상태 종류와 도구 선택

```
어떤 상태인가?
│
├── 서버에서 오는 데이터 (API 응답)?
│   └── 커스텀 훅 (useXxx) → hooks/ 디렉토리
│
├── 한 컴포넌트 안에서만 쓰는 UI 상태?
│   └── useState
│
└── 여러 컴포넌트가 공유하는 클라이언트 상태?
    └── Zustand store → store/ 디렉토리
```

## 커스텀 훅 (서버 상태)

API 데이터는 항상 커스텀 훅으로 관리합니다.

```js
// hooks/useUsers.js
import { useState, useEffect, useCallback } from 'react'
import api from '../services/api'

export function useUsers() {
  const [users, setUsers] = useState([])
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState(null)

  const fetchUsers = useCallback(async () => {
    setIsLoading(true)
    setError(null)
    try {
      const { data } = await api.get('/users')
      setUsers(data.items)
    } catch (err) {
      setError(err)
    } finally {
      setIsLoading(false)
    }
  }, [])

  useEffect(() => {
    fetchUsers()
  }, [fetchUsers])

  return { users, isLoading, error, refetch: fetchUsers }
}
```

## useState (로컬 UI 상태)

```jsx
// 모달 열림/닫힘 - 로컬 상태 적합
function UserPage() {
  const [isModalOpen, setIsModalOpen] = useState(false)
  const [selectedUser, setSelectedUser] = useState(null)

  return (
    <>
      <UserList onSelect={setSelectedUser} />
      {isModalOpen && <UserEditModal user={selectedUser} />}
    </>
  )
}
```

## Zustand (전역 클라이언트 상태)

로그인 사용자 정보, 토스트 알림 등 여러 컴포넌트에서 공유되는 상태.

```js
// store/useAuthStore.js
import { create } from 'zustand'
import { persist } from 'zustand/middleware'

export const useAuthStore = create(
  persist(
    (set) => ({
      user: null,
      token: null,
      login: (user, token) => set({ user, token }),
      logout: () => set({ user: null, token: null }),
    }),
    { name: 'auth-storage' }  // localStorage에 저장
  )
)
```

```jsx
// 어디서든 사용 가능
import { useAuthStore } from '../store/useAuthStore'

function Header() {
  const { user, logout } = useAuthStore()
  return <header>{user ? <button onClick={logout}>로그아웃</button> : null}</header>
}
```

## 판단 기준 요약

| 상황 | 도구 |
|------|------|
| 모달 열림/닫힘, 폼 입력값 | useState |
| API 데이터 (목록, 단건 조회) | 커스텀 훅 |
| 로그인 사용자 정보 | Zustand + persist |
| 토스트/알림 메시지 | Zustand |
| 페이지 간 공유 필터/정렬 상태 | Zustand |
