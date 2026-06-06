# Taro Miniprogram Frontend Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Initialize `/Users/xbjt/PycharmProjects/health-pilot/app` as a pnpm-managed Taro 4 React TypeScript WeChat Mini Program engineering template.

**Architecture:** Generate the base project with Taro CLI, then adapt the generated files conservatively. React Query owns server state, `axios-miniprogram` owns HTTP transport, and Zustand owns local client state. Redux Toolkit and Jotai are installed but not wired into template behavior.

**Tech Stack:** Taro 4, React 18, TypeScript 5, pnpm, NutUI React Taro, TDesign Mobile React, Zustand, React Query 5, axios-miniprogram, Vitest, ESLint, Prettier, Tailwind CSS 4.

---

## File Structure

- Create or regenerate: `/Users/xbjt/PycharmProjects/health-pilot/app/package.json`
  - Owns scripts, dependencies, devDependencies, package manager metadata.
- Create or regenerate: `/Users/xbjt/PycharmProjects/health-pilot/app/config/index.ts`
  - Owns Taro project configuration.
- Create or regenerate: `/Users/xbjt/PycharmProjects/health-pilot/app/config/dev.ts`
  - Owns development config overrides.
- Create or regenerate: `/Users/xbjt/PycharmProjects/health-pilot/app/config/prod.ts`
  - Owns production config overrides.
- Create or regenerate: `/Users/xbjt/PycharmProjects/health-pilot/app/project.config.json`
  - Owns WeChat Mini Program project metadata.
- Create or regenerate: `/Users/xbjt/PycharmProjects/health-pilot/app/tsconfig.json`
  - Owns TypeScript compiler configuration.
- Create: `/Users/xbjt/PycharmProjects/health-pilot/app/.eslintrc.cjs`
  - Owns ESLint configuration for Taro and TypeScript source files.
- Create: `/Users/xbjt/PycharmProjects/health-pilot/app/prettier.config.cjs`
  - Owns formatting rules.
- Create: `/Users/xbjt/PycharmProjects/health-pilot/app/vitest.config.ts`
  - Owns unit test configuration.
- Create: `/Users/xbjt/PycharmProjects/health-pilot/app/src/app.tsx`
  - Owns app-level providers and global bootstrapping.
- Create: `/Users/xbjt/PycharmProjects/health-pilot/app/src/app.config.ts`
  - Owns Taro page registration and window defaults.
- Create: `/Users/xbjt/PycharmProjects/health-pilot/app/src/app.scss`
  - Owns global styles.
- Create: `/Users/xbjt/PycharmProjects/health-pilot/app/src/pages/index/index.tsx`
  - Owns the initial boot page.
- Create: `/Users/xbjt/PycharmProjects/health-pilot/app/src/pages/index/index.config.ts`
  - Owns the initial page navigation title.
- Create: `/Users/xbjt/PycharmProjects/health-pilot/app/src/pages/index/index.scss`
  - Owns initial page styles.
- Create: `/Users/xbjt/PycharmProjects/health-pilot/app/src/api/http-client.ts`
  - Owns `axios-miniprogram` client creation and request helpers.
- Create: `/Users/xbjt/PycharmProjects/health-pilot/app/src/api/health.ts`
  - Owns the initial backend health-check API helper.
- Create: `/Users/xbjt/PycharmProjects/health-pilot/app/src/query/query-client.ts`
  - Owns shared React Query client creation.
- Create: `/Users/xbjt/PycharmProjects/health-pilot/app/src/query/use-health-query.ts`
  - Owns the initial query hook example.
- Create: `/Users/xbjt/PycharmProjects/health-pilot/app/src/stores/use-app-store.ts`
  - Owns the minimal Zustand app state store.
- Create: `/Users/xbjt/PycharmProjects/health-pilot/app/src/router/routes.ts`
  - Owns route constants and navigation helpers.
- Create: `/Users/xbjt/PycharmProjects/health-pilot/app/src/types/api.ts`
  - Owns shared API response types.
- Create: `/Users/xbjt/PycharmProjects/health-pilot/app/src/tests/app-store.test.ts`
  - Owns a minimal Vitest test for the Zustand store.

