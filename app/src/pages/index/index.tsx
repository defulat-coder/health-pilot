import { useMemo, useState } from 'react'
import { Input, ScrollView, Text, View } from '@tarojs/components'
import './index.scss'

type TabKey = 'chat' | 'tasks' | 'insights' | 'care'
type MessageRole = 'coach' | 'user' | 'system'
type OnboardingField = 'height' | 'weight' | 'age' | 'activity' | 'target'

interface ChatMessage {
  id: number
  role: MessageRole
  text: string
  meta?: string
}

interface NotificationItem {
  id: number
  triggerName: string
  title: string
  content: string
  time: string
  delivered: boolean
}

interface DayStats {
  calories: number
  protein: number
  exercise: number
  weight: number
  targetCalories: number
  targetProtein: number
}

interface MealRecord {
  name: string
  calories: number
  protein: number
  time: string
}

const tabs: Array<{ key: TabKey; label: string; icon: string }> = [
  { key: 'chat', label: '教练', icon: '✦' },
  { key: 'tasks', label: '办事', icon: '▦' },
  { key: 'insights', label: '数据', icon: '⌁' },
  { key: 'care', label: '关怀', icon: '◌' }
]

const quickPrompts = [
  '我刚吃了一碗黄焖鸡米饭',
  '今天蛋白质还差多少？',
  '帮我做3天备餐计划',
  '我刚跑步35分钟'
]

const healthTasks = [
  { title: '记饮食', hint: '自然语言估算热量', icon: '🍽', accent: 'rose' },
  { title: '拍照识别', hint: '食物/菜单/体重秤', icon: '◉', accent: 'cyan' },
  { title: '记体重', hint: '体重与体脂趋势', icon: '⌁', accent: 'blue' },
  { title: '记运动', hint: '时长与消耗', icon: '↗', accent: 'green' },
  { title: '今日总结', hint: '摄入/运动/缺口', icon: '▤', accent: 'amber' },
  { title: '蛋白进度', hint: '按体重算目标', icon: '◇', accent: 'violet' },
  { title: '体重趋势', hint: '7日移动均值', icon: '〰', accent: 'slate' },
  { title: '备餐计划', hint: '食谱与购物清单', icon: '☷', accent: 'orange' },
  { title: '推送设置', hint: '提醒时间与触发器', icon: '◷', accent: 'pink' }
]

const onboardingSteps: Array<{ key: OnboardingField; label: string; value: string }> = [
  { key: 'height', label: '身高', value: '168cm' },
  { key: 'weight', label: '当前体重', value: '68.4kg' },
  { key: 'age', label: '年龄', value: '29岁' },
  { key: 'activity', label: '活动量', value: '轻度活动' },
  { key: 'target', label: '目标', value: '62kg / 每周0.5kg' }
]

const initialMessages: ChatMessage[] = [
  {
    id: 1,
    role: 'coach',
    text: '你好，我是 Health Pilot。先帮你把今天的饮食、运动和体重串起来，记录时直接说就行。',
    meta: '基于 Health Coach Agent'
  },
  {
    id: 2,
    role: 'system',
    text: '当前档案已建立：TDEE 1840kcal，蛋白目标 109g。今天还剩 910kcal。'
  }
]

const initialNotifications: NotificationItem[] = [
  {
    id: 11,
    triggerName: 'protein_low',
    title: '蛋白质补足',
    content: '晚餐前蛋白质还差 44g，可以优先选鸡胸、虾仁、豆腐或无糖酸奶。',
    time: '18:20',
    delivered: false
  },
  {
    id: 12,
    triggerName: 'calorie_high',
    title: '热量预警',
    content: '今天已摄入接近目标 90%，宵夜建议控制在 180kcal 内。',
    time: '16:48',
    delivered: false
  },
  {
    id: 13,
    triggerName: 'weekly_report',
    title: '周报已生成',
    content: '本周记录 17 餐，平均蛋白达成 82%。周末可以补一次力量训练。',
    time: '周日',
    delivered: true
  }
]

const initialMeals: MealRecord[] = [
  { name: '早餐 鸡蛋三明治', calories: 360, protein: 22, time: '08:12' },
  { name: '午餐 牛肉饭半份', calories: 570, protein: 31, time: '12:36' }
]

function clampPercent(value: number, target: number) {
  return Math.min(Math.round((value / target) * 100), 100)
}

