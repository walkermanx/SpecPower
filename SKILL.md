---
name: spec-power
version: "1.1.2"
description: "SpecPower - 规范驱动的开发工作流。触发关键词:'开发新功能'、'重构模块'、'复杂bug'、'架构设计'、'写计划'、'分步做'、'规范化开发'、'拆解任务'、'团队协作'、'核心系统'、'多模块'、'TDD'。自动推荐Flow(快速)/Standard(日常)/Strict(关键)三档模式。强制测试驱动开发,三层质量审查(自审/规范审查/代码审查),支持子agent并行执行。适用于所有需要结构化规划的开发工作,不适用于简单查询或单行代码修改。"
---

# SpecPower: 规范驱动的超能力开发工作流

> **版本**: 1.1.2 | **更新日志**: [CHANGELOG.md](CHANGELOG.md)

SpecPower 融合了 OpenSpec 的结构化规划能力和 Superpowers 的执行纪律，形成一套完整的软件开发方法论。核心理念：**规划深度匹配任务复杂度，质量门控保障关键节点，灵活迭代而非瀑布僵化**。

---

## 🚀 快速开始

告诉我你的任务 → 我推荐模式(Flow/Standard/Strict) → 确认后引导你完成各阶段 → 自动应用TDD + 多层审查 + 子agent并行。

**新用户**: 先读"模式选择"了解三档工作流，再看"变更目录管理"了解文件组织。
**老用户**: 直接说任务，我会自动匹配模式并开始。详细方法论见下文。

---

## 模式选择

根据任务特征自动推荐模式，用户可随时覆盖。

### Flow 模式 (快速迭代)

```
propose ──► execute ──► verify
```

**适用**: 单文件修改、小bug修复、简单配置变更、明确的小任务
**判定**: 影响范围 ≤ 2个文件，无跨模块依赖，需求明确无歧义

### Standard 模式 (日常开发)

```
propose ──► design ──► tasks ──► execute ──► review ──► verify
```

**适用**: 新功能开发、多文件修改、API变更、需要设计决策的任务
**判定**: 影响 3+ 文件，涉及新接口或数据结构，需要权衡取舍

### Strict 模式 (关键系统)

```
explore ──► propose ──► specs ──► design ──► tasks ──► execute ──► review ──► verify ──► archive
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
```

---

## Phase 1: 探索 (Strict)

在动手之前理解全局。

1. **项目上下文** — 扫描项目结构、技术栈、构建系统、测试框架
2. **现有模式** — 搜索相关代码，理解当前的设计模式和约定
3. **影响范围** — 确定哪些模块、接口、数据结构会被影响
4. **约束发现** — 性能要求、兼容性限制、部署环境

产出形式：在提案中的 Context 部分体现，不单独生成文件。

---

## Phase 2: 提案

所有模式都从提案开始，规模因模式而异。

### Flow 提案

一段话说清楚：改什么、为什么、怎么验证。不需要单独文件，直接在对话中确认。

### Standard/Strict 提案

创建 `docs/spec-power/changes/<change-name>-YYYYMMDDHHMMSS/proposal.md`:

```markdown
# <变更名称>

## 动机
为什么要做这个变更？解决什么问题？

## 变更范围
具体改什么？列出受影响的模块和接口。

### 新增能力
- `capability-name`: 描述

### 修改能力
- `existing-name`: 什么变了，为什么

## 影响分析
- 向后兼容性：是/否，如何处理
- 性能影响：预期变化
- 依赖变化：新增/移除的依赖
```

### 提案自审清单

写完提案后立即检查（30秒，不要跳过）：
- [ ] 没有占位符（"TBD"、"待定"、"后续补充"）
- [ ] 动机清晰——不了解项目的人也能理解为什么
- [ ] 范围边界明确——说了"不做什么"和"做什么"一样重要
- [ ] 影响分析没有遗漏关键模块

---

## Phase 3: 规范 (Strict)

用 Delta 格式描述行为变更，这样多个变更可以并行进行而不冲突。

> 详见 `references/artifact-system.md` 的"Delta 规范"部分了解完整格式和示例。

创建 `docs/spec-power/changes/<change-name>-YYYYMMDDHHMMSS/specs/<domain>/spec.md`:

```markdown
## ADDED Requirements

### Requirement: <行为名称>
系统 SHALL <行为描述>

#### Scenario: <场景名>
- **GIVEN** <前置条件>
- **WHEN** <触发动作>
- **THEN** <预期结果>

## MODIFIED Requirements

### Requirement: <现有行为名称>
系统 MUST <修改后的行为>
(之前: <原始行为>)

## REMOVED Requirements

### Requirement: <废弃行为>
**原因**: <为什么移除>
**迁移**: <替代方案>
```

**RFC 2119 关键词**: MUST(绝对要求), SHALL(同MUST), SHOULD(推荐但可例外), MAY(可选)

### 规范自审清单

