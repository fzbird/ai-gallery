import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import apiClient from '@/api/api.js'
import router from '@/router'

export const useAuthStore = defineStore('auth', () => {
  const token = ref(localStorage.getItem('token') || null)
  const user = ref(JSON.parse(localStorage.getItem('user')) || null)

  const isAuthenticated = computed(() => !!token.value && !!user.value)

  function setToken(newToken) {
    token.value = newToken
    if (newToken) {
      localStorage.setItem('token', newToken)
    } else {
      localStorage.removeItem('token')
    }
  }

  function setUser(newUser) {
    user.value = newUser
    if (newUser) {
      localStorage.setItem('user', JSON.stringify(newUser))
    } else {
      localStorage.removeItem('user')
    }
  }

  async function login(credentials) {
    const params = new URLSearchParams()
    params.append('username', credentials.username)
    params.append('password', credentials.password)
    
    const response = await apiClient.post('/auth/login/access-token', params, {
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
      }
    })
    setToken(response.data.access_token)
    await fetchUser()
    await router.push('/')
  }

  async function register(credentials) {
    await apiClient.post('/users/', credentials)
    // Log in the user after successful registration
    await login({ username: credentials.username, password: credentials.password })
  }

  async function fetchUser() {
    // 如果没有token，直接返回
    if (!token.value) {
      setUser(null)
      return
    }

    try {
      const { data } = await apiClient.get('/users/me')
      setUser(data)
    } catch (error) {
      // 如果是401错误（未认证）或网络错误，清除token和用户信息
      if (error.response?.status === 401 || error.code === 'ERR_NETWORK') {
        setToken(null)
        setUser(null)
      } else {
        // 其他错误只清除用户信息，保留token以便重试
        setUser(null)
        console.error('Failed to fetch user:', error)
      }
    }
  }

  async function changePassword(payload) {
    await apiClient.put('/users/me/password', payload)
  }

  function logout() {
    setToken(null)
    setUser(null)
    router.push('/login')
  }

  // 初始化用户信息（延迟执行，避免在store创建时立即调用API）
  async function initializeAuth() {
    if (token.value) {
      await fetchUser()
    }
  }

  return { token, user, isAuthenticated, login, logout, register, fetchUser, setToken, setUser, changePassword, initializeAuth }
}) 