function taskPrompt(title: string) {
  const promptMap: Record<string, string> = {
    记饮食: '我刚吃了一份鸡胸肉沙拉和一杯拿铁',
    拍照识别: '上传外卖截图，帮我估算热量并记录',
    记体重: '今天早上空腹体重 68.2kg',
    记运动: '我刚椭圆机 35 分钟，强度中等',
    今日总结: '生成今天的数据摘要',
    蛋白进度: '今天蛋白质还差多少？',
    体重趋势: '看看我的7日趋势体重',
    备餐计划: '帮我做3天高蛋白备餐和购物清单',
    推送设置: '把晚餐提醒改到 18:30'
  }
  return promptMap[title] || title
}

function createCoachReply(input: string, stats: DayStats) {
  if (input.includes('体重')) {
    return '已记录体重：68.2kg。最近 7 日趋势稳定下降，建议继续保持早餐后称重的习惯。'
  }
  if (input.includes('跑步') || input.includes('运动') || input.includes('椭圆机')) {
    return '已记录运动：中等强度 35 分钟，估算消耗 240kcal。今天热量余量会同步增加。'
  }
  if (input.includes('蛋白')) {
    return `今天蛋白质 ${stats.protein}g / ${stats.targetProtein}g，还差 ${Math.max(stats.targetProtein - stats.protein, 0)}g。晚餐可以选鸡胸、鱼虾或豆腐。`
  }
  if (input.includes('总结') || input.includes('摘要')) {
    return `今日摘要：已摄入 ${stats.calories}kcal，运动消耗 ${stats.exercise}kcal，热量缺口约 ${stats.targetCalories - stats.calories + stats.exercise}kcal。`
  }
  if (input.includes('备餐') || input.includes('购物')) {
    return '已生成 3 天备餐框架：午餐鸡胸藜麦碗、晚餐虾仁豆腐汤，购物清单按肉类、蔬菜、主食分区整理。'
  }
  if (input.includes('拍照') || input.includes('上传') || input.includes('截图')) {
    return '我会识别图片里的食物、菜单或体重数字；如果份量不清，会追问你是一小份还是一大份。'
  }
  return '已识别为饮食记录：估算 420kcal，蛋白质 28g，碳水 42g，脂肪 14g。已写入今天记录。'
}

