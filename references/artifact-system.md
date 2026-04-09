# 工件系统详解

## DAG 模型

工件形成有向无环图（DAG），依赖关系决定了创建顺序，但不是硬性门控——满足依赖的工件可以并行创建。

### 工件定义

| 工件 | 生成文件 | 依赖 | 所属模式 |
|------|---------|------|---------|
| explore | (内嵌于proposal) | 无 | Strict |
| proposal | `proposal.md` | 无 | 所有 |
| specs | `specs/**/*.md` | proposal | Strict |
| design | `design.md` | proposal | Standard+ |
| tasks | `tasks.md` | specs(如有) + design | Standard+ |
| implementation | 源代码 | tasks(Standard+) 或 proposal(Flow) | 所有 |
| review | (审查记录) | implementation | Standard+ |
| verification | (验证报告) | implementation | 所有 |
| archive | `archive/` 目录 | verification | Strict |

### 状态转移

每个工件有三种状态：

```
BLOCKED ──► READY ──► DONE
```

- **BLOCKED**: 有未完成的依赖
- **READY**: 所有依赖已完成，可以开始创建
- **DONE**: 文件已存在且通过自审

### 并行机会

在 Strict 模式中，specs 和 design 都只依赖 proposal，可以并行创建。识别这种机会能显著加速工作流。

---

## Delta 规范

Delta 规范是 Strict 模式的核心概念，描述的是行为**变更**而非完整规范。这使得多个变更可以并行进行而不产生冲突。

### 为什么用 Delta 而非全规范

1. **清晰性** — 一眼看出改了什么
2. **冲突避免** — 多个变更可触及同一 spec 而无冲突
3. **审查高效** — 只看改动，无需心理 diff
4. **棕地友好** — 对已有系统的修改是一级概念

### Delta 格式详解

每个 Delta spec 包含三种操作：

#### ADDED — 新增需求

```markdown
## ADDED Requirements

### Requirement: 用户头像上传
系统 SHALL 允许用户上传 JPEG 或 PNG 格式的头像图片。
系统 MUST 限制上传文件大小不超过 5MB。

#### Scenario: 成功上传头像
- **GIVEN** 一个已登录用户
- **WHEN** 用户上传一张 2MB 的 JPEG 图片
- **THEN** 系统保存图片并返回图片 URL
- **AND** 用户的个人资料页显示新头像

#### Scenario: 文件过大
- **GIVEN** 一个已登录用户
- **WHEN** 用户上传一张 6MB 的图片
- **THEN** 系统返回错误提示"文件大小不能超过 5MB"
- **AND** 原头像保持不变
```

#### MODIFIED — 修改现有需求

```markdown
## MODIFIED Requirements

### Requirement: 会话过期
系统 MUST 在 30 分钟不活动后过期会话。
(之前: 系统 MUST 在 60 分钟不活动后过期会话。)

#### Scenario: 空闲超时
- **GIVEN** 一个活跃会话
- **WHEN** 30 分钟内无任何请求
- **THEN** 会话标记为过期
- **AND** 下次请求返回 401 并要求重新认证
```

#### REMOVED — 删除需求

```markdown
## REMOVED Requirements

### Requirement: Legacy XML 导出
**原因**: 所有客户端已迁移到 JSON API，XML 端点零流量
**迁移**: 使用 `/api/v2/export?format=json`
**生效日期**: 下个版本
```

### RFC 2119 关键词使用

| 关键词 | 含义 | 用法 |
|--------|------|------|
| MUST / SHALL | 绝对要求 | 违反即为 bug |
| MUST NOT / SHALL NOT | 绝对禁止 | 违反即为 bug |
| SHOULD | 推荐做法 | 可以不做但需要充分理由 |
| SHOULD NOT | 不推荐做法 | 可以做但需要充分理由 |
| MAY | 可选行为 | 实现者自行决定 |

### 场景编写指南

好的场景可以直接转化为测试用例：

