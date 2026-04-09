# 用户头像功能技术设计

## 现状

当前用户系统的数据模型：

```typescript
interface User {
  id: string;
  username: string;
  email: string;
  created_at: Date;
  updated_at: Date;
}
```

前端在显示用户信息时，只能显示用户名首字母或占位符图标。

## 目标

- 用户可以上传和显示个人头像
- 系统能够高效存储和分发头像
- 为未上传头像的用户提供合理的默认展示

## 非目标

- 不提供图片编辑功能
- 不支持动图（GIF）

## 方案对比

### 方案 A: 对象存储 + CDN (推荐)

头像上传到对象存储（S3/OSS），通过 CDN 分发。

**优势**:
- 存储成本低（约 ¥0.12/GB/月）
- CDN 加速全球访问
- 无需担心磁盘空间
- 天然支持高并发

**劣势**:
- 需要配置对象存储和 CDN
- 轻微的外部依赖

**实现复杂度**: 中

### 方案 B: 存储在服务器本地磁盘

头像保存在服务器 `/uploads/avatars/` 目录。

**优势**:
- 实现简单
- 无外部依赖
- 开发环境友好

**劣势**:
- 磁盘空间有限
- 无法水平扩展（多服务器需要同步文件）
- 带宽消耗在应用服务器
- 无 CDN 加速

**实现复杂度**: 低

### 方案 C: 存储在数据库 (BLOB)

头像以二进制形式存储在数据库中。

**优势**:
- 数据一致性好
- 无需额外存储服务

**劣势**:
- 数据库空间消耗大
- 查询性能差
- 备份体积大
- 违反数据库最佳实践

**实现复杂度**: 低（但不推荐）

## 决策

**选择方案 A：对象存储 + CDN**

**理由**:
1. **可扩展性** - 用户量增长时，方案 B 和 C 都会遇到瓶颈
2. **性能** - CDN 分发比应用服务器直接提供快 10 倍以上
3. **成本** - 对象存储比服务器磁盘更便宜，且不占用应用服务器资源
4. **行业标准** - 大多数成熟产品采用此方案

虽然实现复杂度稍高，但长期收益远超短期成本。

## 关键设计

### 数据模型

**数据库变更**:

```sql
ALTER TABLE users 
ADD COLUMN avatar_url VARCHAR(255) DEFAULT NULL;

CREATE INDEX idx_users_avatar_url ON users(avatar_url);
```

**User 模型扩展**:

```typescript
interface User {
  id: string;
  username: string;
  email: string;
  avatar_url: string | null;  // 新增
  created_at: Date;
  updated_at: Date;
}
```

### 接口设计

#### 1. 上传头像

```
POST /api/users/:id/avatar
Content-Type: multipart/form-data

Body:
  - file: (binary)

Response 200:
{
  "avatar_url": "https://cdn.example.com/avatars/abc123.jpg"
}

Response 400:
{
  "error": "Invalid file format. Only JPEG and PNG are supported."
}

Response 413:
{
  "error": "File size exceeds 5MB limit."
}
```

#### 2. 获取用户信息（已有接口，扩展响应）

```
GET /api/users/:id

Response 200:
{
  "id": "123",
  "username": "alice",
  "email": "alice@example.com",
  "avatar_url": "https://cdn.example.com/avatars/abc123.jpg",  // 新增
  "created_at": "2026-01-01T00:00:00Z",
  "updated_at": "2026-04-08T10:30:00Z"
}
```

#### 3. 删除头像

```
DELETE /api/users/:id/avatar

Response 204: (No Content)
```

### 文件命名策略

```
格式: {user_id}_{timestamp}_{random}.{ext}
示例: user_123_1712558400_a7f3.jpg

优势:
- user_id: 快速定位归属
- timestamp: 避免缓存问题（每次上传生成新 URL）
- random: 防止猜测（安全性）
- ext: 保留原始格式
```

### 图片处理

**上传流程**:
1. 验证格式（JPEG/PNG）和大小（≤ 5MB）
2. 生成多个尺寸的缩略图：
   - `original`: 原始上传（保留）
   - `large`: 800x800（个人主页）
   - `medium`: 200x200（评论列表）
   - `small`: 48x48（消息气泡）
3. 上传到对象存储的不同前缀
4. 返回 `medium` 尺寸的 URL 作为默认头像

**URL 结构**:
```
https://cdn.example.com/avatars/large/user_123_xxx.jpg
https://cdn.example.com/avatars/medium/user_123_xxx.jpg
https://cdn.example.com/avatars/small/user_123_xxx.jpg
```

前端可以根据场景选择合适的尺寸。

### 默认头像生成

为未上传头像的用户，生成基于用户名首字母的默认头像：

```typescript
function generateDefaultAvatar(username: string): string {
  const initial = username.charAt(0).toUpperCase();
  const colors = ['#FF6B6B', '#4ECDC4', '#45B7D1', '#FFA07A', '#98D8C8'];
  const colorIndex = username.charCodeAt(0) % colors.length;
  const bgColor = colors[colorIndex];
  
  return `https://ui-avatars.com/api/?name=${initial}&background=${bgColor.slice(1)}&color=fff&size=200`;
}
```

使用第三方服务 `ui-avatars.com`（免费，无需维护）或自建生成服务。

### 错误处理

| 错误场景 | HTTP 状态码 | 处理方式 |
|---------|------------|---------|
| 文件格式不支持 | 400 | 返回友好错误消息 |
| 文件过大 | 413 | 返回错误消息，提示 5MB 限制 |
| 对象存储上传失败 | 500 | 记录日志，返回通用错误消息 |
| 用户无权限修改 | 403 | 返回权限错误 |
| 频率限制超出 | 429 | 返回 "Too Many Requests" |

### 安全考虑

1. **权限检查**: 只能修改自己的头像（除非是管理员）
2. **文件类型验证**: 不仅检查扩展名，还要检查文件头（magic bytes）
3. **文件大小限制**: 5MB 硬限制
4. **频率限制**: 每个用户每天最多上传 3 次
5. **内容审核**: 接入图片审核 API（一期可选）

## 风险与缓解

| 风险 | 概率 | 影响 | 缓解措施 |
|------|------|------|---------|
| 对象存储服务中断 | 低 | 高 | 使用稳定的云服务商；配置降级逻辑（显示默认头像） |
| 恶意上传消耗存储 | 中 | 中 | 频率限制；文件大小限制；定期清理未使用的旧头像 |
| 用户上传不当内容 | 中 | 高 | 二期接入内容审核 API；提供举报机制 |
| 迁移现有用户数据 | 低 | 低 | 无需迁移（旧用户使用默认头像） |

## 迁移计划

**无需数据迁移**

- 新字段 `avatar_url` 默认为 NULL
- 旧用户继续使用默认头像
- 前端代码兼容 `avatar_url` 为 null 的情况

**部署顺序**:
1. 后端 API 部署（包含数据库迁移）
2. 验证 API 工作正常
3. 前端部署
4. 灰度发布（10% → 50% → 100%）

**回滚方案**:
- 数据库迁移可回滚（删除 `avatar_url` 字段）
- 对象存储中的文件可保留（不影响旧版本）
- 前端回滚（旧版本忽略 `avatar_url` 字段）

## 性能指标

- 头像上传 P95 延迟: < 2 秒
- 头像加载（通过 CDN）P95 延迟: < 300ms
- 数据库查询性能: 不受影响（已加索引）

## 监控和告警

- 上传成功率
- 上传延迟
- 对象存储错误率
- CDN 命中率
- 存储空间使用量