## Task 1: Generate Taro Template

**Files:**
- Create or regenerate: `/Users/xbjt/PycharmProjects/health-pilot/app/package.json`
- Create or regenerate: `/Users/xbjt/PycharmProjects/health-pilot/app/config/index.ts`
- Create or regenerate: `/Users/xbjt/PycharmProjects/health-pilot/app/config/dev.ts`
- Create or regenerate: `/Users/xbjt/PycharmProjects/health-pilot/app/config/prod.ts`
- Create or regenerate: `/Users/xbjt/PycharmProjects/health-pilot/app/project.config.json`
- Create or regenerate: `/Users/xbjt/PycharmProjects/health-pilot/app/src/app.tsx`
- Create or regenerate: `/Users/xbjt/PycharmProjects/health-pilot/app/src/app.config.ts`
- Create or regenerate: `/Users/xbjt/PycharmProjects/health-pilot/app/src/pages/index/index.tsx`

- [ ] **Step 1: Confirm `app/` has no source files to preserve**

Run:

```bash
find /Users/xbjt/PycharmProjects/health-pilot/app -maxdepth 2 -type f -print | sort
```

Expected output contains only `.DS_Store` or no files. If any source files appear, stop and inspect them before generating.

- [ ] **Step 2: Generate a Taro 4 React TypeScript template**

Run:

```bash
cd /Users/xbjt/PycharmProjects/health-pilot
rm -rf /tmp/health-pilot-taro-template
pnpm dlx @tarojs/cli@4 init health-pilot-taro-template --typescript --template default --framework react
```

Expected: Taro CLI creates `/tmp/health-pilot-taro-template` or prompts for equivalent React TypeScript defaults. If the CLI prompts for package manager, choose `pnpm`. If the CLI prompts for CSS preprocessor, choose Sass/SCSS.

- [ ] **Step 3: Copy generated template into `app/`**

Run:

```bash
rsync -a --exclude .git --exclude node_modules --exclude dist /tmp/health-pilot-taro-template/ /Users/xbjt/PycharmProjects/health-pilot/app/
```

Expected: `/Users/xbjt/PycharmProjects/health-pilot/app/package.json` and `/Users/xbjt/PycharmProjects/health-pilot/app/src/app.tsx` exist.

- [ ] **Step 4: Inspect generated files**

Run:

```bash
find /Users/xbjt/PycharmProjects/health-pilot/app -maxdepth 3 -type f -print | sort | sed -n '1,160p'
```

Expected: Taro config files, package manifest, and source files are present.

## Task 2: Pin Package Scripts and Dependencies

**Files:**
- Modify: `/Users/xbjt/PycharmProjects/health-pilot/app/package.json`

- [ ] **Step 1: Replace `package.json` with the required dependency surface**

Write `/Users/xbjt/PycharmProjects/health-pilot/app/package.json`:

```json
{
  "name": "health-pilot-miniprogram",
  "version": "0.1.0",
  "private": true,
  "description": "Health Pilot WeChat Mini Program frontend",
  "packageManager": "pnpm@9.0.0",
  "scripts": {
    "build:weapp": "taro build --type weapp",
    "dev:weapp": "taro build --type weapp --watch",
    "lint": "eslint \"src/**/*.{ts,tsx}\"",
    "format": "prettier --write .",
    "format:check": "prettier --check .",
    "test": "vitest run",
    "test:watch": "vitest"
  },
  "dependencies": {
    "@reduxjs/toolkit": "^2.0.0",
    "@tanstack/react-query": "^5.0.0",
    "@tarojs/router": "^4.0.0",
    "@tarojs/taro": "^4.0.0",
    "@nutui/nutui-react-taro": "^3.0.0",
    "axios-miniprogram": "^1.0.0",
    "jotai": "^2.0.0",
    "react": "^18.0.0",
    "react-dom": "^18.0.0",
    "tarojs-router-next": "^4.0.0",
    "tdesign-mobile-react": "^1.0.0",
    "zustand": "^5.0.0"
  },
  "devDependencies": {
    "@tarojs/cli": "^4.0.0",
    "@tarojs/eslint-config": "^4.0.0",
    "@types/react": "^18.0.0",
    "@types/react-dom": "^18.0.0",
    "eslint": "^9.0.0",
    "prettier": "^3.0.0",
    "tailwindcss": "^4.0.0",
    "typescript": "^5.0.0",
    "vitest": "^2.0.0"
  }
}
```

