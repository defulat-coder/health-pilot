import { create } from 'zustand'

interface AppState {
  currentUserId: string
  setCurrentUserId: (nextUserId: string) => void
  reset: () => void
}

const initialState = {
  currentUserId: 'demo-user'
}

export const useAppStore = create<AppState>((set) => ({
  ...initialState,
  setCurrentUserId: (currentUserId: string) => {
    set({ currentUserId })
  },
  reset: () => {
    set(initialState)
  }
}))
