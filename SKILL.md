---
name: spec-power
version: "1.7.0"
description: "SpecPower - 规范驱动的开发工作流。触发关键词:'开发新功能'、'重构模块'、'复杂bug'、'架构设计'、'写计划'、'分步做'、'规范化开发'、'拆解任务'、'团队协作'、'核心系统'、'多模块'、'TDD'。自动推荐Flow(快速)/Standard(日常)/Strict(关键)三档模式。Standard+模式含需求澄清阶段(逐个澄清、方向速览、范围确认),强制测试驱动开发,三层质量审查(自审/规范审查/代码审查),支持子agent并行执行。Strict模式Phase 4采用多角色方案对比(架构师/性能专家/资深开发三视角)。适用于所有需要结构化规划的开发工作,不适用于简单查询或单行代码修改。"
---

# SpecPower: 规范驱动的超能力开发工作流

> **更新日志**: [CHANGELOG.md](CHANGELOG.md)

SpecPower 融合了 OpenSpec 的结构化规划能力和 Superpowers 的执行纪律，形成一套完整的软件开发方法论。核心理念：**规划深度匹配任务复杂度，质量门控保障关键节点，灵活迭代而非瀑布僵化**。

---

## 恢复进行中的变更

如果你在新对话中打开项目，检测到有进行中的变更时：

1. **扫描变更目录**
   ```bash
   [ -d docs/spec-power/changes ] && find docs/spec-power/changes -name ".specpower.yaml" -exec grep -l "status: in-progress" {} \;
   ```
   **注意**: Flow 模式不创建变更目录，因此不支持跨会话恢复。Flow 任务应在单次会话内完成。

2. **读取变更状态**
   - 读取 `.specpower.yaml` 确认模式、工件状态
   - 读取已完成的工件（proposal, design, tasks 等）

3. **向用户确认**
   ```
   检测到进行中的变更：
   - 变更名: add-user-auth-20260408143025
   - 模式: Standard
   - 当前阶段: implementation (3/5 tasks 完成)
   
   是否继续这个变更？
   1. 继续 - 从上次中断处继续
   2. 新变更 - 开始新的变更
   3. 查看详情 - 显示完整状态
   ```

4. **恢复上下文**
   - 切换到对应的 worktree（如果存在）
   - 加载已完成工件到上下文
   - 从第一个 `blocked` 或 `pending` 工件继续

**注意**: 如果有多个 `in-progress` 变更，列出所有并让用户选择。

---

## 快速开始

告诉我你的任务 → 我初判模式并快速验证(边界情况时) → 确认推荐模式 → 引导你完成各阶段 → Standard+模式先澄清需求再写提案 → 自动应用TDD + 多层审查 + 子agent并行。

**新用户**: 先读"模式选择"了解三档工作流，再看"变更目录管理"了解文件组织。
**老用户**: 直接说任务，我会自动匹配模式并开始。详细方法论见下文。

---

## 模式选择

根据任务特征自动推荐模式，用户可随时覆盖。

### Flow 模式 (快速迭代)

```
propose ──► execute ──► verify ──► (finish)
          (含TDD+自我审查30秒)
```

**适用**: 单文件修改、小bug修复、简单配置变更、明确的小任务
**判定**: 影响范围 ≤ 2个文件，无跨模块依赖，需求明确无歧义

> 详细 Flow 模式指南见 `references/flow-mode-guide.md`

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

**⚠️ Strict 模式完整性检查**：

进入 Strict 模式后，必须通过以下检查点：

**前置条件** — 确保正确启动：
- ✅ **Worktree 隔离** (Phase 0): 已创建 Git Worktree（`git worktree list` 验证）

**关键门控** — 保障质量：
- ✅ **探索阶段** (Phase 1): 全局上下文理解完成（现状/约束/影响范围）
- ✅ **规范阶段** (Phase 3): Delta 规范已生成（ADDED/MODIFIED/REMOVED 格式）
- ✅ **设计阶段** (Phase 4): 技术方案确定（多角色对比或单一方案说明）
- ✅ **全局审查** (Phase 7): 跨任务一致性检查完成（接口对接 + 整体架构）
- ✅ **归档阶段** (Phase 9): 上下文归档完成（specs 合并 + 目录移动）

**完成条件** — 正确收尾：
- ✅ **收尾清理** (Phase 10): Worktree 清理已执行（4 选项之一）

**说明**: Phase 1.5（需求澄清）为可选阶段，跳过条件已在 Phase 1.5 章节定义，不需要独立检查。Phase 2（提案）、Phase 5（任务）由工件 DAG 保障，Phase 6（执行+逐任务审查）由 TDD 铁律和修复→重审闭环保障，Phase 8（验证）由验证清单保障，不需要独立检查。缺失任何一项检查点需立即提醒用户。