- [ ] **Step 2: Install dependencies**

Run:

```bash
cd /Users/xbjt/PycharmProjects/health-pilot/app
pnpm install
```

Expected: `pnpm-lock.yaml` is created. Record any peer dependency warnings in the final implementation notes.

## Task 3: Configure Tooling

**Files:**
- Create or modify: `/Users/xbjt/PycharmProjects/health-pilot/app/.eslintrc.cjs`
- Create or modify: `/Users/xbjt/PycharmProjects/health-pilot/app/prettier.config.cjs`
- Create or modify: `/Users/xbjt/PycharmProjects/health-pilot/app/vitest.config.ts`
- Modify: `/Users/xbjt/PycharmProjects/health-pilot/app/tsconfig.json`

- [ ] **Step 1: Add ESLint configuration**

Write `/Users/xbjt/PycharmProjects/health-pilot/app/.eslintrc.cjs`:

```js
module.exports = {
  root: true,
  extends: ['taro/react'],
  parserOptions: {
    ecmaVersion: 'latest',
    sourceType: 'module'
  },
  rules: {
    'react/react-in-jsx-scope': 'off'
  }
}
```

- [ ] **Step 2: Add Prettier configuration**

Write `/Users/xbjt/PycharmProjects/health-pilot/app/prettier.config.cjs`:

```js
module.exports = {
  printWidth: 100,
  singleQuote: true,
  semi: false,
  trailingComma: 'none'
}
```

- [ ] **Step 3: Add Vitest configuration**

Write `/Users/xbjt/PycharmProjects/health-pilot/app/vitest.config.ts`:

```ts
import { defineConfig } from 'vitest/config'

export default defineConfig({
  test: {
    environment: 'node',
    include: ['src/tests/**/*.test.ts']
  }
})
```

- [ ] **Step 4: Ensure TypeScript includes source files**

Update `/Users/xbjt/PycharmProjects/health-pilot/app/tsconfig.json` so it includes this shape while preserving Taro-generated compiler options that are still needed:

```json
{
  "compilerOptions": {
    "target": "ES2017",
    "module": "ESNext",
    "moduleResolution": "Bundler",
    "jsx": "react-jsx",
    "strict": true,
    "baseUrl": ".",
    "paths": {
      "@/*": ["src/*"]
    },
    "allowSyntheticDefaultImports": true,
    "esModuleInterop": true,
    "resolveJsonModule": true,
    "skipLibCheck": true,
    "noEmit": true
  },
  "include": ["src", "config", "types"],
  "exclude": ["node_modules", "dist"]
}
```

## Task 4: Add App Providers

**Files:**
- Modify: `/Users/xbjt/PycharmProjects/health-pilot/app/src/app.tsx`
- Modify: `/Users/xbjt/PycharmProjects/health-pilot/app/src/app.config.ts`
- Modify: `/Users/xbjt/PycharmProjects/health-pilot/app/src/app.scss`
- Create: `/Users/xbjt/PycharmProjects/health-pilot/app/src/query/query-client.ts`

- [ ] **Step 1: Create React Query client**

Write `/Users/xbjt/PycharmProjects/health-pilot/app/src/query/query-client.ts`:

```ts
import { QueryClient } from '@tanstack/react-query'

export const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      retry: 1,
      staleTime: 30_000
    }
  }
})
```

- [ ] **Step 2: Wire the app provider**

Write `/Users/xbjt/PycharmProjects/health-pilot/app/src/app.tsx`:

```tsx
import { PropsWithChildren } from 'react'
import { QueryClientProvider } from '@tanstack/react-query'
import { queryClient } from './query/query-client'
import './app.scss'

export default function App({ children }: PropsWithChildren) {
  return <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
}
```

