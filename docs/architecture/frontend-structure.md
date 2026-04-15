# Frontend Structure

## Directory Roles

```
frontend/src/
├── main.jsx          ← React app entry point (do not modify)
├── App.jsx           ← router configuration
├── components/       ← reusable UI components
├── pages/            ← route-level page components
├── hooks/            ← custom React hooks
├── services/         ← API client
├── store/            ← Zustand global state
└── utils/            ← pure utility functions
```

## Component Hierarchy

```
App.jsx (router)
└── pages/
    └── UserListPage.jsx
        ├── components/UserCard.jsx     ← reusable
        ├── components/UserForm.jsx     ← reusable
        └── hooks/useUsers.js           ← page-specific hook
```

## Directory Rules

### `pages/`

- One route = one file
- Page naming: `<Domain>Page.jsx` (e.g. `UserListPage.jsx`, `LoginPage.jsx`)
- Do not call APIs directly — delegate to custom hooks

```jsx
// pages/UserListPage.jsx
import { useUsers } from '../hooks/useUsers'
import { UserCard } from '../components/UserCard'

export default function UserListPage() {
  const { users, isLoading, error } = useUsers()

  if (isLoading) return <div>Loading...</div>
  if (error) return <div>Error: {error.message}</div>

  return (
    <div>
      {users.map(user => <UserCard key={user.id} user={user} />)}
    </div>
  )
}
```

### `components/`

- Reusable UI units
- Receive data through props only (no direct API calls)
- Filename: PascalCase (`UserCard.jsx`)

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

- Owns API call and state management logic
- Filename: camelCase, `use` prefix (`useUsers.js`)
- Makes API calls through `services/api.js`

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

- axios instance configuration (`api.js`)
- API call functions (can be split by domain)

### `store/`

- Zustand global state (logged-in user info, toast messages, etc.)
- Server state (API data) is managed in hooks; Zustand is for client-only state

## State Management Principles

```
Local UI state (modal open/close)     → useState
Server data (API responses)           → custom hook (useXxx)
Global client state (login)           → Zustand store
```

→ Detailed decision criteria: [docs/frontend/state-management.md](../frontend/state-management.md)
