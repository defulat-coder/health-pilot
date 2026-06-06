import { PropsWithChildren } from 'react'
import { QueryClientProvider } from '@tanstack/react-query'
import { useLaunch } from '@tarojs/taro'

import { queryClient } from './query/query-client'
import './app.scss'

function App({ children }: PropsWithChildren<any>) {
  useLaunch(() => {
    console.log('App launched.')
  })

  // children 是将要会渲染的页面
  return <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
}


export default App
