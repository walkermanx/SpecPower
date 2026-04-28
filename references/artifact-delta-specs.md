# Delta 规范与基线规范(Strict 模式专用)

本文档讲 Strict 模式下规范(`specs/**/*.md`)的格式与编写规则,以及棕地项目首次使用 Strict 时需要生成的局部基线规范。Flow 和 Standard 模式不产出 specs 工件,可跳过本文档。

- **Delta 规范**: 描述行为**变更**的精确语言(ADDED/MODIFIED/REMOVED + RFC 2119 + Scenario),存放于变更目录 `docs/spec-power/changes/<name>/specs/**/*.md`
- **基线规范**: 棕地首次使用 Strict 且涉及 MODIFIED/REMOVED 时,在 Phase 1 按需生成的"当前系统行为"记录,存放于主规范目录 `docs/spec-power/specs/<domain>/spec.md`,归档合并后成为正式主规范的一部分

---

## 为什么用 Delta 而非全规范

1. **清晰性** — 一眼看出改了什么
2. **冲突避免** — 多个变更可触及同一 spec 而无冲突
3. **审查高效** — 只看改动,无需心理 diff
4. **棕地友好** — 对已有系统的修改是一级概念
5. **基线按需生成** — 棕地项目首次使用时,仅为涉及 MODIFIED/REMOVED 的模块生成局部基线,不需要为整个系统写规范

---

## Delta 格式详解

每个 Delta spec 包含三种操作:

### ADDED — 新增需求

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

### MODIFIED — 修改现有需求

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

### REMOVED — 删除需求

```markdown
## REMOVED Requirements

### Requirement: Legacy XML 导出
**原因**: 所有客户端已迁移到 JSON API,XML 端点零流量
**迁移**: 使用 `/api/v2/export?format=json`
**生效日期**: 下个版本
```

---

## RFC 2119 关键词使用

| 关键词 | 含义 | 用法 |
|--------|------|------|
| MUST / SHALL | 绝对要求 | 违反即为 bug |
| MUST NOT / SHALL NOT | 绝对禁止 | 违反即为 bug |
| SHOULD | 推荐做法 | 可以不做但需要充分理由 |
| SHOULD NOT | 不推荐做法 | 可以做但需要充分理由 |
| MAY | 可选行为 | 实现者自行决定 |

---

## 场景编写指南

好的场景可以直接转化为测试用例。

**好场景** — 具体、可验证:

```markdown
#### Scenario: 并发修改冲突
- **GIVEN** 用户 A 和 B 同时编辑同一文档
- **WHEN** 用户 A 先保存,用户 B 随后保存
- **THEN** 系统检测到冲突
- **AND** 用户 B 收到冲突提示并展示 diff
```

**差场景** — 模糊、不可测试:

```markdown
#### Scenario: 系统性能良好
- **WHEN** 有很多用户
- **THEN** 系统运行流畅
```

---

## Delta 合并(Phase 9 归档时)

归档时,Delta 规范会合并到主规范中:

1. ADDED → 追加到主规范相应 section
2. MODIFIED → 替换主规范中的对应需求块
3. REMOVED → 从主规范中删除对应需求

**棕地首次合并**(主规范 `docs/spec-power/specs/<domain>/spec.md` 不存在时):

- 有 Phase 1 生成的局部基线 → 以基线为起点,应用 Delta 操作,生成主规范
- 无基线且全是 ADDED → 直接用 ADDED 内容创建主规范
- 合并完成后移除基线文件的 `type: baseline` frontmatter 元信息

---

## 基线规范格式(棕地项目局部基线)

当棕地项目首次使用 Strict 模式且涉及 MODIFIED/REMOVED 时,Phase 1 探索阶段按需生成局部基线。基线使用标准 Requirement + Scenario 格式(非 Delta),描述"当前系统的行为是什么"。

### 基线与 Delta 的区别

| 维度 | 基线规范 | Delta 规范 |
|------|---------|-----------|
| 描述内容 | 当前行为(是什么) | 行为变更(改什么) |
| 格式 | 标准 Requirement + Scenario | ADDED/MODIFIED/REMOVED 操作 |
| 存放位置 | `docs/spec-power/specs/<domain>/spec.md` | `docs/spec-power/changes/<name>/specs/<domain>/spec.md` |
| 覆盖范围 | 仅本次变更涉及的 Requirement | 本次变更的所有行为变更 |
| 生命周期 | 归档后成为主规范的一部分 | 归档后移入 archive |

### 基线模板

```markdown
---
type: baseline
generated: <YYYY-MM-DD>
scope: partial
change: <change-name>-YYYYMMDDHHMMSS
---

# <模块名称> 现有行为规范

> 局部基线,仅覆盖变更 `<change-name>` 涉及的需求。基于 Phase 1 探索阶段的代码阅读生成。

## Requirements

### Requirement: <需求名>
<当前行为描述,使用 RFC 2119 关键词>

#### Scenario: <场景名>
- **GIVEN** <前置条件>
- **WHEN** <触发动作>
- **THEN** <预期结果>
- **AND** <额外条件或结果>
```

### 注意事项

- 基线仅覆盖本次变更涉及的 Requirement,不需要完整描述整个模块
- `scope: partial` 标明这是局部基线,后续变更可逐步补充
- 归档合并后,基线内容被 Delta 操作更新,frontmatter 元信息被移除,成为正式主规范的一部分
