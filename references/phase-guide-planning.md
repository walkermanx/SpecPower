# Phase 执行指南 — 规划阶段 (Phase 0~3)

本文档详细说明 SpecPower 规划阶段的执行细节。根据使用的模式（Flow/Standard/Strict），不同阶段的要求会有所不同。

> **其他阶段**:
> - 执行阶段 (Phase 4~8): `phase-guide-execution.md`
> - 收尾阶段 (Phase 9~10): `phase-guide-closing.md`

---

## Phase 0: 模式评估 (所有模式)

### 目标

在开始任何实际工作之前，基于用户需求和代码库实际情况，确定最合适的工作模式（Flow/Standard/Strict）。避免"信息最少的时候做最重要的决策"。

### 两阶段推荐流程

```
用户描述任务
     ↓
[初判] 基于描述关键词，形成初步模式判断
     ↓
 ┌── 高置信度（明显简单/明显复杂）→ 直接确认模式，跳过验证
 └── 低置信度（边界情况）→ 进入快速验证
     ↓
[快速验证] ~30秒：扫描影响范围、检查模块边界、确认复杂度信号
     ↓
[确认模式] 基于初判 + 验证结果，给出最终推荐（可能调整）
     ↓
按确认的模式执行后续 Phase
```

### 初判（即时）

基于用户描述中的关键信号：

| 信号类型 | Flow 信号 | Standard 信号 | Strict 信号 |
|---------|-----------|---------------|------------|
| 影响范围 | "修改 login.ts" | "重构登录模块" | "重构认证系统" |
| 跨模块性 | 无提及 | "涉及 API 和前端" | "跨多个模块"、"核心系统" |
| 需求明确度 | "改配置值"、"修 typo" | "添加功能"、"实现 XX" | "优化性能"、"改一下登录"（模糊） |
| 用户语气 | "快速搞定"、"简单改下" | 中性描述 | "仔细做"、"这个很重要"、"团队协作" |
| 测试要求 | 未提及 | "需要测试" | "TDD"、"完整测试覆盖" |

### 快速验证（~30秒，条件触发）

#### 触发条件（任一满足即触发）

1. **用户描述模糊，无法判断影响范围**
   - 示例："改一下登录"（不知道改哪个文件、影响多大）
   - 示例："优化性能"（不知道哪部分性能、需要改什么）

2. **初判在 Standard/Strict 边界上犹豫**
   - 初判认为可能是 Standard，但提到了"核心"、"重要"等关键词
   - 初判认为可能是 Strict，但描述的范围看起来不大

3. **用户提到的模块/功能不了解其复杂度**
   - 用户说"重构 auth"，但不知道 auth 模块的实际复杂度

#### 跳过条件（任一满足即跳过）

1. **任务明显简单** → 直接推荐 Flow
   - "修个 typo"、"改配置值"、"更新注释"

2. **用户明确说了模式偏好**
   - "用 Strict 模式做这个"
   - "快速用 Flow 搞定"

3. **用户提供了足够的上下文信息**
   - "这个涉及 3 个模块、需要改数据库 schema"（信息充分，直接推荐 Strict）
   - "只需要改 config.json 里的一个值"（信息充分，直接推荐 Flow）

#### 验证内容（快速扫描，不是完整的 Phase 1 探索）

**第 1 步：Glob 扫描影响范围**（~10秒）
```bash
# 扫描用户提到的文件/目录
glob "src/auth/**/*"
glob "**/*login*"
```
目标：确认实际文件数量（1-2个 vs 3-5个 vs 10+个）

**第 2 步：Grep 检查耦合度**（~10秒）
```bash
# 检查关键接口/函数的引用数量
grep "login\(" --count
grep "class.*Auth" --count
```
目标：判断耦合程度（被引用 1-2 次 vs 5+ 次 vs 跨模块引用）

