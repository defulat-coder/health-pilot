import axios from 'axios-miniprogram'

export const API_BASE_URL = 'http://localhost:7777'

export const httpClient = axios.create({
  baseURL: API_BASE_URL
})

export async function getJson<TResponse>(url: string): Promise<TResponse> {
  const response = await httpClient.get<TResponse>(url)

  return response.data
}