### 如何推荐

采用两阶段推荐流程：**初判 → 快速验证（可选）→ 确认**

#### 初判（即时）

基于用户描述中的关键信号：
- 文件影响范围（"修改 login.ts" vs "重构认证模块"）
- 是否提到跨模块/核心系统
- 需求明确度（"改配置" vs "优化性能"）
- 用户语气信号（"快速搞定" vs "仔细做"）

#### 快速验证（~30秒，仅在边界情况时触发）

**触发条件**（任一满足即触发）：
- 用户描述模糊，无法判断影响范围（如"改一下登录"、"优化性能"）
- 初判在 Standard/Strict 边界上犹豫
- 用户提到的模块/功能不了解其复杂度

**跳过条件**（任一满足即跳过）：
- 任务明显简单（"修个 typo"、"改配置值"）→ 直接推荐 Flow
- 用户明确说了模式偏好（"用 Strict"）
- 用户提供了足够上下文（"涉及 3 个模块、需要改数据库 schema"）

**验证内容**（快速，不是完整的 Phase 1 探索）：
1. Glob 扫描用户提到的文件/目录，确认实际影响范围
2. Grep 检查关键接口/函数的引用数量，判断耦合度
3. 检查是否有测试覆盖（有无 test 文件）
4. 评估架构影响（是否跨模块、是否影响核心系统）

**验证后调整（边界保守原则）**：
- 初判 Flow 但发现影响 3+ 文件 → 升级 Standard
- 初判 Standard 但发现**同时满足**以下2+条件 → 升级 Strict：
  * 跨 5+ 模块（不是 4+，提高阈值）
  * 无测试覆盖 **且** 是核心系统
  * 团队协作或多人维护
  * 涉及数据格式变更或 breaking change
- 初判 Strict 但发现只影响 1-2 个文件 **且** 无跨模块依赖 → 降级 Standard

**⚠️ 边界判定保守原则**（P0改进）：
- Standard/Strict 边界：**疑似标准就选标准**，避免过度工程化
- 单一功能增强（如"支持自定义铃声"）→ Standard，不升级
- 仅在明确多模块重构或核心系统变更时才推荐 Strict

#### 确认模式

向用户说明最终推荐，如果与初判不同要解释原因：

> 初看这是个 Standard 级别的任务，但我快速扫描了 `src/auth/` 模块后发现它涉及 12 个文件、跨 3 个模块且没有测试覆盖，升级推荐为 **Strict 模式**。

用户说 "快速搞定" / "简单做" → 降级一档
用户说 "仔细做" / "这个很重要" → 升级一档
用户可随时覆盖推荐（"用 Standard 就行"）

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
 [implementation]      ← 执行+逐任务审查: TDD + 审查闭环
       ↓
    [review]           ← 全局审查: 跨任务一致性 (Standard+)
       ↓                  (Flow 跳过, verification 直接依赖 implementation)
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

> ⚠️ 进入此阶段前，READ `references/phase-guide-planning.md` - Phase 1

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

> ⚠️ 进入此阶段前，READ `references/phase-guide-planning.md` - Phase 1.5

---

## Phase 2: 提案

**目标**: 明确变更的动机、范围和影响。

**Flow模式**: 一段话说清楚改什么、为什么、怎么验证。

**Standard/Strict模式**: 创建 `proposal.md`，包含动机、变更范围、影响分析、成功标准。

**自审要点**: 无占位符、动机清晰、范围明确、影响完整。

> ⚠️ 进入此阶段前，READ `references/phase-guide-planning.md` - Phase 2 和 `references/artifact-system.md`

---

## Phase 3: 规范 (Strict)

**目标**: 用Delta格式精确描述行为变更。

**格式**: 使用 ADDED/MODIFIED/REMOVED 三种操作 + RFC 2119 关键词（MUST/SHALL/SHOULD/MAY）。

**场景编写**: 每个需求至少一个 GIVEN-WHEN-THEN 场景，可直接转化为测试用例。

**自审要点**: 场景可测试、MODIFIED标注原行为、REMOVED提供迁移方案、无实现细节。

> ⚠️ 进入此阶段前，READ `references/phase-guide-planning.md` - Phase 3 和 `references/artifact-system.md`

---

## Phase 4: 设计 (Standard+)

**目标**: 记录技术决策和权衡，解释"为什么这样做"。

**必需内容**: 现状、至少2个方案对比、决策理由、关键设计细节、风险与缓解。

**自审要点**: 多方案对比、决策理由具体、接口定义精确、识别风险。

**Strict 模式增强：多角色方案对比**

