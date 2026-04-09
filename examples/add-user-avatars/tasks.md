# 用户头像功能实现计划

> **执行方式**: 使用 spec-power 执行阶段，推荐子 agent 并行模式

**目标**: 为用户系统添加头像上传、显示和管理功能
**架构**: 对象存储（S3/OSS）+ CDN 分发，生成多尺寸缩略图，默认头像基于用户名首字母
**技术栈**: Node.js + TypeScript, PostgreSQL, AWS S3, Sharp（图片处理）

---

## Task 1: 数据库迁移

**文件**:
- Create: `migrations/20260408_add_avatar_url.sql`
- Test: `tests/migrations/test_avatar_migration.ts`

**依赖**: 无 (可并行)

**步骤**:
- [ ] 编写失败测试: 验证 `users` 表有 `avatar_url` 字段
  验证: `npm test -- --grep "avatar_url field"` → 期望失败（字段不存在）
- [ ] 编写迁移脚本: 添加 `avatar_url` 字段和索引
  ```sql
  ALTER TABLE users ADD COLUMN avatar_url VARCHAR(255);
  CREATE INDEX idx_users_avatar_url ON users(avatar_url);
  ```
- [ ] 运行迁移: `npm run migrate:up`
  验证: `npm test -- --grep "avatar_url field"` → 期望通过
- [ ] 编写回滚脚本: `migrations/20260408_add_avatar_url.down.sql`
- [ ] 测试回滚: `npm run migrate:down && npm run migrate:up`
  验证: 迁移和回滚都正常工作
- [ ] 提交: `git commit -m "feat(db): add avatar_url to users table"`

---

## Task 2: 对象存储客户端封装

**文件**:
- Create: `src/services/storage/s3-client.ts`
- Test: `tests/services/storage/s3-client.test.ts`

**依赖**: 无 (可并行)

**步骤**:
- [ ] 编写失败测试: 测试文件上传到 S3
  ```typescript
  test('uploads file to S3 and returns URL', async () => {
    const url = await s3Client.upload(buffer, 'test.jpg');
    expect(url).toMatch(/^https:\/\/cdn\.example\.com/);
  });
  ```
  验证: `npm test s3-client` → 期望失败（类不存在）
- [ ] 实现 S3Client 类:
  - `upload(buffer: Buffer, filename: string): Promise<string>`
  - `delete(url: string): Promise<void>`
- [ ] 配置 S3 凭证（从环境变量读取）
- [ ] 验证测试通过: `npm test s3-client` → 期望全部通过
- [ ] 提交: `git commit -m "feat(storage): add S3 client wrapper"`

---

## Task 3: 图片处理服务

**文件**:
- Create: `src/services/image-processor.ts`
- Test: `tests/services/image-processor.test.ts`

**依赖**: 无 (可并行)

**步骤**:
- [ ] 编写失败测试: 测试生成多尺寸缩略图
  ```typescript
  test('generates thumbnails in multiple sizes', async () => {
    const result = await imageProcessor.process(buffer);
    expect(result).toHaveProperty('large');
    expect(result).toHaveProperty('medium');
    expect(result).toHaveProperty('small');
  });
  ```
  验证: `npm test image-processor` → 期望失败
- [ ] 实现 ImageProcessor:
  - 验证格式（JPEG/PNG）
  - 验证文件大小（≤ 5MB）
  - 生成 800x800、200x200、48x48 三种尺寸
  - 返回 Buffer 数组
- [ ] 验证测试通过: `npm test image-processor` → 期望全部通过
- [ ] 提交: `git commit -m "feat(image): add image processing service"`

---

## Task 4: 默认头像生成器

**文件**:
- Create: `src/services/default-avatar.ts`
- Test: `tests/services/default-avatar.test.ts`

**依赖**: 无 (可并行)

**步骤**:
- [ ] 编写失败测试: 测试基于用户名生成默认头像 URL
  ```typescript
  test('generates default avatar URL from username', () => {
    const url = generateDefaultAvatar('Alice');
    expect(url).toContain('name=A');
    expect(url).toContain('background=');
  });
  ```
  验证: `npm test default-avatar` → 期望失败
- [ ] 实现 generateDefaultAvatar 函数
- [ ] 验证颜色分配的一致性（同一用户名总是相同颜色）
- [ ] 验证测试通过: `npm test default-avatar` → 期望全部通过
- [ ] 提交: `git commit -m "feat(avatar): add default avatar generator"`

---

## Task 5: 头像上传 API

