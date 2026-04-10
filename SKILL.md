---
name: spec-power
version: "1.4.0"
description: "SpecPower - 规范驱动的开发工作流。触发关键词:'开发新功能'、'重构模块'、'复杂bug'、'架构设计'、'写计划'、'分步做'、'规范化开发'、'拆解任务'、'团队协作'、'核心系统'、'多模块'、'TDD'。自动推荐Flow(快速)/Standard(日常)/Strict(关键)三档模式。Standard+模式含需求澄清阶段(逐个澄清、方向速览、范围确认),强制测试驱动开发,三层质量审查(自审/规范审查/代码审查),支持子agent并行执行。适用于所有需要结构化规划的开发工作,不适用于简单查询或单行代码修改。"
---

# SpecPower: 规范驱动的超能力开发工作流

> **版本**: 1.4.0 | **更新日志**: [CHANGELOG.md](CHANGELOG.md)

SpecPower 融合了 OpenSpec 的结构化规划能力和 Superpowers 的执行纪律，形成一套完整的软件开发方法论。核心理念：**规划深度匹配任务复杂度，质量门控保障关键节点，灵活迭代而非瀑布僵化**。

---

## 🚀 快速开始

告诉我你的任务 → 我推荐模式(Flow/Standard/Strict) → 确认后引导你完成各阶段 → Standard+模式先澄清需求再写提案 → 自动应用TDD + 多层审查 + 子agent并行。

**新用户**: 先读"模式选择"了解三档工作流，再看"变更目录管理"了解文件组织。
**老用户**: 直接说任务，我会自动匹配模式并开始。详细方法论见下文。

---

## 模式选择

根据任务特征自动推荐模式，用户可随时覆盖。

### Flow 模式 (快速迭代)

```
propose ──► execute ──► verify ──► (finish)
```

**适用**: 单文件修改、小bug修复、简单配置变更、明确的小任务
**判定**: 影响范围 ≤ 2个文件，无跨模块依赖，需求明确无歧义

### Standard 模式 (日常开发)

```
clarify ──► propose ──► design ──► tasks ──► execute ──► review ──► verify ──► (finish)
```

**适用**: 新功能开发、多文件修改、API变更、需要设计决策的任务
**判定**: 影响 3+ 文件，涉及新接口或数据结构，需要权衡取舍

### Strict 模式 (关键系统)

```
explore ──► clarify ──► propose ──► specs ──► design ──► tasks ──► execute ──► review ──► verify ──► archive ──► finish
```

**适用**: 跨模块重构、核心系统修改、团队协作、需要长期维护的功能
**判定**: 影响多个模块，行为变更需要精确记录，多人参与或将来需要追溯
**隔离要求**: ⚠️ 必须使用 Git Worktree 物理隔离（见"变更目录管理"章节）

### 如何推荐

分析用户请求后，简短说明推荐的模式和原因：

> 这个任务涉及3个模块的接口变更，推荐 **Standard 模式**。需要先设计接口再分解任务。要切换到其他模式随时告诉我。

用户说 "快速搞定" / "简单做" → 降级一档
用户说 "仔细做" / "这个很重要" → 升级一档

---

## 工件 DAG

工件之间形成有向无环图，依赖是"使能者"而非"门控"——满足依赖的工件可以并行推进。

```
  [explore]            ← Strict: 前期调研
      ↓
  [clarify]            ← Standard+: 需求澄清
      ↓
  [proposal]           ← 所有模式: 意图和范围
    ↓        ↓
 [specs]   [design]    ← 可并行: 规范 & 设计
    ↓        ↓
     [tasks]           ← 合并依赖: 分解计划
       ↓
 [implementation]      ← 执行: TDD + 子agent
       ↓
    [review]           ← 审查: 规范 + 代码
       ↓
 [verification]        ← 验证: 实证确认
       ↓
   [archive]           ← Strict: 归档上下文
       ↓
   [finish]            ← 收尾: 分支整合 + Worktree清理
```

---

## Phase 1: 探索 (Strict)

**目标**: 在动手之前理解全局上下文。

**关键活动**: 项目扫描、现有模式理解、影响范围确定、约束发现。

