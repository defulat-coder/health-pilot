import { getJson } from './http-client'
import type { HealthResponse } from '../types/api'

export function getHealth(): Promise<HealthResponse> {
  return getJson<HealthResponse>('/health')
}
