import { useEffect } from 'react'
import { useQuery } from '@tanstack/react-query'
import { useAuthStore } from '../stores/authStore'
import { authApi } from '../api/auth'

export function useAuth() {
  const { user, isLoading, setUser } = useAuthStore()

  const { data, isLoading: queryLoading } = useQuery({
    queryKey: ['currentUser'],
    queryFn: authApi.getCurrentUser,
    retry: false,
    staleTime: 5 * 60 * 1000,
  })

  useEffect(() => {
    if (data?.authenticated && data.user) {
      setUser(data.user)
    } else if (!queryLoading) {
      setUser(null)
    }
  }, [data, queryLoading, setUser])

  return {
    user,
    isLoading: isLoading || queryLoading,
    isAuthenticated: !!user,
  }
}