**产出**: 探索结果体现在提案的 Context 部分，不单独生成文件。

> 详细执行指南见 `references/phase-guide.md` - Phase 1

---

## Phase 1.5: 需求澄清 (Standard+)

**目标**: 在写提案之前，通过对话澄清模糊需求、确认方向、控制范围。

**适用条件**: Standard 模式 1-3 个关键问题快速确认；Strict 模式完整澄清流程；Flow 模式跳过；用户需求已非常明确时可跳过。

**核心步骤**:
1. 快速上下文感知（复用 explore 结果或快速扫描）
2. 逐个澄清关键问题（一次一个，优先多选题）
3. 方向速览（2-3 个方向性选择，非完整设计）
4. 范围确认（分解大任务、过滤无关需求、YAGNI 剪枝）

**产出**: 不生成独立文件，结论直接注入后续 proposal。

**职责边界**: clarify 面向人（理解意图），explore 面向系统（理解代码），design 做技术细节。

> 详细执行指南见 `references/phase-guide.md` - Phase 1.5

---

## Phase 2: 提案

**目标**: 明确变更的动机、范围和影响。

**Flow模式**: 一段话说清楚改什么、为什么、怎么验证。

**Standard/Strict模式**: 创建 `proposal.md`，包含动机、变更范围、影响分析、成功标准。

**自审要点**: 无占位符、动机清晰、范围明确、影响完整。

> 详细格式和模板见 `references/phase-guide.md` - Phase 2 和 `references/artifact-system.md`

---

## Phase 3: 规范 (Strict)

**目标**: 用Delta格式精确描述行为变更。

**格式**: 使用 ADDED/MODIFIED/REMOVED 三种操作 + RFC 2119 关键词（MUST/SHALL/SHOULD/MAY）。

**场景编写**: 每个需求至少一个 GIVEN-WHEN-THEN 场景，可直接转化为测试用例。

**自审要点**: 场景可测试、MODIFIED标注原行为、REMOVED提供迁移方案、无实现细节。

> 详细格式、示例和模板见 `references/phase-guide.md` - Phase 3 和 `references/artifact-system.md`

---

## Phase 4: 设计 (Standard+)

**目标**: 记录技术决策和权衡，解释"为什么这样做"。

**必需内容**: 现状、至少2个方案对比、决策理由、关键设计细节、风险与缓解。

**自审要点**: 多方案对比、决策理由具体、接口定义精确、识别风险。

**Strict 模式增强：多角色方案对比**

Strict 模式在设计阶段引入三视角并行方案设计，从不同优化目标出发产出竞争性方案，避免单一视角的确认偏误：

```
[共享上下文] 主设计者产出现状/目标/约束
      ↓
[三角色并行] 架构师 + 性能专家 + 资深开发 各出聚焦方案（子agent）
      ↓
[技术负责人] 5维度对比矩阵 + 推荐方案
      ↓
[用户评审] 选择或要求修订 → 通过后展开为完整 design.md
```

- **架构师**：系统分层、模块解耦、可扩展性、长期可维护性
- **性能专家**：响应速度、内存占用、IO优化、并发处理、瓶颈预防
- **资深开发**：开发效率、代码简洁、快速上线、技术债务控制
- **技术负责人对比维度**：架构合理性、性能表现、开发成本、可维护性、风险程度

无子agent时降级为顺序内联：主agent依次切换视角，产出格式不变。

> 详细格式和模板见 `references/phase-guide.md` - Phase 4 和 `references/artifact-system.md`
> 三角色子agent提示见 `agents/architect.md`、`agents/perf-expert.md`、`agents/senior-dev.md`

---

## Phase 5: 任务分解 (Standard+)

**目标**: 将设计转化为2-5分钟粒度的可执行任务。

**任务结构**: 文件映射（Create/Modify/Test）+ 依赖关系 + TDD步骤 + 验证命令。

**分解原则**: 独立可验证、文件映射精确、依赖标注清楚、无占位符、每步含验证命令。

**自审要点**: 所有组件有任务、依赖形成DAG、可并行已标注、TDD驱动。

> 详细格式和模板见 `references/phase-guide.md` - Phase 5 和 `references/artifact-system.md`