- [ ] **Step 3: Register the initial page**

Write `/Users/xbjt/PycharmProjects/health-pilot/app/src/app.config.ts`:

```ts
export default defineAppConfig({
  pages: ['pages/index/index'],
  window: {
    backgroundTextStyle: 'light',
    navigationBarBackgroundColor: '#0f766e',
    navigationBarTitleText: 'Health Pilot',
    navigationBarTextStyle: 'white'
  }
})
```

- [ ] **Step 4: Add global styles**

Write `/Users/xbjt/PycharmProjects/health-pilot/app/src/app.scss`:

```scss
page {
  min-height: 100%;
  background: #f6f8f7;
  color: #17211f;
  font-family:
    -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
}
```

## Task 5: Add API, Query, Store, Router, and Types

**Files:**
- Create: `/Users/xbjt/PycharmProjects/health-pilot/app/src/api/http-client.ts`
- Create: `/Users/xbjt/PycharmProjects/health-pilot/app/src/api/health.ts`
- Create: `/Users/xbjt/PycharmProjects/health-pilot/app/src/query/use-health-query.ts`
- Create: `/Users/xbjt/PycharmProjects/health-pilot/app/src/stores/use-app-store.ts`
- Create: `/Users/xbjt/PycharmProjects/health-pilot/app/src/router/routes.ts`
- Create: `/Users/xbjt/PycharmProjects/health-pilot/app/src/types/api.ts`

- [ ] **Step 1: Add shared API types**

Write `/Users/xbjt/PycharmProjects/health-pilot/app/src/types/api.ts`:

```ts
export interface HealthResponse {
  status: string
}
```

- [ ] **Step 2: Add HTTP client**

Write `/Users/xbjt/PycharmProjects/health-pilot/app/src/api/http-client.ts`:

```ts
import axios from 'axios-miniprogram'

export const API_BASE_URL = 'http://localhost:7777'

export const httpClient = axios.create({
  baseURL: API_BASE_URL,
  timeout: 15_000
})

export async function getJson<TResponse>(url: string): Promise<TResponse> {
  const response = await httpClient.get<TResponse>(url)
  return response.data
}
```

- [ ] **Step 3: Add health API helper**

Write `/Users/xbjt/PycharmProjects/health-pilot/app/src/api/health.ts`:

```ts
import { getJson } from './http-client'
import { HealthResponse } from '../types/api'

export function getHealth(): Promise<HealthResponse> {
  return getJson<HealthResponse>('/health')
}
```

- [ ] **Step 4: Add health query hook**

Write `/Users/xbjt/PycharmProjects/health-pilot/app/src/query/use-health-query.ts`:

```ts
import { useQuery } from '@tanstack/react-query'
import { getHealth } from '../api/health'

export function useHealthQuery() {
  return useQuery({
    queryKey: ['health'],
    queryFn: getHealth
  })
}
```

- [ ] **Step 5: Add Zustand app store**

Write `/Users/xbjt/PycharmProjects/health-pilot/app/src/stores/use-app-store.ts`:

```ts
import { create } from 'zustand'

interface AppState {
  currentUserId: string
  setCurrentUserId: (userId: string) => void
  reset: () => void
}

const initialState = {
  currentUserId: 'demo-user'
}

export const useAppStore = create<AppState>((set) => ({
  ...initialState,
  setCurrentUserId: (userId) => set({ currentUserId: userId }),
  reset: () => set(initialState)
}))
```

- [ ] **Step 6: Add route helpers**

Write `/Users/xbjt/PycharmProjects/health-pilot/app/src/router/routes.ts`:

```ts
import Taro from '@tarojs/taro'

export const routes = {
  home: '/pages/index/index'
} as const

export type AppRoute = (typeof routes)[keyof typeof routes]

export function navigateTo(route: AppRoute) {
  return Taro.navigateTo({ url: route })
}
```

## Task 6: Add Initial Page

**Files:**
- Create or modify: `/Users/xbjt/PycharmProjects/health-pilot/app/src/pages/index/index.tsx`
- Create or modify: `/Users/xbjt/PycharmProjects/health-pilot/app/src/pages/index/index.config.ts`
- Create or modify: `/Users/xbjt/PycharmProjects/health-pilot/app/src/pages/index/index.scss`

