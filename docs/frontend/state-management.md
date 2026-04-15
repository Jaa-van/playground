# State Management Guide

## State Type Decision Tree

```
What kind of state is it?
│
├── Data from the server (API response)?
│   └── Custom hook (useXxx) → hooks/ directory
│
├── UI state used only within a single component?
│   └── useState
│
└── Client state shared across multiple components?
    └── Zustand store → store/ directory
```

## Custom Hook (server state)

API data is always managed through a custom hook.

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

## useState (local UI state)

```jsx
// modal open/close — local state is appropriate
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

## Zustand (global client state)

State shared across multiple components: logged-in user, toast notifications, etc.

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
    { name: 'auth-storage' }  // persisted in localStorage
  )
)
```

```jsx
// usable anywhere
import { useAuthStore } from '../store/useAuthStore'

function Header() {
  const { user, logout } = useAuthStore()
  return <header>{user ? <button onClick={logout}>Logout</button> : null}</header>
}
```

## Decision Summary

| Situation | Tool |
|-----------|------|
| Modal open/close, form input values | useState |
| API data (list, single resource) | custom hook |
| Logged-in user info | Zustand + persist |
| Toast/notification messages | Zustand |
| Shared filter/sort state across pages | Zustand |
