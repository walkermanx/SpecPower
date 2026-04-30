# Flow 模式完整指南

Flow 模式是 SpecPower 的轻量级工作流，适用于明确、简单的任务。

> **v1.11.0 强化 — Flow 超轻量化**
>
> Flow 模式现在是真正的 "轻量通道":
> - ❌ **不创建** 变更目录 `docs/spec-power/changes/<name>/`
> - ❌ **不产出** `.specpower.yaml` 元数据
> - ❌ **不产出** `reviews/` 审查文件
> - ❌ **不产出** `task-N-*-skip.md` 声明文件
> - ❌ **不输出** 结构化任务完成声明
> - ✅ **只要**: 口头提案 (1 句话) + TDD 循环 + `git commit`
>
> 这是对 v1.10.0 "Flow 也要强制输出完成声明" 的明确修正——纪律必须匹配任务规模, 否则用户会绕开 Flow 直接 hack。
>
> 需要跨会话恢复、需要审计留痕、需要多任务协调 → 用 Standard 模式, 不要把 Flow 撑重。

---

## 何时使用 Flow

**适用场景**:
- 单文件或双文件修改
- Bug 修复（问题和解决方案都明确）
- 配置变更
- 简单功能增强（无需架构决策）

**不适用场景**:
- 涉及 3+ 文件
- 需要权衡多个方案
- 跨模块变更
- 不确定需求

---

## Flow 工作流

```
[口头提案] → [TDD 执行] → [验证] → [完成]
   30秒        5-15分钟      2分钟     
```

### Step 1: 口头提案（30秒）

无需创建文件，在对话中说清楚：

**提案模板**:
```
改什么：修复 login.ts 中密码特殊字符处理
为什么：当前 #& 等字符导致 500 错误
怎么验证：添加特殊字符测试，修复后测试通过
```

**自审清单**:
- [ ] 说明了改什么文件/函数
- [ ] 说明了为什么要改
- [ ] 说明了如何验证
- [ ] 如果修改了接口、请求格式或行为，说明对已有调用方的影响（兼容性影响）

---

### Step 2: TDD 执行

遵循 RED-GREEN-REFACTOR，但更紧凑：

#### Phase A: RED（写失败测试）

```typescript
// ❌ 先写一个会失败的测试
test('login with special chars in password', async () => {
  const result = await login('user@example.com', 'p@ssw#rd!');
  expect(result.success).toBe(true);
});
```

运行测试，确认失败原因是"功能未实现"。

#### Phase B: GREEN（最小实现）

```typescript
// ✅ 最少代码让测试通过
export async function login(email: string, password: string) {
  const encodedPassword = encodeURIComponent(password); // 新增
  const result = await api.post('/login', { email, password: encodedPassword });
  return result.data;
}
```

运行测试，确认通过。

#### Phase C: REFACTOR（如需）

如果代码质量 OK，跳过此步。

---

### Step 3: 验证（2分钟）

**必选验证**:
- [ ] 新增测试通过
- [ ] 完整测试套件通过
- [ ] 无跳过的测试

**可选验证**（如适用）:
- [ ] Lint 通过
- [ ] 构建成功

---

### Step 4: 提交完成

```bash
git add <修改的文件>
git commit -m "fix: handle special chars in login password"
```

---

## Flow 模式的 TDD 简化

Flow 模式 TDD 可以更灵活：

### 可以豁免 TDD 的情况

**配置文件修改**:
```yaml
# 修改 config.yaml 的一个值
api_timeout: 30  # 改为 60
```
验证：运行系统，观察配置生效。

**纯样式调整**:
```css
/* 调整按钮颜色 */
.btn-primary { background: #007bff; }
```
验证：视觉检查，浏览器测试。

**文档修改**:
```markdown
# 更新 README.md
```
验证：检查渲染效果。

### 必须遵循 TDD 的情况

**逻辑变更** - 任何 if/else、循环、函数逻辑
**数据处理** - 解析、转换、验证
**API 修改** - 接口、路由、参数
**Bug 修复** - 必须先写复现测试

---

## Flow 示例 1: 修复 Typo

**口头提案**:
> 修复 `UserService.ts:45` 中 `recieve` 拼写错误为 `receive`

**执行**（无需 TDD，直接修改）:
```typescript
// 前：const data = await this.recieve();
// 后：const data = await this.receive();
```