---

## Phase 6: 执行

**目标**: 产出经过TDD验证的代码实现。

**执行方式**: 
- **子agent并行**（Claude Code）：无依赖任务并行dispatch
- **内联顺序**（其他平台）：按依赖顺序逐个执行

**TDD铁律**: RED → 验证RED → GREEN → 验证GREEN → REFACTOR。如果在没有失败测试的情况下写了生产代码，停下来删掉，先写测试。

**系统调试**: 遇到问题使用四阶段法——根因调查、假设形成、验证、修复。

> 详细执行指南和TDD流程见 `references/execution-guide.md` 和 `references/phase-guide.md` - Phase 6
> 子agent提示模板见 `agents/implementer.md`

---

## Phase 7: 审查 (Standard+)

**目标**: 通过三层质量网在不同层面捕获问题。

**第一层：自我审查**（所有模式，30秒）- 代码完整性、测试覆盖、安全基线。

**第二层：规范符合审查**（Strict，子agent）- 对比specs/检查实现覆盖和正确性。

**第三层：代码质量审查**（Standard+，子agent）- 架构设计、代码质量、安全性、可维护性。

**问题分级**: Critical（必须修复）/ Important（应该修复）/ Suggestion（不阻塞）。

> 详细审查方法和清单见 `references/review-verify.md` 和 `references/phase-guide.md` - Phase 7
> 子agent提示见 `agents/spec-reviewer.md` 和 `agents/code-reviewer.md`

---

## Phase 8: 验证

**目标**: 提供可验证的证据证明变更达到预期。

**验证原则**: 运行而非声称、完整而非抽样、真实而非模拟、捕获输出。

**验证清单**: 
- 必选（所有模式）：完整测试套件、新增测试、无跳过测试
- Standard+额外：构建、lint、类型检查
- Strict额外：规范场景覆盖、性能基准、安全扫描

> 详细验证方法和报告模板见 `references/review-verify.md` 和 `references/phase-guide.md` - Phase 8

---

## Phase 9: 归档 (Strict)

**目标**: 保留上下文供将来追溯。

**步骤**: 合并Delta规范到主规范、移动变更目录到archive、保留完整工件。

**价值**: 历史追溯、模式复用、团队学习。

> 详细归档流程见 `references/phase-guide.md` - Phase 9

---

## Phase 10: 收尾清理

**目标**: 闭合 Worktree 生命周期，整合分支，清理隔离环境。

**适用**: 所有使用了 Git Worktree 的变更（Strict 必需，Standard/Flow 如果创建了 worktree 也适用）。未使用 worktree 的变更跳过此阶段。

**前置条件**: 验证通过（Phase 8），归档完成（Phase 9，如适用）。

**结构化选项**（提供给用户选择，不问开放性问题）:

1. **合并到主分支** — 切到主分支 → pull → merge → 验证测试 → 删除 worktree 和分支
2. **推送并创建 PR** — push → gh pr create → 保留 worktree 直到 PR 合并
3. **保留当前状态** — 不清理，用户稍后自行处理
4. **废弃变更** — 需用户确认 → 删除 worktree 和分支（force delete）

**安全原则**: 测试未通过不提供选项；废弃需确认；合并后再次验证测试。

**平台适配**:
- Claude Code: 使用 `ExitWorktree(action="remove"/"keep")`
- 其他平台: 输出对应的 `git worktree remove` / `git branch -d` 命令

**完成后**: 更新 `.specpower.yaml` 中 status 为 `done`（选项1/2）或 `archived`（选项4）。

> 详细执行步骤见 `references/phase-guide.md` - Phase 10
> 收尾脚本: `scripts/finish-change.sh`

---

## 变更目录管理

### 创建变更

**命名格式**: `<change-name>-YYYYMMDDHHMMSS`

变更目录名称包含时间戳，避免命名冲突并自动记录创建时间。

**示例**:
- `add-user-auth-20260408143025` - 2026年4月8日 14:30:25 创建
- `refactor-payment-20260410091530` - 2026年4月10日 09:15:30 创建

```bash
mkdir -p docs/spec-power/changes/<change-name>-YYYYMMDDHHMMSS
```