**文件**:
- Modify: `src/routes/users.ts`
- Create: `src/controllers/avatar-controller.ts`
- Test: `tests/api/avatar-upload.test.ts`

**依赖**: Task 1, Task 2, Task 3 (需要数据库、存储、图片处理)

**步骤**:
- [ ] 编写失败测试: 测试上传头像 API
  ```typescript
  test('POST /api/users/:id/avatar uploads and returns URL', async () => {
    const res = await request(app)
      .post('/api/users/123/avatar')
      .attach('file', buffer, 'avatar.jpg')
      .expect(200);
    expect(res.body.avatar_url).toBeDefined();
  });
  ```
  验证: `npm test avatar-upload` → 期望失败（路由不存在）
- [ ] 实现 AvatarController.upload:
  - 验证用户权限（只能修改自己的头像）
  - 调用 ImageProcessor 处理图片
  - 上传三个尺寸到 S3（large/medium/small）
  - 更新数据库 `avatar_url` 字段（存储 medium 尺寸的 URL）
  - 返回 avatar_url
- [ ] 添加路由: `POST /api/users/:id/avatar`
- [ ] 测试边界情况:
  - 文件格式错误 → 返回 400
  - 文件过大 → 返回 413
  - 无权限 → 返回 403
- [ ] 验证所有测试通过: `npm test avatar-upload` → 期望全部通过
- [ ] 提交: `git commit -m "feat(api): add avatar upload endpoint"`

---

## Task 6: 头像删除 API

**文件**:
- Modify: `src/routes/users.ts`
- Modify: `src/controllers/avatar-controller.ts`
- Test: `tests/api/avatar-delete.test.ts`

**依赖**: Task 5 (复用控制器)

**步骤**:
- [ ] 编写失败测试: 测试删除头像 API
  ```typescript
  test('DELETE /api/users/:id/avatar removes avatar', async () => {
    await request(app)
      .delete('/api/users/123/avatar')
      .expect(204);
    
    const user = await db.users.findById('123');
    expect(user.avatar_url).toBeNull();
  });
  ```
  验证: `npm test avatar-delete` → 期望失败
- [ ] 实现 AvatarController.delete:
  - 验证用户权限
  - 从 S3 删除三个尺寸的文件
  - 将数据库 `avatar_url` 设为 NULL
- [ ] 添加路由: `DELETE /api/users/:id/avatar`
- [ ] 验证测试通过: `npm test avatar-delete` → 期望全部通过
- [ ] 提交: `git commit -m "feat(api): add avatar delete endpoint"`

---

## Task 7: 扩展用户 API 响应

**文件**:
- Modify: `src/controllers/user-controller.ts`
- Modify: `src/serializers/user-serializer.ts`
- Test: `tests/api/user-get.test.ts`

**依赖**: Task 1, Task 4 (需要数据库字段和默认头像生成器)

**步骤**:
- [ ] 编写失败测试: 验证 GET /api/users/:id 返回 avatar_url
  ```typescript
  test('includes avatar_url in response', async () => {
    const res = await request(app).get('/api/users/123').expect(200);
    expect(res.body).toHaveProperty('avatar_url');
  });
  
  test('uses default avatar when avatar_url is null', async () => {
    const res = await request(app).get('/api/users/no-avatar').expect(200);
    expect(res.body.avatar_url).toMatch(/ui-avatars\.com/);
  });
  ```
  验证: `npm test user-get` → 期望失败
- [ ] 修改 UserSerializer:
  - 添加 `avatar_url` 字段到响应
  - 如果 `avatar_url` 为 null，调用 `generateDefaultAvatar(username)`
- [ ] 验证测试通过: `npm test user-get` → 期望全部通过
- [ ] 提交: `git commit -m "feat(api): include avatar_url in user response"`

---

## Task 8: 前端头像上传组件

**文件**:
- Create: `frontend/src/components/AvatarUpload.tsx`
- Test: `frontend/tests/components/AvatarUpload.test.tsx`

**依赖**: Task 5 (需要上传 API)

**步骤**:
- [ ] 编写失败测试: 测试组件渲染和上传行为
  ```typescript
  test('uploads file when selected', async () => {
    const { getByLabelText } = render(<AvatarUpload userId="123" />);
    const input = getByLabelText('Upload avatar');
    fireEvent.change(input, { target: { files: [file] } });
    await waitFor(() => expect(mockUploadFn).toHaveBeenCalled());
  });
  ```
  验证: `npm test AvatarUpload` → 期望失败
