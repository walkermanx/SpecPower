---
name: spec-power
version: "1.12.0"
description: "SpecPower - 规范驱动的结构化开发工作流。遇到以下场景强烈建议启用:开发新功能、重构模块、跨多模块或核心系统改动、复杂bug 排查、架构设计、团队协作或需长期维护的代码。根据影响范围自动推荐三档严格度(轻量/日常/关键),按阶段推进规划、设计、执行、审查、验证——避免大改动在没有计划的情况下一路做下去翻车。适合大于单文件的任何实质改动;不适用:简单查询、单行修复、typo、阅读理解类问题。"
---

# SpecPower: 规范驱动的超能力开发工作流

> **更新日志**: [CHANGELOG.md](CHANGELOG.md)

SpecPower 融合了 OpenSpec 的结构化规划能力和 Superpowers 的执行纪律,形成一套完整的软件开发方法论。核心理念:**规划深度匹配任务复杂度, 质量门控保障关键节点, 灵活迭代而非瀑布僵化**。

---

## 🚨 收到任务后立即执行 (不可跳过)

> 这是启动 SpecPower 的**硬入口**。未按顺序执行以下步骤,视为违反流程纪律 (见 `references/discipline-recovery.md`)。

### 优先级声明 (与项目默认约束冲突时)

用户**主动调用** `/spec-power` (或该 skill 被显式加载) 即表明**选择结构化流程**。在这一入口下:

- ✅ SpecPower 的产物化要求 (`proposal.md` / `design.md` / `tasks.md` / `reviews/`) **覆盖** `CLAUDE.md` / 项目级指令中 "不要写计划文档"、"不要使用 Plan Mode"、"直接开始编码" 之类的**精简化约束**
- ✅ SpecPower 的模式判定展示要求**覆盖**项目里 "快速给结论" 的默认
- ⚠️ 仅以下情况可降级回项目默认:
  - 用户在本次对话中明确说 "按项目默认流程"、"别走 spec-power"、"直接实现不要文档"
  - 模式判定为 Flow (Flow 本就不产出文档, 与精简化约束天然兼容)
- ❌ **不得**以 "项目 CLAUDE.md 说不要写计划文档" 为理由静默跳过 Standard+ 产物 — 这是 v1.12.0 明令禁止的反模式
- 当 SpecPower 产物要求与项目编码规范 (命名、目录、变体隔离等) 冲突时, **项目编码规范优先**;产物要求和产物内容是两个维度,不互相抵消

### Step 0 — 恢复检测 (30 秒内完成)

```bash
find docs/spec-power/changes -name ".specpower.yaml" -exec grep -l "status: in-progress" {} \;
```

- 命中 → 进入 "恢复进行中的变更" 章节, **按"最小恢复"原则**加载 → 询问用户继续/新开
- 无命中 → 进入 Step 1

> ⚠️ 恢复时**禁止**主动 batch 读所有产物 (proposal/design/tasks/reviews 全部一次性读完)。这会瞬间填满刚清空的上下文 → 清空收益归零。具体加载策略见"恢复进行中的变更"章节的分级表。

### Step 1 — 模式判定 + **必须向用户展示推理**

按 "模式选择" 章节使用**强制推理格式** (见后文) 输出模式建议。**禁止**只说 "Standard 模式" 一句话, 用户无法纠正等同暗箱决策。

### Step 2 — 按模式执行分支

| 模式 | 立即动作 |
|------|---------|
| **Flow** | 口头提案获确认 → 直接 Phase 6 TDD,无需变更目录 |
| **Standard** | ① 创建变更目录 `docs/spec-power/changes/<kebab-name>/` ② 初始化 `.specpower.yaml` ③ READ `references/phase-guide-planning.md` → Phase 1.5/2 ④ **产出 `proposal.md`** 后才能进 Phase 4 |
| **Strict** | 同 Standard + 强制 Worktree + Phase 1 探索 + Phase 3 Delta 规范 |

### Step 3 — 产物锚点 (Standard+)