### 元数据文件

`docs/spec-power/changes/<change-name>-YYYYMMDDHHMMSS/.specpower.yaml`:

```yaml
name: <change-name>-YYYYMMDDHHMMSS
mode: standard          # flow | standard | strict
created: 2026-04-08
status: in-progress     # in-progress | review | done | archived
```

### Git Worktree 隔离

**Strict 模式必需，Standard/Flow 可选**

使用 worktree 提供物理隔离，确保关键变更不影响主分支：

```
主分支: main
工作分支: spec-power/<change-name>-YYYYMMDDHHMMSS
Worktree: .worktrees/<change-name>-YYYYMMDDHHMMSS/
```

**示例**:
```
变更: add-user-auth-20260408143025
分支: spec-power/add-user-auth-20260408143025
目录: .worktrees/add-user-auth-20260408143025/
```

**执行方式**:

**Claude Code (自动)**:
```
我会自动调用 EnterWorktree(name="<change-name>-YYYYMMDDHHMMSS") 创建隔离环境
```

**其他平台 (手动)**:
```bash
git worktree add .worktrees/<change-name>-YYYYMMDDHHMMSS -b spec-power/<change-name>-YYYYMMDDHHMMSS
cd .worktrees/<change-name>-YYYYMMDDHHMMSS
```

**双重隔离**：
- 变更目录: 逻辑隔离（工件组织）`docs/spec-power/changes/<change-name>-YYYYMMDDHHMMSS/`
- Worktree: 物理隔离（代码分支）`.worktrees/<change-name>-YYYYMMDDHHMMSS/`

Strict 模式下两者必须组合使用。

---

## 平台适配

| 能力 | Claude Code | Cursor | Copilot/其他 |
|------|------------|--------|-------------|
| 子agent并行 | Yes | No | No |
| 多角色设计 (Strict) | 3子agent并行 | 顺序内联 | 顺序内联 |
| Git worktree (Strict) | 自动 | 手动必需 | 手动必需 |
| Git worktree (Standard/Flow) | 自动 | 手动可选 | 手动可选 |
| Worktree 收尾清理 | ExitWorktree | 手动/脚本 | 手动/脚本 |
| 工件系统 | Yes | Yes | Yes |
| TDD流程 | Yes | Yes | Yes |
| 两阶段审查 | 子agent | 内联 | 内联 |

无子agent时的降级策略：
- 多角色设计改为顺序内联（主agent依次切换视角）
- 审查改为自我审查（用清单代替独立子agent）
- 并行执行改为顺序执行
- 所有工件和质量规则不变

---

## 快速参考

### 开始新变更

使用初始化脚本（推荐）:
```bash
./scripts/init-change.sh <change-name> [mode]
# 自动添加时间戳，生成完整目录结构
```

或手动：确定模式 → 写提案 → 按模式执行剩余阶段

### 收尾变更

使用收尾脚本（推荐）:
```bash
./scripts/finish-change.sh <change-name-with-timestamp> [merge|pr|keep|discard]
# 整合分支、清理 worktree、更新状态
```

或手动：按 Phase 10 步骤操作

### 参考资源

**完整指南**:
- `references/phase-guide.md` — 各Phase详细执行步骤（新增）
- `references/artifact-system.md` — 工件类型、DAG模型、Delta规范、所有模板
- `references/execution-guide.md` — TDD详细流程、子agent调度、系统调试
- `references/review-verify.md` — 审查方法论、验证清单、问题分级
- `references/mindset.md` — 反理性化与最佳实践心态

**子agent提示**:
- `agents/implementer.md` — 任务实现者
- `agents/spec-reviewer.md` — 规范符合审查
- `agents/code-reviewer.md` — 代码质量审查
- `agents/architect.md` — 架构师视角设计（Strict）
- `agents/perf-expert.md` — 性能专家视角设计（Strict）
- `agents/senior-dev.md` — 资深开发视角设计（Strict）

**示例和工具**:
- `examples/add-user-avatars/` — Standard模式端到端示例（含Strict多角色方案对比示例）
- `scripts/init-change.sh` — 自动创建变更目录结构