**第 3 步：检查测试覆盖**（~10秒）
```bash
# 查找相关的测试文件
glob "**/*auth*.test.*"
glob "**/*auth*.spec.*"
```
目标：是否有测试（有测试 = 已被重视，可能更复杂；无测试 = 技术债，Strict 优先）

#### 验证后调整规则

| 初判 | 验证发现 | 调整为 | 理由 |
|------|---------|--------|------|
| Flow | 影响 3+ 文件 | Standard | 范围超出单文件 |
| Flow | 跨模块引用 | Standard | 耦合度高 |
| Standard | 跨 5+ 模块且无测试 | Strict | 复杂度高 + 技术债 |
| Standard | 影响核心认证/支付/权限 | Strict | 关键系统 |
| Strict | 只影响 1 个文件 | Standard 或 Flow | 范围过小，不需要 Strict |

### 确认模式

向用户说明最终推荐，**如果与初判不同要解释原因**：

**示例 1：验证后升级**
> 初看这是个 Standard 级别的任务，但我快速扫描了 `src/auth/` 模块后发现它涉及 12 个文件、跨 3 个模块且没有测试覆盖，升级推荐为 **Strict 模式**。

**示例 2：验证后降级**
> 初看"重构登录模块"可能比较复杂，但我检查后发现只涉及 `login.ts` 和 `LoginForm.tsx` 两个文件，推荐 **Standard 模式**就够了。

**示例 3：初判明确，跳过验证**
> 这个任务只需要修改 `config.json` 中的 API 地址，推荐 **Flow 模式**。

用户可随时覆盖推荐：
- "快速搞定" / "简单做" → 降级一档
- "仔细做" / "这个很重要" → 升级一档
- "用 Standard 就行" → 直接使用指定模式

### 与 Phase 1 探索的区别

| 维度 | Phase 0: 模式评估 | Phase 1: 探索 |
|------|-------------------|--------------|
| 目标 | 确定模式 | 理解全局上下文 |
| 深度 | 快速扫描（~30秒） | 完整探索（5-15分钟） |
| 时机 | 模式确定前 | Strict 模式开始后 |
| 产出 | 模式推荐 | 上下文报告（内嵌于 proposal） |
| 适用 | 所有任务 | 仅 Strict 模式 |

Phase 0 是为了"选对工具"，Phase 1 是为了"用好工具"。

---

## 变更目录初始化 (模式确认后，所有模式必须执行)

### 目标

创建变更目录和元数据文件，为后续工件提供存储位置。**此步骤所有模式必须执行，不可跳过。**

### 适用条件

- **所有模式**: 必需（Flow/Standard/Strict）
- **前置条件**: Phase 0 模式确认完成

### 执行步骤

#### Step 1: 确认基准分支

确认用户期望的基准分支：

```bash
git rev-parse --abbrev-ref HEAD
```

**向用户确认**："当前在 `<branch-name>` 分支上，将基于此分支进行变更。确认？"

如果用户期望基于其他分支，记录用户指定的分支名即可（无需 checkout）。

将确认后的分支记录为 `base_branch`。

#### Step 2: 创建变更目录

```bash
mkdir -p docs/spec-power/changes/<change-name>-YYYYMMDDHHMMSS
```

#### Step 3: 写入元数据

创建 `docs/spec-power/changes/<change-name>-YYYYMMDDHHMMSS/.specpower.yaml`：

```yaml
name: <change-name>-YYYYMMDDHHMMSS
mode: flow          # flow | standard | strict
created: YYYY-MM-DD
base_branch: <base_branch>   # Step 1 中确认的基准分支
status: in-progress
```

### 常见错误

| 错误 | 原因 | 预防 |
|------|------|------|
| 遗漏 `.specpower.yaml` | 跳过了此步骤 | 所有模式必须执行此步骤 |
| base_branch 记录与实际不一致 | 仅记录分支名未验证 | 使用 `git rev-parse --abbrev-ref HEAD` 确认 |