- [ ] **Step 1: Add page config**

Write `/Users/xbjt/PycharmProjects/health-pilot/app/src/pages/index/index.config.ts`:

```ts
export default definePageConfig({
  navigationBarTitleText: 'Health Pilot'
})
```

- [ ] **Step 2: Add page component**

Write `/Users/xbjt/PycharmProjects/health-pilot/app/src/pages/index/index.tsx`:

```tsx
import { View, Text } from '@tarojs/components'
import { useAppStore } from '../../stores/use-app-store'
import './index.scss'

export default function IndexPage() {
  const currentUserId = useAppStore((state) => state.currentUserId)

  return (
    <View className='home-page'>
      <View className='home-page__header'>
        <Text className='home-page__eyebrow'>Health Pilot</Text>
        <Text className='home-page__title'>AI 健康教练前端模板</Text>
        <Text className='home-page__body'>
          当前用户：{currentUserId}。项目已预留 API、React Query、Zustand、路由、测试和工具链边界。
        </Text>
      </View>
    </View>
  )
}
```

- [ ] **Step 3: Add page styles**

Write `/Users/xbjt/PycharmProjects/health-pilot/app/src/pages/index/index.scss`:

```scss
.home-page {
  min-height: 100vh;
  box-sizing: border-box;
  padding: 40px 28px;
}

.home-page__header {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.home-page__eyebrow {
  color: #0f766e;
  font-size: 24px;
  font-weight: 700;
}

.home-page__title {
  color: #17211f;
  font-size: 42px;
  font-weight: 700;
  line-height: 1.2;
}

.home-page__body {
  color: #53615e;
  font-size: 28px;
  line-height: 1.6;
}
```

## Task 7: Add Minimal Unit Test

**Files:**
- Create: `/Users/xbjt/PycharmProjects/health-pilot/app/src/tests/app-store.test.ts`

- [ ] **Step 1: Add Zustand store test**

Write `/Users/xbjt/PycharmProjects/health-pilot/app/src/tests/app-store.test.ts`:

```ts
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
```

- [ ] **Step 2: Run unit tests**

Run:

```bash
cd /Users/xbjt/PycharmProjects/health-pilot/app
pnpm test
```

Expected: Vitest reports one passing test.

## Task 8: Verify Build, Lint, and Format

**Files:**
- Verify: `/Users/xbjt/PycharmProjects/health-pilot/app`

- [ ] **Step 1: Run lint**

Run:

```bash
cd /Users/xbjt/PycharmProjects/health-pilot/app
pnpm lint
```

Expected: ESLint exits successfully. If ESLint 9 rejects `.eslintrc.cjs`, add `eslint.config.mjs` with equivalent Taro-compatible configuration and rerun.

- [ ] **Step 2: Run format check**

Run:

```bash
cd /Users/xbjt/PycharmProjects/health-pilot/app
pnpm format:check
```

Expected: Prettier exits successfully. If it reports formatting differences, run `pnpm format` and rerun `pnpm format:check`.

- [ ] **Step 3: Run WeChat Mini Program build**

Run:

```bash
cd /Users/xbjt/PycharmProjects/health-pilot/app
pnpm build:weapp
```

Expected: Taro creates a WeChat Mini Program build output under `dist/`.

- [ ] **Step 4: Inspect final git status**

Run:

```bash
cd /Users/xbjt/PycharmProjects/health-pilot
git status --short app docs/superpowers/plans/2026-06-06-taro-miniprogram-frontend.md
```

Expected: Only the new frontend project files, pnpm lockfile, and implementation plan are shown for this task.

## Self-Review

- Spec coverage: The plan covers Taro CLI generation, pnpm, required dependencies, Zustand default state, React Query plus `axios-miniprogram`, router helpers, lightweight placeholder page, tooling, and verification.
- Placeholder scan: No task uses placeholder tokens or vague implementation-only wording.
- Type consistency: API response, store state, query hook, and page imports are consistently named across tasks.
