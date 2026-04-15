# API Integration Patterns

## axios Instance Setup

All API calls must go through the axios instance in `services/api.js`. Direct use of `fetch` is prohibited.

```js
// src/services/api.js
import axios from 'axios'
import { useAuthStore } from '../store/useAuthStore'

const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL || '/api/v1',
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
})

// request interceptor: auto-attach JWT token
api.interceptors.request.use((config) => {
  const token = useAuthStore.getState().token
  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }
  return config
})

// response interceptor: common error handling
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      // token expired → logout
      useAuthStore.getState().logout()
      window.location.href = '/login'
    }
    return Promise.reject(error)
  }
)

export default api
```

## API Function Files (split by domain)

```js
// src/services/userService.js
import api from './api'

export const userService = {
  getAll: (params) => api.get('/users', { params }),
  getById: (id) => api.get(`/users/${id}`),
  create: (data) => api.post('/users', data),
  update: (id, data) => api.patch(`/users/${id}`, data),
  delete: (id) => api.delete(`/users/${id}`),
}
```

## Usage in Custom Hooks

```js
// src/hooks/useCreateUser.js
import { useState } from 'react'
import { userService } from '../services/userService'

export function useCreateUser() {
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState(null)

  const createUser = async (data) => {
    setIsLoading(true)
    setError(null)
    try {
      const { data: newUser } = await userService.create(data)
      return newUser
    } catch (err) {
      const message = err.response?.data?.detail || 'An error occurred'
      setError(message)
      throw err
    } finally {
      setIsLoading(false)
    }
  }

  return { createUser, isLoading, error }
}
```

## Error Message Extraction

Extract messages matching FastAPI's error format:

```js
// src/utils/apiError.js
export function getErrorMessage(error) {
  const detail = error.response?.data?.detail

  // single string error
  if (typeof detail === 'string') return detail

  // Pydantic validation error (array)
  if (Array.isArray(detail)) {
    return detail.map(e => e.msg).join(', ')
  }

  return 'An unknown error occurred'
}
```

## Environment Variables

```
# .env.development
VITE_API_URL=http://localhost:8000/api/v1

# .env.production (or Docker environment)
VITE_API_URL=/api/v1   ← via nginx proxy
```

In Vite, env vars require the `VITE_` prefix. Do not use `process.env` → use `import.meta.env`.