---

## Worktree 隔离 (可选，Standard/Strict 推荐)

### 目标

创建 Git Worktree 物理隔离环境，确保工作分支基于正确的基准分支。**此步骤可选，但推荐用于 Standard 和 Strict 模式。**

### 适用条件

- **Strict 模式**: 强烈推荐
- **Standard 模式**: 推荐（特别是多人协作或长期任务）
- **Flow 模式**: 通常不需要
- **前置条件**: 变更目录初始化完成

### 执行步骤

#### Step 1: 创建 Worktree

**Claude Code（先创建再进入）**:

```bash
# 手动创建 worktree，显式指定 base_branch 确保基准精确
git worktree add .claude/worktrees/<change-name>-YYYYMMDDHHMMSS \
  -b spec-power/<change-name>-YYYYMMDDHHMMSS \
  <base_branch>
```

```
# 进入已创建的 worktree，获得完整的会话状态管理（CWD 切换、CLAUDE.md 重载、退出时自动清理提示）
EnterWorktree(path=".claude/worktrees/<change-name>-YYYYMMDDHHMMSS")
```

> **为什么分两步？** `EnterWorktree(name=...)` 只能基于当前 HEAD 创建分支，不支持指定 base_branch，在 HEAD 与期望基准不一致时会导致分支基于错误的 commit。先用 `git worktree add` 显式指定 base_branch，再用 `EnterWorktree(path=...)` 进入，兼顾基准精确性和会话状态管理。

**其他平台（手动）**:

```bash
git worktree add .worktrees/<change-name>-YYYYMMDDHHMMSS \
  -b spec-power/<change-name>-YYYYMMDDHHMMSS \
  <base_branch>
cd .worktrees/<change-name>-YYYYMMDDHHMMSS
```

#### Step 2: 验证分支基准

Worktree 创建后，**立即验证**新分支的基准是否正确：

```bash
# 新分支 HEAD 应与 base_branch 的 HEAD 指向同一 commit
git log --oneline -1 HEAD
git log --oneline -1 <base_branch>
```

如果两者 commit 不一致：
1. 退出并删除 worktree（Claude Code: `ExitWorktree(action="remove")`）
2. 检查 `<base_branch>` 是否拼写正确、是否已 fetch 最新
3. 重新执行 Step 1-2

#### Step 3: 更新元数据

更新 `.specpower.yaml`，添加 worktree 信息：

```yaml
name: <change-name>-YYYYMMDDHHMMSS
mode: strict          # flow | standard | strict
created: YYYY-MM-DD
base_branch: <base_branch>
worktree_path: .claude/worktrees/<change-name>-YYYYMMDDHHMMSS  # 新增
status: in-progress
```

### 常见错误

| 错误 | 原因 | 预防 |
|------|------|------|
| 新分支基于错误 commit | `git worktree add` 的 base_branch 参数拼写错误或未 fetch | Step 2 验证 commit hash |
| 多次创建 worktree 分支冲突 | 时间戳重复 | 名称中包含 YYYYMMDDHHMMSS 精确到秒 |

---

## Phase 1: 探索 (仅Strict模式)

### 目标

在动手之前理解全局上下文，为后续的规范和设计奠定基础。

### 执行步骤

1. **项目上下文扫描**
   - 扫描项目结构、技术栈识别
   - 查找构建系统配置（package.json, Cargo.toml, go.mod等）
   - 识别测试框架和约定

2. **现有模式理解**
   - 使用 Glob/Grep 搜索相关代码
   - 理解当前的设计模式和架构约定
   - 查看类似功能的实现方式

3. **影响范围确定**
   - 列出会被影响的模块、接口、数据结构
   - 使用 Grep 查找相关引用和依赖

4. **约束发现**
   - 性能要求（从注释或文档中查找）
   - 兼容性限制（查看版本历史）
   - 部署环境约束

