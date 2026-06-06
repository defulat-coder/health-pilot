import { describe, expect, it } from 'vitest'
import { useAppStore } from '../stores/use-app-store'

describe('useAppStore', () => {
  it('updates and resets the current user id', () => {
    useAppStore.getState().setCurrentUserId('user-123')
    expect(useAppStore.getState().currentUserId).toBe('user-123')

    useAppStore.getState().reset()
    expect(useAppStore.getState().currentUserId).toBe('demo-user')
  })
})