在完成以下产物前,**不得跳到后一阶段**:

- `proposal.md` (Phase 2 确认门) — 未落盘 ⇒ 禁止进 Phase 4
- `design.md` (Phase 4 确认门) — 未落盘 ⇒ 禁止进 Phase 5
- `tasks.md` (Phase 5) — 未落盘 ⇒ 禁止进 Phase 6
- `reviews/task-N-*.md` (Phase 6 每任务) — 未落盘 ⇒ 禁止 git commit

### 反模式 (违规示例)

- ❌ 用对话消息代替 `proposal.md` / `design.md` / `tasks.md`
- ❌ 用 `TaskCreate` 工具代替 `tasks.md` 文件 (见 "任务管理职责划分")
- ❌ 模式判定只写结论不写推理
- ❌ Standard 模式跳过变更目录直接开始改代码

---

## 关键规则速查 (铁律 / MUST)

> 以下每一条都是**禁止性约束**, 违反任一条 = 违规, **立即按 `references/discipline-recovery.md` 处置** (停止推进 → 回退状态 → 补齐产物/重做)。
> 禁止自行判断 "这条规则本次可跳过" — 规则退役必须走 `discipline-recovery.md` 的正式流程。

| # | 铁律 (禁止性) | 适用 | 违规即时动作 |
|---|--------------|------|-------------|
| R1 | **禁止**未让运行时测试失败 (runtime RED) 就改动含逻辑的代码; RED + GREEN 必须留下原始输出证据 (TDD, v1.13.0 起) | 所有 | 撤回改动 → 先建 stub → 写测试看到 runtime 断言失败 → 重新实现 → 补 RED/GREEN 证据到 `task-N-self.md` `## TDD 证据`, 见 `execution-guide.md` "Stub-first runtime RED" |
| R2 | **禁止**单个 commit 跨越 2+ 任务 (逐任务 commit) | Standard+ | 回退 HEAD, 按任务拆分重提, 见 `phase-guide-execution.md` — Phase 6 |
| R3 | **禁止**跳过 `proposal.md` 落盘直接进 Phase 4 (提案确认门) | Standard+ | 停止推进, 先落盘 proposal.md + 用户确认, 见 `phase-guide-planning.md` — Phase 2 |
| R4 | **禁止**跳过 `design.md` 落盘直接进 Phase 5 (设计确认门) | Standard+ | 停止推进, 先落盘 design.md + 用户确认, 见 `phase-guide-execution.md` — Phase 4 |
| R5 | **禁止**静默跳过任何 "触发/声明跳过" 步骤 (必须显式声明或产出) | 所有 | 回退任务状态, 补 `-skip.md` 声明或执行审查, 见 `skip-policy.md` |
| R6 | **禁止** `reviews/task-N-*.md` 未落盘就 `git commit` (产物化审查) | Standard+ | `git reset` 到 commit 前, 运行 `scripts/verify-task-reviews.sh` 补产物, 见 `review-artifact-protocol.md` |
| R7 | **禁止**未运行验证 (Phase 8) 就报告任务完成 | 所有 | 回滚完成声明, 执行验证清单, 见 `review-verify.md` |
| R8 | **禁止**用 `TaskCreate` 工具代替 Standard+ 的 `tasks.md` 落盘 | Standard+ | 补写 `tasks.md`, `TaskCreate` 仅作会话级追踪, 见下文 "任务管理职责划分" |
| R9 | **禁止**模式判定只给结论不给推理 (判定可见性) | 所有 | 按 "模式判定输出格式" 重写推理并展示给用户 |

**逐任务循环 6 步 (Standard+)**: 实现(TDD: stub → runtime RED → GREEN, 留 RED/GREEN 证据) → 自审 → 规范审查(触发/声明跳过) → 代码审查(触发/声明跳过) → 修复闭环 → `verify-task-reviews.sh` 校验 + git commit