5. **棕地基线检测**（按需，仅当涉及 MODIFIED/REMOVED 时）

   在探索阶段结束时，评估本次变更是否涉及修改或移除现有行为：

   a. **检查主规范状态**
      ```bash
      [ -d docs/spec-power/specs ] && echo "主规范目录已存在" || echo "主规范目录不存在"
      ```

   b. **逐模块判断是否需要基线**
      对本次变更涉及的每个模块（domain），独立判断：
      - 本模块全是 ADDED（新增能力）→ **不需要基线**，跳过
      - 本模块涉及 MODIFIED 或 REMOVED → 检查 `docs/spec-power/specs/<domain>/spec.md`
        - 已存在且覆盖相关 Requirement → **检查新鲜度**（见下方 Step 5d）
        - 不存在或未覆盖 → **需要生成局部基线**

   c. **生成局部基线规范**（仅对需要基线的模块）
      - 阅读现有代码，理解当前行为
      - 生成 `docs/spec-power/specs/<domain>/spec.md` 作为基线
      - 只覆盖本次变更涉及的 Requirement，不要求覆盖整个模块
      - 使用标准 Requirement + Scenario 格式（非 Delta），记录"当前系统的行为是什么"
      - 添加 frontmatter 元信息标注为局部基线（格式见 `artifact-delta-specs.md` - 基线规范格式）

   d. **主规范新鲜度验证**（仅当 Step 5b 判定"已存在且覆盖"时）

      主规范可能因 Standard/Flow 变更或体系外开发而过时。通过 git 检测代码侧变更：

      ```bash
      # 获取主规范最后更新的 commit
      SPEC_COMMIT=$(git log -1 --format="%H" -- docs/spec-power/specs/<domain>/spec.md)
      # 查看该 commit 之后，模块相关代码是否有变更
      git log --oneline $SPEC_COMMIT..HEAD -- <module-code-paths>
      ```

      **如果无代码变更** → 主规范是最新的，**不需要基线**，直接用作参照。

      **如果存在代码变更**，按信息丰富度分级处理：
      1. 查找 `docs/spec-power/changes/` 下相关变更目录中的 `behavior-changes.md` → 读取摘要，定向核实主规范对应 Requirement
      2. 查找相关变更目录中的 `proposal.md` → 从变更范围推断行为影响
      3. 仅有 git log → 阅读代码差异，确认主规范中涉及的 Requirement 是否仍然准确

      **处理方式**：
      - 能确认变更内容 → 直接更新主规范对应 Requirement（保持格式，仅修正行为描述）
      - 无法确认 → 在主规范对应 Requirement 旁标注 `<!-- unverified since <commit-hash> -->`，提醒 Phase 3 写 MODIFIED 时需特别核实

      > `<module-code-paths>` 指模块对应的代码目录。通常可从主规范的上下文或项目结构推断（如 `src/auth/`、`lib/user-api/`）。如果模块与代码目录的映射不明确，扩大范围扫描或查阅项目文档。

   > **注意**: 基线检测是逐模块的。即使主规范目录已存在（之前的 Strict 变更创建了其他模块的主规范），只要本次涉及的具体模块没有主规范，仍会触发基线生成。一旦主规范通过归档积累起来，后续变更自然有基线可参照。新鲜度验证确保已有的主规范仍然反映代码的当前行为。

### 产出形式

探索结果不单独生成文件，而是体现在提案的"上下文"或"现状"部分。

**棕地基线例外**: 如果 Step 5 检测到需要基线，则在 `docs/spec-power/specs/<domain>/spec.md` 生成局部基线规范文件。这是探索阶段唯一可能产出独立文件的情况。

### 平台适配

- **Claude Code**: 可使用 Explore 子agent 并行扫描不同方面
- **其他平台**: 顺序执行上述步骤

---

## Phase 1.5: 需求澄清 (Standard及以上)

