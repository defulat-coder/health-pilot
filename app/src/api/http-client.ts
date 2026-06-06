import axios from 'axios-miniprogram'

// Development default for the local Health Pilot backend. Production builds
// should replace this with the Mini Program request domain.
export const API_BASE_URL = 'http://localhost:7777'

export const httpClient = axios.create({
  baseURL: API_BASE_URL
})

export async function getJson<TResponse>(url: string): Promise<TResponse> {
  const response = await httpClient.get(url)

  return response.data as TResponse
}
