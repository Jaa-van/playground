# React Component Conventions

## File & Directory Naming

| Item | Rule | Example |
|------|------|---------|
| Component file | PascalCase + `.jsx` | `UserCard.jsx` |
| Custom hook file | camelCase + `.js`, `use` prefix | `useUsers.js` |
| Utility function file | camelCase + `.js` | `formatDate.js` |
| Page component | `<Domain>Page.jsx` | `UserListPage.jsx` |
| Store file | `use<Domain>Store.js` | `useAuthStore.js` |

## Component Base Structure

```jsx
// components/UserCard.jsx

// 1. imports (external libraries → internal modules)
import { useState } from 'react'
import { formatDate } from '../utils/formatDate'

// 2. component (named export preferred)
export function UserCard({ user, onEdit }) {
  const [isExpanded, setIsExpanded] = useState(false)

  return (
    <div className="user-card">
      <h3>{user.name}</h3>
      <p>{user.email}</p>
      {isExpanded && <p>Joined: {formatDate(user.created_at)}</p>}
      <button onClick={() => setIsExpanded(!isExpanded)}>
        {isExpanded ? 'Collapse' : 'Show more'}
      </button>
      <button onClick={() => onEdit(user.id)}>Edit</button>
    </div>
  )
}
```

## Props Rules

```jsx
// event handler props use `on` prefix
<UserCard onEdit={handleEdit} onDelete={handleDelete} />

// boolean props stand alone (omit =true)
<UserCard isAdmin />
// same as: <UserCard isAdmin={true} />

// document props with JSDoc (when no TypeScript)
/**
 * @param {{ user: {id: number, name: string, email: string}, onEdit: (id: number) => void }} props
 */
export function UserCard({ user, onEdit }) { ... }
```

## Conditional Rendering

```jsx
// simple show/hide
{isLoading && <Spinner />}

// if/else
{isLoading ? <Spinner /> : <UserList users={users} />}

// complex conditions → extract to variable
const content = (() => {
  if (isLoading) return <Spinner />
  if (error) return <ErrorMessage message={error.message} />
  return <UserList users={users} />
})()

return <div>{content}</div>
```

## List Rendering

```jsx
// always use a stable ID as key (never use index)
{users.map(user => (
  <UserCard key={user.id} user={user} />
))}
```

## Event Handlers

```jsx
// inline functions only for simple cases
<button onClick={() => setIsOpen(true)}>Open</button>

// extract to function when there is logic
function handleSubmit(e) {
  e.preventDefault()
  // logic here
}

<form onSubmit={handleSubmit}>
```

## Prohibited

```jsx
// no console.log in commits
console.log(user)  // ❌

// do not mutate props
props.user.name = "new name"  // ❌

// no direct API calls (use hooks)
fetch('/api/v1/users')  // ❌ in component
```