### 目标

在写提案之前，通过对话澄清模糊需求、确认方向、控制范围。好的澄清能显著提升提案质量，避免在 design 阶段才发现方向错误。

### 适用条件

- **Standard**: 1-3 个关键问题，快速确认方向
- **Strict**: 完整澄清流程，按需提问直到需求清晰
- **Flow**: 跳过——任务明确，不需要澄清
- **跳过条件**: 用户需求已非常明确且具体（有明确的输入/输出/边界），无论模式都可跳过

### 执行步骤

1. **快速上下文感知**
   - 如果已执行 explore（Strict），直接使用其结果
   - 如果未执行（Standard），快速扫描相关代码和文档（30秒）
   - 目的：为后续提问建立技术上下文，避免问出与项目现状脱节的问题

2. **逐个澄清关键问题**
   - 一次只问一个问题，等用户回答后再问下一个
   - 优先使用多选题（降低用户认知负担）
   - 聚焦于：目的、约束、成功标准、边界
   - Standard: 最多 3 个问题
   - Strict: 按需，直到需求清晰
   - 如果用户的回答已经让需求足够清晰，提前结束提问

3. **方向速览**（如果存在多条技术路径）
   - 提出 2-3 个方向性选择（不是完整设计方案）
   - 带推荐和简短理由
   - 示例："JWT vs Session vs OAuth？推荐 JWT，因为项目已有 jsonwebtoken 依赖且是无状态 API"
   - 与 design 阶段的区别：这里选方向，design 阶段做技术细节设计
   - 如果只有一条明显合理的路径，跳过此步

4. **范围确认**
   - 如果任务涉及多个独立子系统，建议分解
   - 如果需求描述包含与当前项目技术栈无关的内容（如 Android 项目中的 iOS/后端描述），识别并确认排除
   - 主动识别并移除不必要的功能（YAGNI）
   - 明确"不做什么"

### 产出

不生成独立文件。澄清结论直接注入后续 proposal 的动机和范围部分：
- 澄清确认的需求 → proposal 的"变更范围"
- 确认排除的内容 → proposal 的"不在范围内"
- 选定的方向 → proposal 的"动机"或 design 的前置输入

### 与 explore 的职责划分

- **explore**: 看代码，理解技术现状（面向系统）
- **clarify**: 问用户，理解意图和需求（面向人）

### 与 design 的职责划分

- **clarify**: 方向选择（"用什么方案"）
- **design**: 技术细节（"方案怎么实现"，含接口定义、数据模型、风险分析）

### 平台适配

所有平台行为一致——clarify 是主对话中的交互过程，不依赖子agent或特殊工具。

---

## Phase 2: 提案

### 目标

明确变更的动机、范围和影响，为后续工作建立共识基础。

### Flow模式提案

一段话说清楚：改什么、为什么、怎么验证。不需要单独文件，直接在对话中确认。

**示例**:
```
提案：修复用户登录时密码特殊字符处理bug。
动机：当前密码含#&等字符会导致500错误。
验证：添加测试覆盖特殊字符场景，修复后测试通过。
```

### Standard/Strict模式提案

创建 `docs/spec-power/changes/<change-name>-YYYYMMDDHHMMSS/proposal.md`

**必需内容**:

#### 动机
为什么要做这个变更？解决什么问题？有什么业务或技术背景？

**技巧**: 用"不了解项目的人也能理解"的语言描述

#### 变更范围

**新增能力**:
- `capability-name`: 一句话描述

**修改能力**:
- `existing-name`: 什么变了，之前是什么

**不在范围内**:
明确列出不做的事情，避免范围蔓延

#### 影响分析

**向后兼容性**: 是/否，如何处理
**性能影响**: 预期变化
**安全考虑**: 是否引入新攻击面
**依赖变化**: 新增/移除的依赖

#### 成功标准
怎么算"做完了"？可量化的指标。