每个审查步骤(执行或跳过)必须在 `reviews/` 产出对应 markdown 文件。具体机制:
- 产物化审查协议: `references/review-artifact-protocol.md` (含 `task-N-self.md` 的 `tdd_evidence` 必填字段与 `## TDD 证据` 章节)
- TDD 强协议 (stub-first runtime RED + 证据): `references/execution-guide.md` "Stub-first runtime RED"
- 跳过规则与有效理由: `references/skip-policy.md`
- 任务完成声明模板: `references/task-declaration.md`
- **违规处置与规则退役**: `references/discipline-recovery.md` ← 触发任一铁律违规必读

---

## 任务管理职责划分 (`tasks.md` vs `TaskCreate`)

> 两者**不是替代关系**, 是**互补关系**。混用不当 → 直接违反 R8, 按 `discipline-recovery.md` 处置。

| 维度 | `tasks.md` (落盘文件) | `TaskCreate` (会话工具) |
|------|----------------------|------------------------|
| **性质** | 产物 / 权威记录 | 会话级 UI 辅助 |
| **生命周期** | 跨会话持久, 可被 git 追溯、别人 clone 后看见 | 会话结束即丢失 |
| **Standard+ 是否必需** | ✅ **MUST** — 未落盘视为违规 R8 | ⚠️ 可选, 仅作进度可视化 |
| **Flow 是否必需** | ❌ 不需要 | ⚠️ 可选 |
| **更新方式** | Edit 工具直接改文件内容 | `TaskUpdate` 改状态 |
| **与 `.specpower.yaml` 关系** | `tasks[]` 字段引用 `tasks.md` 中的任务编号 | 不写入 yaml |
| **驱动 Phase 6 循环** | ✅ 是权威任务清单 | ❌ 仅镜像 tasks.md 的状态 |

### 正确用法

**Standard+**:
1. Phase 5 产出 `tasks.md` (权威) → 同时用 `TaskCreate` 把每个任务在会话中登记一份 (镜像)
2. Phase 6 每启动一个任务: `TaskUpdate` → `in_progress`
3. 任务完成: 先更新 `tasks.md` 勾选 + commit, **再** `TaskUpdate` → `completed`
4. **`tasks.md` 是真相之源**, `TaskCreate` 状态不一致时以文件为准

**Flow**: 任务在对话里即可, 无需 tasks.md;是否用 TaskCreate 自行决定。

### 反模式

- ❌ Standard 模式只用 `TaskCreate` 不产出 `tasks.md` — 违反 R8
- ❌ 先 `TaskCreate` 建立一堆任务, 再补写 `tasks.md` 导致编号不一致
- ❌ `tasks.md` 和 `TaskUpdate` 状态长期不一致 (单向同步丢失)

---

## 恢复进行中的变更