- [ ] 实现 AvatarUpload 组件:
  - 文件输入框
  - 预览当前头像
  - 上传进度指示
  - 错误处理（显示友好的错误消息）
- [ ] 验证测试通过: `npm test AvatarUpload` → 期望全部通过
- [ ] 提交: `git commit -m "feat(ui): add avatar upload component"`

---

## Task 9: 前端头像显示组件

**文件**:
- Create: `frontend/src/components/Avatar.tsx`
- Test: `frontend/tests/components/Avatar.test.tsx`

**依赖**: Task 7 (需要用户 API 返回 avatar_url)

**步骤**:
- [ ] 编写失败测试: 测试头像显示
  ```typescript
  test('displays avatar from URL', () => {
    const { getByAltText } = render(
      <Avatar url="https://cdn.example.com/avatar.jpg" />
    );
    expect(getByAltText('User avatar')).toBeInTheDocument();
  });
  ```
  验证: `npm test Avatar` → 期望失败
- [ ] 实现 Avatar 组件:
  - 支持三种尺寸（small/medium/large）
  - 根据尺寸加载对应 URL
  - 图片加载失败时显示占位符
  - 圆形裁剪
- [ ] 验证测试通过: `npm test Avatar` → 期望全部通过
- [ ] 提交: `git commit -m "feat(ui): add avatar display component"`

---

## Task 10: 集成和端到端测试

**文件**:
- Create: `tests/e2e/avatar-flow.test.ts`

**依赖**: Task 8, Task 9 (需要前端组件)

**步骤**:
- [ ] 编写端到端测试: 完整的头像上传和显示流程
  ```typescript
  test('user can upload and see their avatar', async () => {
    // 1. 登录
    await page.goto('/login');
    await page.fill('[name="email"]', 'test@example.com');
    await page.click('button[type="submit"]');
    
    // 2. 上传头像
    await page.goto('/profile');
    await page.setInputFiles('[data-testid="avatar-input"]', 'test-avatar.jpg');
    await page.waitForSelector('[data-testid="avatar-preview"]');
    
    // 3. 验证头像显示
    const avatarSrc = await page.getAttribute('[data-testid="avatar-preview"]', 'src');
    expect(avatarSrc).toContain('cdn.example.com');
    
    // 4. 在其他页面验证
    await page.goto('/comments');
    const commentAvatar = await page.getAttribute('.comment-avatar', 'src');
    expect(commentAvatar).toBe(avatarSrc);
  });
  ```
  验证: `npm run test:e2e` → 期望通过（如果前面所有步骤都正确）
- [ ] 提交: `git commit -m "test(e2e): add avatar upload flow test"`

---

## 依赖图

```
Task 1 (DB) ──┬──► Task 5 (上传 API) ──► Task 6 (删除 API)
              │       │
Task 2 (S3) ──┤       │
              │       │
Task 3 (图片处理) ─┘       │
                          │
Task 4 (默认头像) ──────► Task 7 (用户 API) ──┬──► Task 9 (显示组件) ──┐
                                              │                      │
                      Task 8 (上传组件) ◄──────┘                      │
                              │                                      │
                              └──────────────────────────────────────┴──► Task 10 (E2E)
```

**可并行**: Task 1, Task 2, Task 3, Task 4 (前四个任务无依赖，可同时开始)

---

## 验证清单

所有任务完成后，运行完整验证：

- [ ] 单元测试: `npm test` → 所有测试通过
- [ ] 端到端测试: `npm run test:e2e` → 所有流程正常
- [ ] 代码覆盖率: `npm run test:coverage` → ≥ 80%
- [ ] Lint: `npm run lint` → 无错误
- [ ] 类型检查: `npm run type-check` → 无错误
- [ ] 本地手动测试:
  - 上传 JPEG 头像 → 成功
  - 上传 PNG 头像 → 成功
  - 上传超大文件 → 返回 413 错误
  - 上传 GIF → 返回 400 错误
  - 删除头像 → 成功，显示默认头像
  - 在多个页面查看头像 → 显示一致

---

## 时间估算

假设使用子 agent 并行执行：

- **第一批并行** (Task 1-4): 2-3 小时
- **第二批顺序** (Task 5-7): 3-4 小时
- **第三批并行** (Task 8-9): 2-3 小时
- **集成测试** (Task 10): 1-2 小时
- **总计**: 1-1.5 个工作日

如果顺序执行，预计 2-3 个工作日。