**好场景** — 具体、可验证：
```markdown
#### Scenario: 并发修改冲突
- **GIVEN** 用户 A 和 B 同时编辑同一文档
- **WHEN** 用户 A 先保存，用户 B 随后保存
- **THEN** 系统检测到冲突
- **AND** 用户 B 收到冲突提示并展示 diff
```

**差场景** — 模糊、不可测试：
```markdown
#### Scenario: 系统性能良好
- **WHEN** 有很多用户
- **THEN** 系统运行流畅
```

### Delta 合并

归档时，Delta 规范会合并到主规范中：

1. ADDED → 追加到主规范相应 section
2. MODIFIED → 替换主规范中的对应需求块
3. REMOVED → 从主规范中删除对应需求

---

## 工件模板

### proposal.md 完整模板

```markdown
# <变更名称>

## 动机
<为什么要做这个变更？解决什么问题？有什么背景？>

## 变更范围

### 新增能力
- `<capability-id>`: <一句话描述>

### 修改能力
- `<capability-id>`: <什么变了，之前是什么>

### 不在范围内
- <明确列出不做的事情，避免范围蔓延>

## 影响分析

### 向后兼容性
<是否兼容？不兼容的话如何处理？>

### 性能影响
<预期的性能变化>

### 安全考虑
<是否引入新的攻击面？>

### 依赖变化
<新增或移除的依赖>

## 成功标准
<怎么算"做完了"？可量化的指标>
```

### design.md 完整模板

```markdown
# <变更名称> 技术设计

## 现状
<当前系统相关部分如何工作>

## 目标
- <目标 1>
- <目标 2>

## 非目标
- <明确不追求的目标>

## 方案对比

### 方案 A: <名称> (推荐)
<核心思路描述>

**优势**:
- ...

**劣势**:
- ...

**实现复杂度**: 低/中/高

### 方案 B: <名称>
<核心思路描述>

**优势**:
- ...

**劣势**:
- ...

## 决策
选择方案 A。
<决策理由，具体到为什么 A 的优势比 B 更重要>

## 关键设计

### 数据模型
<新增或修改的数据结构>

### 接口设计
<API、函数签名、事件>

### 错误处理
<错误类型和处理策略>

## 风险与缓解

| 风险 | 概率 | 影响 | 缓解措施 |
|------|------|------|---------|
| ... | 低/中/高 | 低/中/高 | ... |

## 迁移计划 (如需)
<分步部署、数据迁移、回滚方案>
```

### tasks.md 完整模板

```markdown
# <变更名称> 实现计划

> **执行方式**: 使用 spec-power 执行阶段

**目标**: <一句话>
**架构**: <2-3句话概括>
**技术栈**: <关键技术>

## Task 1: <组件名>

**文件**:
- Create: `<精确路径>`
- Modify: `<精确路径>`
- Test: `<精确路径>`

**依赖**: 无 (可并行)

**步骤**:
- [ ] 编写失败测试: `<具体描述测试什么>`
  验证: `<运行命令>` → 期望失败
- [ ] 最小实现使测试通过
  验证: `<运行命令>` → 期望全部通过
- [ ] 重构 (如需)
  验证: `<运行命令>` → 保持全部通过
- [ ] 提交: `git commit -m "<commit message>"`

## Task 2: <组件名>

**文件**: ...
**依赖**: Task 1 (需要其导出的接口)

**步骤**:
- [ ] ...

---

## 依赖图

```
Task 1 ──► Task 3
Task 2 ──► Task 3
Task 3 ──► Task 4
```

可并行: Task 1, Task 2
```

---

## .specpower.yaml 格式

```yaml
name: add-user-avatars
mode: standard              # flow | standard | strict
created: 2026-04-07
status: in-progress          # in-progress | review | done | archived
artifacts:
  proposal: done
  design: done
  tasks: in-progress
  implementation: blocked
  review: blocked
  verification: blocked
```
