# 用户头像功能规范 (Delta)

> **注意**: 这是一个 Delta 规范示例，展示格式。Standard 模式通常不需要写规范。

---

## ADDED Requirements

### Requirement: 头像上传

系统 SHALL 允许已认证用户上传 JPEG 或 PNG 格式的头像图片。
系统 MUST 限制上传文件大小不超过 5MB。
系统 MUST 验证文件格式的真实性（检查文件头，不仅依赖扩展名）。

#### Scenario: 成功上传 JPEG 头像

- **GIVEN** 一个已登录的用户
- **WHEN** 用户上传一张 2MB 的 JPEG 图片
- **THEN** 系统保存图片并返回图片 URL
- **AND** 用户的个人资料页显示新头像
- **AND** 响应时间在 2 秒内（P95）

#### Scenario: 成功上传 PNG 头像

- **GIVEN** 一个已登录的用户
- **WHEN** 用户上传一张 3MB 的 PNG 图片
- **THEN** 系统保存图片并返回图片 URL
- **AND** 用户的个人资料页显示新头像

#### Scenario: 文件过大被拒绝

- **GIVEN** 一个已登录的用户
- **WHEN** 用户上传一张 6MB 的图片
- **THEN** 系统返回 HTTP 413 状态码
- **AND** 返回错误消息 "文件大小不能超过 5MB"
- **AND** 用户的头像保持不变

#### Scenario: 不支持的格式被拒绝

- **GIVEN** 一个已登录的用户
- **WHEN** 用户上传一张 GIF 动图
- **THEN** 系统返回 HTTP 400 状态码
- **AND** 返回错误消息 "仅支持 JPEG 和 PNG 格式"

#### Scenario: 伪装的文件被识别

- **GIVEN** 一个已登录的用户
- **WHEN** 用户上传一个扩展名为 .jpg 但实际是 .exe 的文件
- **THEN** 系统返回 HTTP 400 状态码
- **AND** 返回错误消息 "文件格式验证失败"

### Requirement: 头像显示

系统 SHALL 在用户个人主页、评论列表、消息界面显示用户头像。
系统 MUST 为未上传头像的用户生成默认头像。

#### Scenario: 显示已上传的头像

- **GIVEN** 一个已上传头像的用户
- **WHEN** 另一个用户访问该用户的个人主页
- **THEN** 系统显示该用户上传的头像
- **AND** 头像加载时间在 300ms 内（P95，通过 CDN）

#### Scenario: 显示默认头像

- **GIVEN** 一个未上传头像的用户（用户名为 "Alice"）
- **WHEN** 另一个用户访问该用户的个人主页
- **THEN** 系统显示基于用户名首字母的默认头像
- **AND** 默认头像显示字母 "A"
- **AND** 背景颜色与用户名一致（同一用户名总是相同颜色）

#### Scenario: 评论中显示头像

- **GIVEN** 一个评论列表页面
- **WHEN** 页面包含多个用户的评论
- **THEN** 每条评论旁边显示对应用户的头像（已上传或默认）
- **AND** 所有头像加载完成时间在 1 秒内（P95）

### Requirement: 头像删除

系统 SHALL 允许用户删除自己的头像。
系统 MUST 在删除头像后清理对象存储中的文件。

#### Scenario: 删除头像

- **GIVEN** 一个已上传头像的用户
- **WHEN** 用户删除自己的头像
- **THEN** 系统从对象存储删除相关文件（三个尺寸）
- **AND** 数据库中 `avatar_url` 字段设为 NULL
- **AND** 用户的个人主页显示默认头像

#### Scenario: 无权限删除他人头像

- **GIVEN** 两个用户 Alice 和 Bob
- **WHEN** Alice 尝试删除 Bob 的头像
- **THEN** 系统返回 HTTP 403 状态码
- **AND** Bob 的头像保持不变

### Requirement: 权限控制

系统 MUST 确保用户只能修改自己的头像。
系统 MAY 允许管理员修改任何用户的头像。

#### Scenario: 用户修改自己的头像

- **GIVEN** 一个已登录的用户 Alice
- **WHEN** Alice 上传新头像到 `/api/users/alice-id/avatar`
- **THEN** 请求成功

#### Scenario: 用户无法修改他人头像

- **GIVEN** 两个已登录的用户 Alice 和 Bob
- **WHEN** Alice 尝试上传头像到 `/api/users/bob-id/avatar`
- **THEN** 系统返回 HTTP 403 状态码
- **AND** Bob 的头像保持不变

### Requirement: 频率限制

系统 MUST 限制每个用户每天最多修改头像 3 次。

#### Scenario: 频率限制内的操作

- **GIVEN** 一个用户今天已经修改头像 2 次
- **WHEN** 用户第 3 次修改头像
- **THEN** 请求成功

#### Scenario: 超出频率限制

- **GIVEN** 一个用户今天已经修改头像 3 次
- **WHEN** 用户尝试第 4 次修改头像
- **THEN** 系统返回 HTTP 429 状态码
- **AND** 返回错误消息 "每天最多修改 3 次头像"
- **AND** 头像保持不变

---

## MODIFIED Requirements

### Requirement: 用户 API 响应

系统 MUST 在 `/api/users/:id` 响应中包含 `avatar_url` 字段。
(之前: 用户 API 不包含头像信息)

#### Scenario: API 返回头像 URL

- **GIVEN** 一个已上传头像的用户
- **WHEN** 调用 `GET /api/users/:id`
- **THEN** 响应包含 `avatar_url` 字段
- **AND** `avatar_url` 指向有效的图片 URL

#### Scenario: API 返回默认头像

- **GIVEN** 一个未上传头像的用户
- **WHEN** 调用 `GET /api/users/:id`
- **THEN** 响应包含 `avatar_url` 字段
- **AND** `avatar_url` 指向默认头像生成服务

---

## REMOVED Requirements

无。本变更没有移除任何现有需求。

---

## 规范遵循度

| RFC 2119 关键词 | 使用次数 | 说明 |
|----------------|---------|------|
| MUST | 7 | 绝对要求（文件大小、格式验证、权限等） |
| SHALL | 3 | 核心功能（上传、显示、删除） |
| MAY | 1 | 可选功能（管理员权限） |

所有 MUST/SHALL 级需求都必须在实现中完整覆盖。