Strict 模式在设计阶段引入三视角并行方案设计，从不同优化目标出发产出竞争性方案，避免单一视角的确认偏误。

**快速退出条件**: 如果设计空间明显单一（只有一种合理方案，例如"给所有 API 添加统一日志格式"），可跳过多角色对比。在 design.md 方案对比章节说明"仅一种可行方案"并解释原因即可。

**完整流程**（设计空间充足时）:

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

> ⚠️ 进入此阶段前，READ `references/phase-guide-execution.md` - Phase 4 和 `references/artifact-system.md`
> 三角色子agent提示见 `agents/architect.md`、`agents/perf-expert.md`、`agents/senior-dev.md`

---

## Phase 5: 任务分解 (Standard+)

**目标**: 将设计转化为可执行任务。

**任务粒度建议**: 单个任务 5-15 分钟为佳，不超过 30 分钟。
- **过小**（<2分钟）：上下文切换成本高于任务本身
- **过大**（>30分钟）：失去快速验证的反馈，难以隔离问题

**任务结构**: 文件映射（Create/Modify/Test）+ 依赖关系 + TDD步骤 + 验证命令。

**分解原则**: 独立可验证、文件映射精确、依赖标注清楚、无占位符、每步含验证命令。

**自审要点**: 所有组件有任务、依赖形成DAG、可并行已标注、TDD驱动。

> ⚠️ 进入此阶段前，READ `references/phase-guide-execution.md` - Phase 5 和 `references/artifact-system.md`

---

## Phase 6: 执行与逐任务审查

**目标**: 产出经过TDD验证的代码实现。Standard+ 模式下每个任务完成后立即通过审查门控。

**核心机制**:
- **TDD铁律**: 先写失败测试，再写实现。没有例外。
- **逐任务审查**: 每完成一个任务立即审查（自审→spec审查→code审查），问题在传染到下游前被捕获。
- **修复→重审闭环**: Critical/Important 问题修复后审查者必须重新审查（最多3轮，超过升级用户）。
- **验证纪律**: 每个完成声明必须有**新鲜的验证证据**。详见 `references/mindset.md` - 验证纪律。

**执行方式**: 子agent并行（Claude Code）或内联顺序（其他平台）。

> ⚠️ 进入此阶段前，READ `references/phase-guide-execution.md` - Phase 6（含逐任务循环图、审查详解、闭环流程）
> TDD详细流程见 `references/execution-guide.md`
> Flow 模式详见 `references/flow-mode-guide.md`
> 子agent提示: `agents/implementer.md`、`agents/spec-reviewer.md`、`agents/code-reviewer.md`
> 审查清单见 `references/review-verify.md`

---

## Phase 7: 全局审查 (Standard+)

**目标**: 所有任务完成后，从全局视角检查跨任务一致性和整体质量。

**定位**: Phase 6 的逐任务审查捕获单任务内的问题，Phase 7 捕获**任务间的集成问题**和**全局架构问题**。

**审查内容**:
- **跨任务接口一致性** — 不同任务产出的接口是否正确对接
- **整体架构评估** — 所有变更组合后的架构是否合理
- **交叉影响检查** — 确认各任务测试集成后仍通过，检查跨任务交互问题（完整测试运行在 Phase 8）
- **代码风格一致性** — 不同子agent产出的代码风格是否统一

**问题分级**: Critical（必须修复）/ Important（应该修复）/ Suggestion（不阻塞）。

**修复闭环**: 全局审查发现 Critical/Important 问题后：修复 → 重跑全量测试 → 重新全局审查（最多2轮，超过则升级给用户）。

> ⚠️ 进入此阶段前，READ `references/phase-guide-execution.md` - Phase 7 和 `references/review-verify.md`

---

## Phase 8: 验证

**目标**: 提供可验证的证据证明变更达到预期。

**验证原则**: 运行而非声称、完整而非抽样、真实而非模拟、捕获输出。

**验证清单**: 
- 必选（所有模式）：完整测试套件、新增测试、无跳过测试
- Standard+额外：构建、lint、类型检查
- Strict额外：规范场景覆盖、性能基准、安全扫描


**⚠️ 验证环境隔离策略**（P0改进）：
当代码库存在编译错误或环境问题时，Phase 8 验证可能被阻塞。应对策略：

1. **Pre-Check 快速验证**（Phase 8 前置）：
   - 尝试编译：`./gradlew build --dry-run` 或等效命令
   - 如果失败 → 记录已存在问题，标记为"环境前提条件不满足"
   - 如果成功 → 继续 Phase 8 完整验证

2. **Isolated Test 策略**（推荐）：
   - 仅运行新增/修改测试：`./gradlew test --tests NewFeatureTest`
   - 验证新增代码编译：检查修改文件的 Kotlin/Java 语法
   - 跳过全局 lint（如果阻塞），仅验证修改文件