- [ ] 每个需求都有至少一个场景
- [ ] 场景可以直接转化为测试用例
- [ ] MODIFIED 标注了"之前"的行为
- [ ] REMOVED 提供了迁移方案
- [ ] 没有实现细节混入规范（规范说"做什么"，不说"怎么做"）

---

## Phase 4: 设计 (Standard+)

记录技术决策和权衡，让将来的维护者理解"为什么这样做"。

创建 `docs/spec-power/changes/<change-name>-YYYYMMDDHHMMSS/design.md`:

```markdown
# <变更名称> 技术设计

## 现状
当前系统如何工作，相关的架构背景。

## 方案

### 方案 A: <名称> (推荐)
- 描述核心思路
- **优势**: ...
- **劣势**: ...

### 方案 B: <名称>
- 描述核心思路
- **优势**: ...
- **劣势**: ...

## 决策
选择方案 A，因为 <具体理由>。

## 关键设计细节
- 数据流
- 接口定义
- 错误处理策略

## 风险与缓解
| 风险 | 概率 | 影响 | 缓解措施 |
|------|------|------|---------|

## 迁移计划 (如需)
分步部署策略和回滚方案。
```

### 设计自审清单

- [ ] 至少考虑了 2 个方案（即使另一个明显不如）
- [ ] 决策理由具体——不是"更好"而是"因为X所以Y"
- [ ] 接口定义精确到参数和返回值
- [ ] 识别了至少一个风险

---

## Phase 5: 任务分解 (Standard+)

将设计转化为可执行的小任务。每个任务粒度控制在 2-5 分钟。

创建 `docs/spec-power/changes/<change-name>-YYYYMMDDHHMMSS/tasks.md`:

```markdown
# <变更名称> 实现计划

> **执行方式**: 使用 spec-power 的执行阶段，推荐子agent并行模式

**目标**: 一句话
**架构**: 2-3句话
**技术栈**: 关键技术

## Task 1: <组件名>
**文件**:
- Create: `src/path/to/new-file.ts`
- Modify: `src/path/to/existing.ts`
- Test: `tests/path/to/test.ts`

**依赖**: 无 (可并行)

- [ ] 编写失败测试
- [ ] 验证测试确实失败且原因正确
- [ ] 最小实现使测试通过
- [ ] 验证所有测试通过
- [ ] 提交

## Task 2: <组件名>
**文件**: ...
**依赖**: Task 1 (需要 Task 1 的接口)

- [ ] 编写失败测试
- [ ] ...
```

### 任务分解规则

1. **每个任务独立可验证** — 完成后有明确的"通过/不通过"判定
2. **文件映射精确** — Create/Modify/Test 三种操作，精确到路径
3. **依赖标注清楚** — 无依赖的任务可以并行
4. **无占位符** — 不允许"添加验证逻辑"，要写"验证 email 格式匹配 RFC 5322"
5. **每步含验证命令** — 不只是"编写测试"，还要"运行 `npm test -- --grep 'email'` 确认失败"

### 任务自审清单

- [ ] 所有设计文档中的组件都有对应任务
- [ ] 任务之间的依赖关系形成 DAG（无循环）
- [ ] 无依赖的任务已标注"可并行"
- [ ] 每个任务都以测试开始（TDD）

---

## Phase 6: 执行

这是代码产出的核心阶段。根据平台能力选择执行方式。

> 完整执行指南见 `references/execution-guide.md`

### 执行方式选择

**子agent 并行** (Claude Code，推荐):
- 每个无依赖任务 dispatch 一个子agent
- 子agent 收到完整上下文（项目信息 + 任务详情 + TDD规则）
- 主agent 监控进度和集成

**内联顺序** (Cursor/Copilot/其他):
- 按依赖顺序逐个执行任务
- 同样遵循 TDD 流程
- 适合无子agent支持的平台

### TDD 铁律

无论哪种执行方式，测试驱动开发是不可妥协的：

```
RED     → 写一个测试，运行，确认它失败
验证RED → 失败原因是"功能未实现"而非"语法错误"
GREEN   → 写最小代码使测试通过
验证GREEN → 运行所有测试，全部通过
REFACTOR → 改善代码结构，保持测试绿色
```

**铁律**: 如果发现自己在没有失败测试的情况下写了生产代码——停下来，删掉代码，先写测试。这不是建议，是规则。

### 系统调试 (遇到问题时)

当测试失败或出现意外行为，使用四阶段法：

1. **根因调查** — 仔细读错误信息，一致复现，追踪数据流。不要在知道原因之前尝试修复。
2. **假设形成** — 根据证据提出可能原因，排序可能性
3. **验证** — 设计最小实验证明或反驳假设
4. **修复** — 只在确认根因后修复。如果修复后问题消失但你不知道为什么——继续调查。

### 子agent 上下文注入

dispatch 子agent 时，构造丰富的上下文（融合 OpenSpec 的指令注入模式）：

