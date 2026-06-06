# Taro Miniprogram Frontend Initialization Design

Date: 2026-06-06

## Goal

Initialize the `app/` directory as a WeChat Mini Program frontend for Health Pilot using Taro 4, React 18, TypeScript, and pnpm.

The first version is an engineering template, not a complete business UI. It should compile, provide clear frontend boundaries, and make later feature work straightforward.

## Confirmed Decisions

- Use Taro CLI to generate the base project, then adapt it.
- Use pnpm as the package manager.
- Use React 18 and TypeScript.
- Target WeChat Mini Program as the primary platform.
- Install the requested dependency set.
- Use Zustand as the default state management layer.
- Install Redux Toolkit and Jotai, but do not wire example logic for them.
- Use React Query plus `axios-miniprogram` for API requests.
- Keep business pages lightweight placeholders only.

## Technical Stack

Runtime dependencies:

- `@tarojs/taro`
- `react`
- `react-dom`
- `@nutui/nutui-react-taro`
- `tdesign-mobile-react`
- `zustand`
- `@reduxjs/toolkit`
- `jotai`
- `@tanstack/react-query`
- `axios-miniprogram`
- `@tarojs/router`
- `tarojs-router-next`

Development dependencies:

- `typescript`
- `eslint`
- `@tarojs/eslint-config`
- `prettier`
- `vitest`
- `tailwindcss`

## Architecture

The Taro CLI project will be generated inside `/Users/xbjt/PycharmProjects/health-pilot/app`. After generation, the template will be shaped into this boundary:

```text
app/
  config/
  src/
    app.tsx
    app.config.ts
    app.scss
    pages/
    api/
    query/
    stores/
    router/
    components/
    utils/
    types/
    tests/
```

`src/api/` owns HTTP concerns. It should expose a small API client based on `axios-miniprogram`, with room for base URL configuration and shared error handling.

`src/query/` owns React Query setup. It should export a query client and provider integration so pages can use query hooks without recreating client state.

`src/stores/` owns Zustand stores. The initial store should be minimal, such as app/session UI state, and should not encode backend business rules prematurely.

`src/router/` owns route constants and Taro navigation helpers. Router libraries are installed, but the initial template should avoid complex navigation abstractions until real page flows exist.

`src/pages/` contains only lightweight placeholder pages needed to prove the app boots.

`src/components/`, `src/utils/`, and `src/types/` are reserved for shared frontend code once concrete features are implemented.

## Data Flow

Pages and components should call query hooks or API functions rather than using raw request calls directly.

The intended flow is:

1. Page renders UI and calls a query hook or API helper.
2. React Query manages loading, error, caching, and invalidation state.
3. The API helper calls the shared `axios-miniprogram` client.
4. Shared client code handles base request configuration and common errors.
5. Zustand stores hold local app state that is not server-cache state.

React Query is the default tool for server data. Zustand is the default tool for local client state.

## Error Handling

The initial API client should provide one shared location for request and response error handling. The template does not need full production error UX, but it should make it clear where later code will add:

- Backend base URL selection.
- Auth headers or user identifiers.
- Network error normalization.
- Toast or page-level error presentation.

## Testing

Vitest should be configured with at least a minimal test entry or sample test so the test runner can be validated.

The first implementation should verify:

- pnpm dependency installation succeeds.
- Taro development command is available.
- TypeScript configuration is present.
- ESLint and Prettier configuration exist.
- Vitest can run a minimal test.

## Scope Boundaries

In scope:

- Initialize a Taro 4 React TypeScript project in `app/`.
- Use pnpm.
- Install the requested dependencies.
- Add engineering directories and basic provider wiring.
- Add minimal placeholder page content.
- Add request, query, store, route, lint, format, and test scaffolding.

Out of scope:

- Full Health Pilot product UI.
- Complete chat, meal tracking, weight tracking, exercise tracking, notification, or profile flows.
- Backend API contract changes.
- Authentication design.
- Production deployment setup.

## Risks

Taro CLI output can vary by installed CLI version. The implementation should inspect the generated project and adapt conservatively instead of replacing the whole template.

Some requested dependencies may have peer dependency warnings with Taro 4 or React 18. The implementation should preserve the requested dependency ranges and report any installation warnings that affect usage.

Tailwind CSS 4 may require additional Mini Program-specific integration work. The first version should install and configure it only to the extent that it does not destabilize the Taro build.
