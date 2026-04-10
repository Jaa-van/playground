# API 연동 패턴

## axios 인스턴스 설정

모든 API 호출은 `services/api.js`의 axios 인스턴스를 통해야 합니다. `fetch` 직접 사용 금지.

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

// 요청 인터셉터: JWT 토큰 자동 첨부
api.interceptors.request.use((config) => {
  const token = useAuthStore.getState().token
  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }
  return config
})

// 응답 인터셉터: 공통 에러 처리
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      // 토큰 만료 → 로그아웃
      useAuthStore.getState().logout()
      window.location.href = '/login'
    }
    return Promise.reject(error)
  }
)

export default api
```

## API 함수 파일 (도메인별 분리)

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

## 커스텀 훅에서 사용

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
      const message = err.response?.data?.detail || '오류가 발생했습니다'
      setError(message)
      throw err
    } finally {
      setIsLoading(false)
    }
  }

  return { createUser, isLoading, error }
}
```

## 에러 메시지 추출

FastAPI 에러 형식에 맞게 메시지를 추출합니다:

```js
// src/utils/apiError.js
export function getErrorMessage(error) {
  const detail = error.response?.data?.detail

  // 단일 문자열 에러
  if (typeof detail === 'string') return detail

  // Pydantic 유효성 검사 에러 (배열)
  if (Array.isArray(detail)) {
    return detail.map(e => e.msg).join(', ')
  }

  return '알 수 없는 오류가 발생했습니다'
}
```

## 환경변수

```
# .env.development
VITE_API_URL=http://localhost:8000/api/v1

# .env.production (또는 docker 환경)
VITE_API_URL=/api/v1   ← nginx 프록시 경유
```

Vite에서 환경변수는 `VITE_` 접두사 필수. `process.env` 사용 금지 → `import.meta.env` 사용.