**验证**:
```bash
npm run lint  # 确认无拼写错误
npm test      # 确认测试仍通过
```

**时长**: ~2 分钟

---

## Flow 示例 2: 修复密码特殊字符 Bug

**口头提案**:
> 修复 `auth/login.ts` 中密码含 # 导致 500 错误。原因是 URL 编码问题。

**执行**（遵循 TDD）:

1. **RED**: 写失败测试
```typescript
test('login with # in password', async () => {
  const result = await login('user@example.com', 'pass#word');
  expect(result.status).toBe(200);
});
```
运行 → 失败（500 错误）

2. **GREEN**: 修复
```typescript
export async function login(email: string, password: string) {
  const encoded = encodeURIComponent(password);
  return api.post('/login', { email, password: encoded });
}
```
运行 → 通过

3. **验证**:
```bash
npm test  # 全部通过
```

**时长**: ~10 分钟

---

## Flow 示例 3: 添加配置项

**口头提案**:
> 在 `config.json` 添加 `max_retries` 配置项，默认值 3。

**执行**（TDD 可选，但建议写测试）:

1. **添加配置**:
```json
{
  "api_timeout": 30,
  "max_retries": 3
}
```

2. **添加测试**:
```typescript
test('config has max_retries', () => {
  expect(config.max_retries).toBe(3);
});
```

3. **使用配置**:
```typescript
async function fetchWithRetry() {
  for (let i = 0; i < config.max_retries; i++) {
    try {
      return await fetch(url);
    } catch (e) {
      if (i === config.max_retries - 1) throw e;
    }
  }
}
```

**时长**: ~8 分钟

---

## Flow 模式快速检查清单

**提案阶段**（30秒）:
- [ ] 说清楚改什么、为什么、怎么验证
- [ ] 接口/格式变更：说明对调用方的兼容性影响

**执行阶段**（5-15分钟）:
- [ ] 逻辑变更遵循 TDD（RED → GREEN）
- [ ] 配置/样式/文档可跳过 TDD
- [ ] 代码无 TODO/FIXME 遗留
- [ ] 无调试代码遗留

**验证阶段**（2分钟）:
- [ ] 新增测试通过（如有）
- [ ] 完整测试套件通过
- [ ] Lint/构建通过（如适用）

**提交阶段**:
- [ ] Commit message 清晰（type: description）
- [ ] 无多余文件提交

---

## Flow 与 Standard 的边界

| 信号 | Flow | Standard |
|------|------|----------|
| 文件数量 | 1-2 个 | 3+ 个 |
| 需求明确度 | 完全明确 | 需要澄清 |
| 设计决策 | 无需权衡 | 需要对比方案 |
| 测试复杂度 | 单元测试 | 集成测试 + 单元测试 |
| 预计时长 | < 30 分钟 | 1-3 小时 |

**升级信号**: 如果执行过程中发现需要修改 3+ 文件或需要设计决策，停下来升级到 Standard 模式。

---

## 常见问题

### Q: Flow 模式需要创建变更目录吗？

**A**: 不需要。Flow 模式足够轻量，直接在主分支工作即可。如果担心影响，可以：
```bash
git checkout -b fix-login-bug
# 做完后
git checkout main && git merge fix-login-bug
```

**注意**: 因为不创建变更目录和 `.specpower.yaml`，Flow 模式**不支持跨会话恢复**。如果对话中断，需要手动判断进度。Flow 任务本身足够小（<30分钟），应在单次会话内完成。

### Q: Flow 模式需要审查吗？

**A**: 自我审查（30秒清单）是必需的。代码质量审查可选。

### Q: 多个 Flow 任务可以一起做吗？

**A**: 不建议。Flow 的优势是快速完成单个任务。多个任务考虑：
- 如果相关 → 升级到 Standard 模式统一规划
- 如果无关 → 逐个完成，分别提交

### Q: Flow 任务失败了怎么办？

**A**: 
- 如果是简单 bug → 调试修复
- 如果发现任务比预期复杂 → 停下来，升级到 Standard 模式重新规划

---

## 总结

Flow 模式的核心是**快速、轻量、聚焦**：
- ✅ 明确的小任务
- ✅ TDD 保证质量
- ✅ 快速验证完成
- ❌ 不做过度规划
- ❌ 不处理复杂需求

当任务符合 Flow 的适用场景时，不要过度工程化——快速完成、快速验证、快速交付。