```
你是一个实现任务的开发者。

## 项目上下文
<来自 .specpower.yaml 或项目配置的技术栈、约定>

## 你的任务
<来自 tasks.md 的具体任务描述>

## 相关上下文
<来自已完成工件的关键信息：设计决策、接口定义>

## 执行规则
1. 使用 TDD: 先写失败测试，再写实现
2. 每完成一步运行测试验证
3. 遇到问题时报告状态而非猜测修复

## 输出要求
完成后报告：完成的步骤、测试结果、遇到的问题
```

> 完整子agent提示模板见 `agents/implementer.md`

---

## Phase 7: 审查 (Standard+)

三层质量网，层层递进。

> 详见 `references/review-verify.md`

### 第一层: 自我审查 (所有模式，30秒)

每完成一个任务立即执行：
- 代码中有无 TODO/FIXME/HACK 遗留？
- 测试覆盖了正常路径和边界情况？
- 没有引入新的安全漏洞（注入、XSS、敏感信息泄露）？

### 第二层: 规范符合审查 (Strict, 子agent)

Dispatch `spec-reviewer` 子agent：
- 对比 specs/ 中的每个 Requirement 和 Scenario
- 检查实现是否完整覆盖所有规范要求
- 标记偏差——是改进还是遗漏？

> 子agent 提示见 `agents/spec-reviewer.md`

### 第三层: 代码质量审查 (Standard+, 子agent)

Dispatch `code-reviewer` 子agent：
- 代码风格与项目约定一致
- 错误处理完善
- 无过度工程或过少工程
- 架构决策合理（SOLID、低耦合）
- 问题分级：Critical / Important / Suggestion

> 子agent 提示见 `agents/code-reviewer.md`

### 审查结果处理

- **Critical**: 必须修复，阻塞完成
- **Important**: 应该修复，除非有充分理由不修
- **Suggestion**: 记录但不阻塞，由用户决定

对每个审查意见做技术评估，不要表演性同意。如果审查意见有误，说明为什么。

---

## Phase 8: 验证

声称完成之前，必须有证据。不是"我觉得应该没问题"，而是"我运行了X，输出是Y，符合预期Z"。

### 验证清单

- [ ] 运行完整测试套件，附上输出
- [ ] 新功能的手动验证（如适用）
- [ ] 构建成功（如适用）
- [ ] lint/类型检查通过（如适用）
- [ ] 边界条件测试

### 验证报告格式

```
## 验证结果

### 测试
命令: `npm test`
结果: 47 passed, 0 failed
新增测试: 5

### 构建
命令: `npm run build`
结果: 成功，无警告

### 手动验证
- [x] 创建用户 → 返回 201，数据正确
- [x] 重复邮箱 → 返回 409，错误信息友好
- [x] 无效输入 → 返回 422，字段级错误
```

---

## Phase 9: 归档 (Strict)

保留上下文供将来追溯。

1. 如果有 Delta 规范，合并到主规范 (`docs/spec-power/specs/`)
2. 将变更目录移到 `docs/spec-power/archive/YYYY-MM-DD-<name>/`
3. 在 archive 中保留完整的 proposal、design、tasks、specs

归档的价值：三个月后新同事问"这个为什么这样设计"，可以直接指向 archive。

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
| Git worktree (Strict) | 自动 | 手动必需 | 手动必需 |
| Git worktree (Standard/Flow) | 自动 | 手动可选 | 手动可选 |
| 工件系统 | Yes | Yes | Yes |
| TDD流程 | Yes | Yes | Yes |
| 两阶段审查 | 子agent | 内联 | 内联 |

无子agent时的降级策略：
- 审查改为自我审查（用清单代替独立子agent）
- 并行执行改为顺序执行
- 所有工件和质量规则不变

---

## 快速参考

### 心态与最佳实践

常见的思维陷阱和如何克服它们：详见 `references/mindset.md` — 反理性化 Red Flags、为什么这些念头危险、如何培养正确的开发心态。

### 开始一个新变更

**使用初始化脚本** (推荐):
```bash
./scripts/init-change.sh <change-name> [mode]
# 脚本会自动添加时间戳后缀
# 示例: ./scripts/init-change.sh add-user-auth standard
# 生成: docs/spec-power/changes/add-user-auth-20260408143025/
```

**手动创建**:
1. 确定模式（自动推荐或手动选择）
2. 写提案（Flow: 一段话; Standard+: proposal.md）
3. 按模式走完剩余阶段

### 示例和工具

- `examples/add-user-avatars/` — 完整的 Standard 模式端到端示例
- `scripts/init-change.sh` — 自动创建变更目录结构的脚本

### 引用资源
- `references/artifact-system.md` — 工件类型、DAG模型、Delta规范详解、模板
- `references/execution-guide.md` — TDD详细流程、子agent调度、系统调试四阶段
- `references/review-verify.md` — 审查方法论、验证清单、问题分级
- `references/mindset.md` — 反理性化与最佳实践心态

### 子agent 提示
- `agents/implementer.md` — 任务实现者
- `agents/spec-reviewer.md` — 规范符合审查
- `agents/code-reviewer.md` — 代码质量审查
