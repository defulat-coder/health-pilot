# Health Pilot Agent Guide

本文件适用于整个仓库。子目录中的 `AGENTS.md` 会补充或覆盖更具体的规则。

## 项目定位

Health Pilot 是一个轻量个人健康管理产品：用户通过移动 AI 聊天体验记录饮食、体重、运动和图片截图，系统在后端沉淀结构化健康数据、长期记忆和主动关怀推送。前端当前主线是 `ios/DoubaoNative` 的原生 SwiftUI 移动端，后端当前主线是 `backend` 的 Agno AgentOS API。

核心产品与设计依据：

- `PRODUCT.md`：产品目标、用户、语气、安全边界和反参考。
- `DESIGN.md`：Health Pilot 视觉系统与组件原则。
- `design/reference/doubao-mobile/`：移动端交互与视觉参考截图、manifest、网络/DOM 观察。
- `docs/research/2026-06-19-doubao-mobile-cdp-analysis.md`：Doubao mobile CDP 研究记录。
- `docs/superpowers/specs/` 与 `docs/superpowers/plans/`：历史规格与实现计划。

## 目录边界

- `backend/`：Python 3.13+ 后端，Agno AgentOS/FastAPI、SQLAlchemy、APScheduler、健康记录 tools、主动推送调度。
- `ios/`：原生 iOS SwiftUI 客户端。当前项目是 `ios/DoubaoNative`。
- `design/`：参考截图、候选视觉稿和 manifest。修改视觉覆盖时优先保持 manifest 与截图脚本一致。
- `docs/`：研究、计划、规格和证据材料。新增长期决策应写入合适的 docs 文件，不只写在对话里。

## 工作规则

- 先读相关目录的 `AGENTS.md`、README 和设计/产品文档，再改代码。
- 不要回滚或清理用户已有的未提交改动，除非用户明确要求。
- 不要提交或移动密钥、本地数据库、虚拟环境、DerivedData、临时截图和系统文件。
- 健康建议相关文案必须保持非医疗诊断边界：不提供诊断或药物建议，不鼓励极端节食。
- UI 改动必须遵守 `DESIGN.md`：聊天优先、轻量、原生移动节奏、蓝色和中性色为主，不使用 SaaS 式紫蓝渐变、金色装饰或医疗后台风格。
- 不要复制 Doubao 专有品牌资产或调用受保护 Doubao 接口；只复用观察到的交互模式。

## 常用验证

按改动范围选择最小但充分的验证：

```bash
# 后端
cd backend
uv sync
uv run python -m compileall .
uv run python main.py

# iOS 本地静态/状态验证
ios/DoubaoNative/Scripts/verify-local.sh

# iOS 工程发现
xcodebuild -project ios/DoubaoNative/DoubaoNative.xcodeproj -list
```

后端服务默认运行在 `http://localhost:7777`，健康检查为 `GET /health`。需要联调 iOS 健康摘要时，先启动后端，再验证客户端服务边界。

## Git 与生成物

当前仓库可能包含迁移中的文件移动状态。做任务时只改请求范围内的文件，并在最终说明中点明改了哪些文件。避免把以下内容加入版本控制：`.env`、`*.db`、`.venv/`、`.derivedData/`、`__pycache__/`、`.DS_Store`。