3. **证据分级**：
   - **A级证据**：完整测试套件 + lint + 构建 （全部通过）
   - **B级证据**：新增测试通过 + 修改代码编译（环境有问题但新代码OK）
   - **C级证据**：人工审查 + 合理性分析（环境完全阻塞）

默认尝试A级，降级到B级时需说明原因，降级到C级需用户确认。
> ⚠️ 进入此阶段前，READ `references/phase-guide-execution.md` - Phase 8 和 `references/review-verify.md`

---

## Phase 9: 归档 (Strict)

**目标**: 保留上下文供将来追溯。

**步骤**: 合并Delta规范到主规范、移动变更目录到archive、保留完整工件。

**价值**: 历史追溯、模式复用、团队学习。

> ⚠️ 进入此阶段前，READ `references/phase-guide-closing.md` - Phase 9

---

## Phase 10: 收尾清理

**目标**: 闭合 Worktree 生命周期，整合分支，清理隔离环境。

**适用**: 所有使用了 Git Worktree 的变更（Strict 必需，Standard/Flow 如果创建了 worktree 也适用）。未使用 worktree 的变更跳过此阶段。

**前置条件**: 验证通过（Phase 8），归档完成（Phase 9，如适用）。

**结构化选项**（提供给用户选择，不问开放性问题）:

1. **合并到主分支** — 切到主分支 → pull → merge → 验证测试 → 删除 worktree 和分支
2. **推送并创建 PR** — push → gh pr create → 清理 worktree（代码已推送到远端）。PR 合并后需手动将 `.specpower.yaml` status 更新为 `done`
3. **保留当前状态** — 不清理，用户稍后自行处理
4. **废弃变更** — 需用户确认 → 删除 worktree 和分支（force delete）

**安全原则**: 测试未通过不提供选项；废弃需确认；合并后再次验证测试。

**平台适配**:
- Claude Code: 使用 `ExitWorktree(action="remove"/"keep")`
- 其他平台: 输出对应的 `git worktree remove` / `git branch -d` 命令

**完成后**: 更新 `.specpower.yaml` 中 status 为 `done`（选项1/2）或 `archived`（选项4）。

> ⚠️ 进入此阶段前，READ `references/phase-guide-closing.md` - Phase 10
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
# 状态流转: in-progress → done (合并) | in-progress → review (PR) → done (PR合并后手动更新) | in-progress → archived (废弃)
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
| 逐任务审查 | 子agent闭环 | 内联自审 | 内联自审 |

无子agent时的降级策略：
- 多角色设计改为顺序内联（主agent依次切换视角）
- 逐任务审查改为清单驱动的自审（审查维度不变，只是执行方式不同）
- 并行执行改为顺序执行
- 修复→重审闭环改为修复→自审验证
- 所有工件和质量规则不变

---

## 阶段回退协议

当发现当前阶段的前提假设错误，需要回退重做时：

### 何时触发回退

| 发现时机 | 问题类型 | 回退到 | 示例 |
|---------|---------|--------|------|
| Phase 4 设计 | 需求理解错误 | Phase 1.5 | "用户实际需要的是 X 而非 Y" |
| Phase 6 执行 | 任务分解有问题 | Phase 5 | "任务粒度太大，无法完成" |
| Phase 6 执行 | 设计方案不可行 | Phase 4 | "接口设计在实际实现时发现有致命缺陷" |
| Phase 7 全局审查 | 规范缺失关键场景 | Phase 3 | "发现遗漏了并发冲突场景" |
| Phase 7 全局审查 | 某任务代码需重做 | Phase 6 | "跨任务接口不一致，需重新实现某个任务" |
| Phase 8 验证 | 功能不工作 | Phase 6 | "全量测试发现逐任务审查未覆盖的集成问题" |

### 回退流程

1. **识别回退点** - 明确需要回到哪个阶段
2. **保留已有工作** - 将当前工件重命名为 `.old` 备份
3. **更新状态** - 修改 `.specpower.yaml` 中对应工件状态为 `blocked`
4. **重新执行** - 从回退点开始，考虑已知问题
5. **对比验证** - 完成后与 `.old` 版本对比，确认问题已解决

### 回退不是失败

回退是发现问题的正常响应。记录回退原因到 `RETROSPECTIVE.md`，帮助改进流程。

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
- `references/phase-guide-planning.md` — 规划阶段 (Phase 0~3) 详细执行步骤
- `references/phase-guide-execution.md` — 执行阶段 (Phase 4~8) 详细执行步骤
- `references/phase-guide-closing.md` — 收尾阶段 (Phase 9~10) 详细执行步骤
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