export default function Index() {
  const [activeTab, setActiveTab] = useState<TabKey>('chat')
  const [inputValue, setInputValue] = useState('')
  const [messages, setMessages] = useState<ChatMessage[]>(initialMessages)
  const [notifications, setNotifications] = useState<NotificationItem[]>(initialNotifications)
  const [stats, setStats] = useState<DayStats>({
    calories: 930,
    protein: 53,
    exercise: 180,
    weight: 68.4,
    targetCalories: 1840,
    targetProtein: 109
  })
  const [meals, setMeals] = useState<MealRecord[]>(initialMeals)
  const [completedFields, setCompletedFields] = useState<OnboardingField[]>([
    'height',
    'weight',
    'age'
  ])

  const unreadCount = useMemo(
    () => notifications.filter((item) => !item.delivered).length,
    [notifications]
  )

  const sendMessage = (value: string) => {
    const trimmed = value.trim()
    if (!trimmed) return

    const nextStats = { ...stats }
    const nextMessages: ChatMessage[] = [
      ...messages,
      { id: Date.now(), role: 'user', text: trimmed }
    ]

    if (!trimmed.includes('蛋白') && !trimmed.includes('总结') && !trimmed.includes('体重')) {
      nextStats.calories += 420
      nextStats.protein += 28
      setMeals((items) => [
        ...items,
        { name: 'AI 识别记录', calories: 420, protein: 28, time: '刚刚' }
      ])
    }

    if (trimmed.includes('运动') || trimmed.includes('跑步') || trimmed.includes('椭圆机')) {
      nextStats.exercise += 240
    }

    if (trimmed.includes('体重')) {
      nextStats.weight = 68.2
    }

    nextMessages.push({
      id: Date.now() + 1,
      role: 'coach',
      text: createCoachReply(trimmed, nextStats),
      meta: '已调用对应后端 Tool 的原型响应'
    })

    setStats(nextStats)
    setMessages(nextMessages)
    setInputValue('')
  }

  const handleTaskTap = (title: string) => {
    setActiveTab('chat')
    sendMessage(taskPrompt(title))
  }

  const toggleOnboarding = (field: OnboardingField) => {
    setCompletedFields((fields) =>
      fields.includes(field) ? fields.filter((item) => item !== field) : [...fields, field]
    )
  }

  const markRead = (id: number) => {
    setNotifications((items) =>
      items.map((item) => (item.id === id ? { ...item, delivered: true } : item))
    )
  }

  const renderChat = () => (
    <View className="screen screen-chat">
      <View className="hero">
        <View className="coach-avatar">
          <Text>HP</Text>
        </View>
        <View>
          <Text className="hero-title">你好，cy</Text>
          <Text className="hero-subtitle">为你记录、分析、提醒，随时找我聊健康</Text>
        </View>
      </View>

      <View className="suggestions">
        {quickPrompts.map((prompt) => (
          <View key={prompt} className="prompt-pill" onClick={() => sendMessage(prompt)}>
            <Text>{prompt}</Text>
          </View>
        ))}
      </View>

      <ScrollView className="message-list" scrollY>
        {messages.map((message) => (
          <View key={message.id} className={`message-row ${message.role}`}>
            <View className="message-bubble">
              <Text>{message.text}</Text>
              {message.meta ? <Text className="message-meta">{message.meta}</Text> : null}
            </View>
          </View>
        ))}
      </ScrollView>
    </View>
  )

  const renderTasks = () => (
    <ScrollView className="screen screen-scroll" scrollY>
      <View className="page-head">
        <Text className="page-title">Health Pilot 办事</Text>
        <View className="outline-button" onClick={() => setActiveTab('care')}>
          <Text>我的关怀 {unreadCount}</Text>
        </View>
      </View>

      <View className="task-grid">
        {healthTasks.map((task) => (
          <View
            key={task.title}
            className={`task-card ${task.accent}`}
            onClick={() => handleTaskTap(task.title)}
          >
            <View className="task-icon">
              <Text>{task.icon}</Text>
            </View>
            <Text className="task-title">{task.title}</Text>
            <Text className="task-hint">{task.hint}</Text>
          </View>
        ))}
      </View>

      <Text className="section-title">你可以这样跟我说</Text>
      <View className="phrase-board">
        {quickPrompts.concat(['上传菜单，帮我防坑', '把早餐提醒设到8点']).map((item) => (
          <View key={item} className="phrase-chip" onClick={() => sendMessage(item)}>
            <Text>{item}</Text>
          </View>
        ))}
      </View>

      <Text className="section-title">新用户建档</Text>
      <View className="setup-panel">
        {onboardingSteps.map((step, index) => {
          const done = completedFields.includes(step.key)
          return (
            <View
              key={step.key}
              className={`setup-row ${done ? 'done' : ''}`}
              onClick={() => toggleOnboarding(step.key)}
            >
              <View className="setup-index">
                <Text>{done ? '✓' : index + 1}</Text>
              </View>
              <View className="setup-copy">
                <Text>{step.label}</Text>
                <Text>{step.value}</Text>
              </View>
            </View>
          )
        })}
      </View>
    </ScrollView>
  )

  const renderInsights = () => {
    const caloriePct = clampPercent(stats.calories, stats.targetCalories)
    const proteinPct = clampPercent(stats.protein, stats.targetProtein)
    const gap = stats.targetCalories - stats.calories + stats.exercise

    return (
      <ScrollView className="screen screen-scroll" scrollY>
        <View className="page-head compact">
          <View>
            <Text className="page-title">今日数据</Text>
            <Text className="page-subtitle">对齐后端 daily summary / protein / trend 工具</Text>
          </View>
          <Text className="sync-label">刚刚同步</Text>
        </View>

        <View className="metric-hero">
          <Text className="metric-label">热量余量</Text>
          <Text className="metric-value">{gap}kcal</Text>
          <View className="progress-track">
            <View className="progress-fill calories" style={{ width: `${caloriePct}%` }} />
          </View>
          <Text className="metric-note">
            已摄入 {stats.calories} / {stats.targetCalories}kcal，运动抵扣 {stats.exercise}kcal
          </Text>
        </View>

        <View className="insight-grid">
          <View className="insight-item">
            <Text className="insight-number">{proteinPct}%</Text>
            <Text className="insight-label">蛋白达成</Text>
          </View>
          <View className="insight-item">
            <Text className="insight-number">{stats.weight}kg</Text>
            <Text className="insight-label">今日体重</Text>
          </View>
          <View className="insight-item">
            <Text className="insight-number">-0.42</Text>
            <Text className="insight-label">周均kg</Text>
          </View>
        </View>

        <Text className="section-title">趋势体重</Text>
        <View className="trend-panel">
          {[62, 54, 58, 44, 48, 38, 34].map((height, index) => (
            <View key={`${height}-${index}`} className="trend-bar-wrap">
              <View className="trend-bar" style={{ height: `${height}%` }} />
              <Text>{index + 1}</Text>
            </View>
          ))}
        </View>

        <Text className="section-title">今日记录</Text>
        <View className="record-list">
          {meals.map((meal) => (
            <View key={`${meal.name}-${meal.time}`} className="record-row">
              <View>
                <Text className="record-title">{meal.name}</Text>
                <Text className="record-subtitle">
                  {meal.calories}kcal · 蛋白 {meal.protein}g
                </Text>
              </View>
              <Text className="record-time">{meal.time}</Text>
            </View>
          ))}
        </View>
      </ScrollView>
    )
  }

  const renderCare = () => (
    <ScrollView className="screen screen-scroll" scrollY>
      <View className="page-head compact">
        <View>
          <Text className="page-title">主动关怀</Text>
          <Text className="page-subtitle">定时提醒、条件触发和沉默唤醒</Text>
        </View>
        <View className="badge">
          <Text>{unreadCount} 未读</Text>
        </View>
      </View>

      <View className="care-feed">
        {notifications.map((item) => (
          <View key={item.id} className={`care-card ${item.delivered ? 'read' : 'unread'}`}>
            <View className="care-topline">
              <Text className="care-trigger">{item.triggerName}</Text>
              <Text className="care-time">{item.time}</Text>
            </View>
            <Text className="care-title">{item.title}</Text>
            <Text className="care-content">{item.content}</Text>
            <View className="care-actions">
              <View
                className="care-action primary"
                onClick={() => sendMessage(`回复推送：${item.content}`)}
              >
                <Text>接着聊</Text>
              </View>
              <View className="care-action" onClick={() => markRead(item.id)}>
                <Text>{item.delivered ? '已读' : '标记已读'}</Text>
              </View>
            </View>
          </View>
        ))}
      </View>

      <Text className="section-title">提醒时间</Text>
      <View className="schedule-list">
        {['早餐 08:00', '午餐 12:10', '晚餐 18:30', '称重 07:40', '周报 周日 20:00'].map((item) => (
          <View key={item} className="schedule-row">
            <Text>{item}</Text>
            <View className="switch-on">
              <View />
            </View>
          </View>
        ))}
      </View>
    </ScrollView>
  )

  return (
    <View className="index">
      <View className="status-bar">
        <Text>21:02</Text>
        <Text>Health Pilot</Text>
        <Text>{unreadCount ? `${unreadCount} 条提醒` : '已同步'}</Text>
      </View>

      <View className="top-bar">
        <View className="menu-mark">
          <Text>—</Text>
        </View>
        <Text className="brand-title">
          {activeTab === 'chat' ? '健康教练' : tabs.find((tab) => tab.key === activeTab)?.label}
        </Text>
        <View className="quiet-mark">
          <Text>⌁</Text>
        </View>
      </View>

      <View className="viewport">
        {activeTab === 'chat' ? renderChat() : null}
        {activeTab === 'tasks' ? renderTasks() : null}
        {activeTab === 'insights' ? renderInsights() : null}
        {activeTab === 'care' ? renderCare() : null}
      </View>

      <View className="shortcut-row">
        {tabs.map((tab) => (
          <View
            key={tab.key}
            className={`shortcut ${activeTab === tab.key ? 'active' : ''}`}
            onClick={() => setActiveTab(tab.key)}
          >
            <Text>{tab.icon}</Text>
            <Text>{tab.label}</Text>
          </View>
        ))}
      </View>

      <View className="composer">
        <View className="voice-button">
          <Text>◉</Text>
        </View>
        <Input
          className="composer-input"
          value={inputValue}
          placeholder="发消息或按住说话..."
          onInput={(event) => setInputValue(String(event.detail.value))}
          confirmType="send"
          onConfirm={() => sendMessage(inputValue)}
        />
        <View className="icon-button" onClick={() => sendMessage('上传一张午餐照片')}>
          <Text>□</Text>
        </View>
        <View
          className="send-button"
          onClick={() => sendMessage(inputValue || '今天蛋白质还差多少？')}
        >
          <Text>↑</Text>
        </View>
      </View>
    </View>
  )
}