### 提案自审

写完提案后立即检查（30秒）：
- [ ] 没有占位符（"TBD"、"待定"、"后续补充"）
- [ ] 动机清晰——不了解项目的人也能理解为什么
- [ ] 范围边界明确——说了"不做什么"和"做什么"一样重要
- [ ] 影响分析没有遗漏关键模块

完整 proposal.md 模板见 `templates.md`

### 提案呈现与用户确认（Standard/Strict 必须执行，不可跳过）

自审通过后，**必须**在对话中向用户呈现提案摘要，并**等待用户明确批准后才能进入 Phase 4**。这是一个硬性停止点——不能因为"需求已经很清楚"或"用户应该会同意"就自行跳过。

**呈现内容**（简明扼要，不要直接粘贴整个 proposal.md）：
- 一句话说明做什么（动机）
- 变更范围列表（新增 / 修改 / 不做什么）
- 成功标准

**等待用户响应**：
- 用户明确表示同意（"OK"、"可以"、"继续"等）→ 进入 Phase 4
- 用户有修改意见 → 更新 proposal.md，重新呈现，再次等待确认
- 用户未响应或回应模糊 → 追问，不得自行推进

---

## Phase 3: 规范 (仅Strict模式)

### 目标

用 Delta 格式精确描述行为变更，使规范可测试、可审查、可合并。

### Delta规范格式

创建 `docs/spec-power/changes/<change-name>-YYYYMMDDHHMMSS/specs/<domain>/spec.md`

使用三种操作：

#### ADDED - 新增需求

```markdown
## ADDED Requirements

### Requirement: <行为名称>
系统 SHALL <行为描述>

#### Scenario: <场景名>
- **GIVEN** <前置条件>
- **WHEN** <触发动作>
- **THEN** <预期结果>
- **AND** <额外条件或结果>
```

#### MODIFIED - 修改现有需求

```markdown
## MODIFIED Requirements

### Requirement: <现有行为名称>
系统 MUST <修改后的行为>
(之前: <原始行为>)

#### Scenario: <场景名>
<更新后的场景描述>
```

> **棕地提示**: "(之前: ...)" 内容来源优先级：
> 1. 主规范 `docs/spec-power/specs/<domain>/spec.md` 中的对应 Requirement（如已存在）
> 2. Phase 1 生成的局部基线规范（棕地首次使用时）
> 3. 基于代码阅读描述当前行为（需标注"基于代码推断"）

#### REMOVED - 删除需求

```markdown
## REMOVED Requirements

### Requirement: <废弃行为>
**原因**: <为什么移除>
**迁移**: <替代方案>
```

> **棕地提示**: REMOVED 中废弃行为的描述来源优先级同 MODIFIED。如果无基线可引用，必须在 Phase 1 探索阶段通过代码阅读确认要移除的行为确实存在。

### RFC 2119 关键词

- **MUST / SHALL**: 绝对要求，违反即为bug
- **MUST NOT / SHALL NOT**: 绝对禁止
- **SHOULD**: 推荐做法，可例外但需充分理由
- **SHOULD NOT**: 不推荐，可做但需充分理由
- **MAY**: 可选行为，实现者自行决定

### 场景编写原则

好的场景可以直接转化为测试用例：
- 具体且可验证
- 包含前置条件、触发动作、预期结果
- 避免模糊表述（"系统运行流畅"）

### 规范自审

- [ ] 每个需求都有至少一个场景
- [ ] 场景可以直接转化为测试用例
- [ ] MODIFIED 标注了"之前"的行为
- [ ] REMOVED 提供了迁移方案
- [ ] 没有实现细节混入规范
- [ ] 棕地场景：MODIFIED/REMOVED 的"之前"描述有明确来源（主规范/基线/代码推断+标注）

完整 Delta 格式、RFC 2119、场景编写指南、基线规范格式见 `artifact-delta-specs.md`
