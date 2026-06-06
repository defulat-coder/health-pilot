import Taro from '@tarojs/taro'

export const routes = {
  home: '/pages/index/index'
} as const

export type AppRoute = (typeof routes)[keyof typeof routes]

export function navigateTo(route: AppRoute) {
  return Taro.navigateTo({ url: route })
}