> **核心原则**: 恢复 = **最少必要信息加载**, 不是 "把所有产物读一遍"。后者瞬间填满刚清空的上下文 → 清空收益归零, 与 [上下文管理](#上下文管理--阶段性清空建议) 章节的设计意图直接冲突。

### 检测与定位 (30 秒内完成)

1. `find docs/spec-power/changes -name ".specpower.yaml" -exec grep -l "status: in-progress" {} \;`
2. 读取 `.specpower.yaml` 确认: 模式 / 当前 phase / 已完成产物 / 下一步 (Standard+ 看 `tasks` 字段)
3. 询问用户: **继续 / 新变更 / 查看详情**
4. 切换 worktree (如有) → 进入"按 phase 分级加载"

### 按 phase 分级加载 (按需读, 不预读)

| 当前 phase | 必读 | 按需读 (任务触发时再读) | 不要主动读 |
|-----------|------|----------------------|----------|
| Phase 1.5 / 2 (规划中) | `.specpower.yaml` + `proposal.md`(若已落盘) | 探索阶段笔记 | tasks.md / reviews/(尚不存在) |
| Phase 4 (设计中) | `.specpower.yaml` + `proposal.md` | `design.md` 半成品 | reviews/ |
| Phase 5 (拆任务) | `.specpower.yaml` + `proposal.md` + `design.md` | tasks.md 半成品 | reviews/ |
| Phase 6 (执行中) | `.specpower.yaml` + `tasks.md` 中**当前任务**条目 | 当前任务的 `reviews/task-N-*.md` | 已完成任务的 reviews 全文(用 `git log` / `git show` 按需查) / 与当前任务无关的设计章节 |
| Phase 7 (全局审查) | `.specpower.yaml` + `tasks.md` 任务清单 | `git log --oneline` 看 commit 序列、关键 reviews 摘要 | 单个任务的 reviews 全文(grep 按需切片) |
| Phase 8 (验证) | `.specpower.yaml` + 验证清单 | 测试输出、构建日志 | 设计/审查文档 |
| Phase 9 (归档, Strict) | `.specpower.yaml` + tasks.md(完成态)+ Delta 规范 | git log + reviews 摘要 | 探索期与执行期的中间笔记 |

### 恢复后向用户复述 (强制)

完成最小加载、进入下一步动作前, **必须**用以下模板向用户简短复述定位 (≤8 行):

```
## 已恢复

- **变更**: <变更名>
- **模式**: <Flow / Standard / Strict>
- **当前 phase**: <Phase N: 名称>
- **已完成**: <一行, 如 "tasks.md 落盘, 共 5 任务, task-1 已 commit">
- **下一步**: <具体动作, 如 "继续 task-2: 实现 X 接口">

是否继续?
```

> **意义**: 这一步既验证模型确实读到了关键信息(而非凭印象推进), 又给用户一个低成本纠错机会。模板**禁止**膨胀成"完整产物概要" — 越短越好, 8 行硬上限。

> Flow 模式**不创建变更目录, 不产出审查文件, 不支持跨会话恢复**, 应在单次会话内完成。

---

## 上下文管理 — 阶段性清空建议

> **背景**: spec-power 后期(尤其 Phase 6 多任务执行)会累积大量上下文 → 模型质量与速度同步下降。spec-power 的产物体系**已经支持任意点清空 + 重入**, 应主动利用此优势, 而不是任由上下文一路膨胀到对话末尾。

### 三个清空检查点 (CP)

skill **应**在以下三个过渡点向用户**主动建议**清空。这是**建议性**约束(不是铁律 R 级):用户可拒绝, 但模型不应静默跳过提示。

| 检查点 | 触发条件 | 建议时机 | 适用模式 |
|-------|---------|---------|---------|
| **CP-1** | Phase 5 → Phase 6 | `tasks.md` 已落盘 + 用户确认设计 → 进入执行**前** | Standard+ |
| **CP-2** | Phase 6 内 | 每完成 3-5 个任务 commit 后, 或主会话已读入大量代码/审查产物时 | Standard+ |
| **CP-3** | Phase 7 → Phase 8 | 全局审查完成 → 进入验证**前** | Standard+ |

### 标准建议提示模板

到达检查点时, 输出以下格式 (变量按实际填充):

```
---
🧠 **上下文压缩建议 (CP-<N>)**

当前进度: <一行总结, 如 "Phase 5 完成, tasks.md 已落盘, 5 任务待执行">
建议操作: 在新对话执行 `/clear`, 然后输入 `继续 spec-power` 或 `继续 <变更名>`
恢复行为: Step 0 会自动定位 → 按"最小恢复"原则加载 → 复述定位 → 继续推进

权衡:
- ✅ 现在清空(推荐) — 释放上下文, 后续质量与速度更稳
- ⚠️ 跳过继续累积 — 后期可能变慢/质量下降, 风险自担
---
```

### 不适用范围 (跳过 CP 的合法情形)

- **Flow 模式**: 单会话完成, 无产物, 清空 = 丢失全部进度
- **Phase 内中途**(如 Phase 4 设计写一半): 设计未落盘, 清空 = 重做
- **用户明确说**"保留上下文连续性"或"别清空"
- **当前任务依赖刚才会话里讨论的活信息**(尚未沉淀到产物)— 此时先把活信息沉淀到 `design.md` / `tasks.md` 注释, 再 CP

### 模型自约束 (即使不清空也应做)

参见 `references/execution-guide.md` 的"上下文隔离原则" — 关键约束:

- Phase 6 任务实现**必须**通过 implementer 子 agent (Claude Code), 主会话不亲自读大段代码
- 子 agent 返回**最小回报**: 任务号 / 状态 / 创建-修改文件列表 / ≤200 字关键决策摘要
- **禁止**主会话粘贴/复述子 agent 的代码 diff(在 git 与 reviews 里, 需要时按需 `git show` 切片)
- 已 commit 的任务**不要**反复回读, 用 `git log --oneline` 定位、`git show <sha>` 切片

---

## 模式选择

### Flow 模式 (快速迭代)

```
propose (口头) ──► execute (TDD) ──► verify ──► (finish)
```

**适用**: 单文件修改、小 bug 修复、typo、配置变更
**判定**: 影响 ≤ 2 文件, 无跨模块依赖, 需求明确
**特点**: 不创建变更目录, 不产出审查文件, 5-15 分钟完成

### Standard 模式 (日常开发)

```
clarify ──► propose ──► design ──► tasks ──► execute ──► review ──► verify ──► (finish)
```

**适用**: 新功能开发、多文件修改、API 变更
**判定**: 影响 3+ 文件, 涉及新接口或数据结构
**特点**: 创建变更目录, 逐任务产出 `reviews/`, 1-4 小时

### Strict 模式 (关键系统)

```
explore ──► clarify ──► propose ──► specs ──► design ──► tasks ──► execute ──► review ──► verify ──► archive ──► finish
```

**适用**: 跨模块重构、核心系统、团队协作
**判定**: 影响多模块, 行为变更需精确记录, 多人参与
**隔离**: 必须 Git Worktree 物理隔离
**特点**: Delta 规范 + 多角色设计, 逐任务强制三层审查, 1-3 天

### 模式推荐

**两阶段**: 初判 → 快速验证(边界情况)→ 确认

**初判信号**:
- Flow: "修改 X.ts" / "修 typo" / "改配置值" / "快速搞定"
- Standard: "重构 XX 模块" / "添加功能" / 涉及 API 和前端
- Strict: "跨多个模块" / "核心系统" / "团队协作" / "仔细做"

**快速验证**(~30s, 仅边界触发): Glob 扫影响范围 + Grep 耦合度 + 测试覆盖。
**边界保守原则**: 疑似标准就选标准。"快速搞定"降一档, "仔细做"升一档。

### 模式判定输出格式 (MUST — 见 R9)

模式判定**必须**向用户展示推理, 用户才有机会纠正。**禁止**只输出 "Standard 模式" 一句话。

**强制模板** (所有维度必须填写, 边界验证和降/升档条目可按需补, 未触发写 "未触发"):

```
## 模式判定

| 维度 | 观察 |
|------|------|
| 影响文件数 | <数字或 "约 N"> |
| 跨模块程度 | <单模块内 / 跨 2 模块 / 跨多模块> |
| 需求清晰度 | <清晰 / 有模糊点: ... / 模糊> |
| 新接口/数据结构 | <无 / 有: ...> |
| 团队协作/长期维护 | <是 / 否> |
| 初判信号命中 | <Flow / Standard / Strict> |
| 边界验证 (若触发) | <快速扫描结果或 "未触发"> |
| 降/升档规则 (若触发) | <"快速搞定"→降档 / "仔细做"→升档 / 未触发> |

**推荐**: <Flow / Standard / Strict>
**理由**: <一句话总结>
**用户可改**: 如需调整, 告诉我即可
```

**违反后果**: 判定只写结论不写推理 → 违反 R9 → 按 `discipline-recovery.md` 重新输出推理并向用户展示。

> 详细模式评估见 `phase-guide-planning.md` — Phase 0

---

## Phase 路由

每个 Phase 进入前按指示 READ 对应参考文件。

| Phase | 适用模式 | 入口文件 |
|-------|---------|---------|
| 变更目录初始化 | Standard+ | `phase-guide-planning.md` — 变更目录初始化 |
| Worktree 隔离 | Standard+(推荐) / Strict(必需) | `phase-guide-planning.md` — Worktree 隔离 |
| Phase 1: 探索 | Strict | `phase-guide-planning.md` — Phase 1 |
| Phase 1.5: 需求澄清 | Standard+ | `phase-guide-planning.md` — Phase 1.5 |
| Phase 2: 提案 | 所有 | `phase-guide-planning.md` — Phase 2 |
| Phase 3: 规范 | Strict | `phase-guide-planning.md` — Phase 3 + `artifact-delta-specs.md` |
| Phase 4: 设计 | Standard+ | `phase-guide-execution.md` — Phase 4 |
| Phase 5: 任务分解 | Standard+ | `phase-guide-execution.md` — Phase 5 |
| Phase 6: 执行与审查 | 所有 | `phase-guide-execution.md` — Phase 6 + `review-artifact-protocol.md` |
| Phase 7: 全局审查 | Standard+ | `phase-guide-execution.md` — Phase 7 |
| Phase 8: 验证 | 所有 | `phase-guide-execution.md` — Phase 8 |
| Phase 9: 归档 | Strict | `phase-guide-closing.md` — Phase 9 |
| Phase 10: 收尾 | 使用 Worktree 时 | `phase-guide-closing.md` — Phase 10 |

> Flow 模式只需 Phase 2 口头提案 + Phase 6 TDD + Phase 8 验证, 细节见 `flow-mode-guide.md`。

---

## Strict 模式完整性检查

进入 Strict 必须通过: 变更目录初始化 ✅ | Worktree 隔离 ✅ | Phase 1 探索 ✅ | Phase 3 Delta 规范 ✅ | Phase 4 设计 ✅ | Phase 7 全局审查 ✅ | Phase 9 归档 ✅ | Phase 10 收尾 ✅

---

## 参考资源索引

| 文件 | 内容 |
|------|------|
| `references/phase-guide-planning.md` | Phase 0~3 详细执行 |
| `references/phase-guide-execution.md` | Phase 4~8 详细执行 |
| `references/phase-guide-closing.md` | Phase 9~10 + 变更目录管理 + 平台适配 |
| `references/artifact-system.md` | 工件 DAG、状态机、`.specpower.yaml` 格式 |
| `references/artifact-delta-specs.md` | Delta 规范 + RFC 2119 + 棕地基线 (Strict) |
| `references/templates.md` | proposal / design / 多角色 / tasks 模板 |
| `references/execution-guide.md` | TDD 流程、子 agent 调度、系统调试 |
| `references/review-verify.md` | 审查方法论、验证清单、问题分级 |
| **`references/review-artifact-protocol.md`** | **产物化审查协议 (v1.11.0)** |
| **`references/skip-policy.md`** | **跳过规则与理由规范 (v1.11.0)** |
| **`references/task-declaration.md`** | **任务完成声明模板 (v1.11.0)** |
| **`references/discipline-recovery.md`** | **违规处置与规则退役 (v1.11.0)** |
| `references/mindset.md` | 反合理化与验证纪律 |
| `references/flow-mode-guide.md` | Flow 模式完整指南 |

### 子 agent 提示

| 文件 | 角色 |
|------|------|
| `agents/implementer.md` | 任务实现者 |
| `agents/spec-reviewer.md` | 规范符合审查 |
| `agents/code-reviewer.md` | 代码质量审查 |
| `agents/architect.md` | 架构师视角 (Strict) |
| `agents/perf-expert.md` | 性能专家视角 (Strict) |
| `agents/senior-dev.md` | 资深开发视角 (Strict) |

### 辅助脚本

| 脚本 | 用途 |
|------|------|
| **`scripts/verify-task-reviews.sh`** | **审查产物校验 (v1.11.0, Phase 6 Step 6 前调用)** |
| `scripts/bump-version.sh` | 自动化版本更新 |
| `scripts/link-skill.sh` | 软链接安装到各 IDE skill 目录 |
