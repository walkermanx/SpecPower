---
name: spec-power
version: "1.11.0"
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

- 命中 → 进入 "恢复进行中的变更" 章节, 询问用户继续/新开
- 无命中 → 进入 Step 1

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

## 关键规则速查 (必须遵守)

> SpecPower 的铁律。违反任一条都会导致流程失效。具体操作见对应 references。

| 规则 | 适用模式 | 权威出处 |
|------|---------|---------|
| **逐任务 TDD** | 所有 | `execution-guide.md` |
| **逐任务 commit** | Standard+ | `phase-guide-execution.md` — Phase 6 提交门控 |
| **提案确认门** | Standard+ | `phase-guide-planning.md` — Phase 2 |
| **设计确认门** | Standard+ | `phase-guide-execution.md` — Phase 4 |
| **禁止静默跳过** | 所有 | `skip-policy.md` |
| **产物化审查** (v1.11.0) | Standard+ | `review-artifact-protocol.md` |
| **验证必须运行** | 所有 | `review-verify.md` |

**逐任务循环 6 步 (Standard+)**: 实现(TDD) → 自审 → 规范审查(触发/声明跳过) → 代码审查(触发/声明跳过) → 修复闭环 → `verify-task-reviews.sh` 校验 + git commit

每个审查步骤(执行或跳过)必须在 `reviews/` 产出对应 markdown 文件, 详见 `review-artifact-protocol.md`。跳过规则见 `skip-policy.md`, 任务完成声明模板见 `task-declaration.md`, 违规处置与规则退役机制见 `discipline-recovery.md`。

---

## 恢复进行中的变更

新对话进入项目时检测:

1. `find docs/spec-power/changes -name ".specpower.yaml" -exec grep -l "status: in-progress" {} \;`
2. 读取 `.specpower.yaml` 确认模式、工件状态、`tasks` 字段(Standard+)
3. 询问用户: 继续 / 新变更 / 查看详情
4. 切换 worktree(如有)→ 加载工件 → 从首个 `blocked`/`pending` 工件继续

> Flow 模式**不创建变更目录, 不产出审查文件, 不支持跨会话恢复**, 应在单次会话内完成。

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
