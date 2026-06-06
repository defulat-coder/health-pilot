import { create } from 'zustand'

const initialState = {
  currentUserId: 'demo-user'
}

export const useAppStore = create((set) => ({
  ...initialState,
  setCurrentUserId: (currentUserId: string) => {
    set({ currentUserId })
  },
  reset: () => {
    set(initialState)
  }
}))
