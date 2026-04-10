# Phase执行指南

本文档详细说明 SpecPower 各个阶段的执行细节。根据使用的模式（Flow/Standard/Strict），不同阶段的要求会有所不同。

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

### 产出形式

探索结果不单独生成文件，而是体现在提案的"上下文"或"现状"部分。

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

完整模板见 `artifact-system.md`

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

#### REMOVED - 删除需求

```markdown
## REMOVED Requirements

### Requirement: <废弃行为>
**原因**: <为什么移除>
**迁移**: <替代方案>
```

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

完整格式和示例见 `artifact-system.md`

---

## Phase 4: 设计 (Standard及以上)

### 目标

记录技术决策和权衡，让将来的维护者理解"为什么这样做"。

### 设计文档结构

创建 `docs/spec-power/changes/<change-name>-YYYYMMDDHHMMSS/design.md`

#### 现状
当前系统相关部分如何工作，架构背景

#### 目标与非目标
明确追求什么、不追求什么

#### 方案对比

至少包含2个方案：

**方案 A: <名称> (推荐)**
- 核心思路
- 优势
- 劣势
- 实现复杂度: 低/中/高

**方案 B: <名称>**
- 核心思路
- 优势
- 劣势

#### 决策
选择方案 A，因为<具体理由>

#### 关键设计细节
- 数据模型
- 接口定义（精确到参数和返回值）
- 错误处理策略

#### 风险与缓解

| 风险 | 概率 | 影响 | 缓解措施 |
|------|------|------|---------|
| ... | 低/中/高 | 低/中/高 | ... |

#### 迁移计划（如需）
分步部署策略和回滚方案

### 设计自审

- [ ] 至少考虑了2个方案（即使另一个明显不如）
- [ ] 决策理由具体——不是"更好"而是"因为X所以Y"
- [ ] 接口定义精确到参数和返回值
- [ ] 识别了至少一个风险

完整模板见 `artifact-system.md`

---

## Phase 5: 任务分解 (Standard及以上)

### 目标

将设计转化为可执行的小任务，每个任务粒度控制在2-5分钟。

### 任务文档结构

创建 `docs/spec-power/changes/<change-name>-YYYYMMDDHHMMSS/tasks.md`

#### 前言部分

```markdown
**目标**: 一句话
**架构**: 2-3句话概括
**技术栈**: 关键技术
```

#### 任务模板

```markdown
## Task N: <组件名>

**文件**:
- Create: `src/path/to/new-file.ts`
- Modify: `src/path/to/existing.ts`
- Test: `tests/path/to/test.ts`

**依赖**: 无 (可并行) | Task X (需要其接口)

**步骤**:
- [ ] 编写失败测试: <具体描述测试什么>
  验证: `npm test -- --grep 'keyword'` → 期望失败
- [ ] 验证RED: 失败原因是"功能未实现"而非语法错误
- [ ] 最小实现使测试通过
  验证: `npm test` → 期望全部通过
- [ ] 验证GREEN: 运行完整测试套件
- [ ] 重构（如需）
  验证: 保持测试绿色
- [ ] 提交: `git commit -m "feat: <具体说明>"`
```

### 任务分解规则

1. **独立可验证**: 每个任务完成后有明确的"通过/不通过"判定
2. **文件映射精确**: Create/Modify/Test三种操作，精确到路径
3. **依赖标注清楚**: 无依赖的任务标注"可并行"
4. **无占位符**: 不允许"添加验证逻辑"，要写"验证email格式匹配RFC 5322"
5. **每步含验证命令**: 包含具体的命令和预期结果

### 依赖图可视化

```
Task 1 ──► Task 3
Task 2 ──► Task 3
Task 3 ──► Task 4

可并行: Task 1, Task 2
```

### 任务自审

- [ ] 所有设计文档中的组件都有对应任务
- [ ] 任务依赖关系形成DAG（无循环）
- [ ] 无依赖的任务已标注"可并行"
- [ ] 每个任务都以测试开始（TDD）

完整模板见 `artifact-system.md`

---

## Phase 6: 执行

### 目标

产出经过TDD验证的代码实现。

### 执行方式选择

**子agent并行**（Claude Code，推荐）:
- 每个无依赖任务dispatch一个子agent
- 子agent收到完整上下文（项目信息 + 任务详情 + TDD规则）
- 主agent监控进度和集成

**内联顺序**（Cursor/Copilot/其他）:
- 按依赖顺序逐个执行任务
- 同样遵循TDD流程
- 适合无子agent支持的平台

### TDD铁律

无论哪种执行方式，测试驱动开发是不可妥协的：

```
RED     → 写一个测试，运行，确认它失败
验证RED → 失败原因是"功能未实现"而非"语法错误"
GREEN   → 写最小代码使测试通过
验证GREEN → 运行所有测试，全部通过
REFACTOR → 改善代码结构，保持测试绿色
```

**铁律**: 如果发现自己在没有失败测试的情况下写了生产代码——停下来，删掉代码，先写测试。

详细TDD流程见 `execution-guide.md`

### 子agent调度

详见 `execution-guide.md` 的"子agent调度"章节和 `agents/implementer.md`

### 系统调试

遇到问题时使用四阶段法：
1. 根因调查
2. 假设形成
3. 验证
4. 修复

详见 `execution-guide.md` 的"系统调试四阶段"

### Git提交规范

每完成一个task提交一次：

```
<type>(<scope>): <简短描述>

<详细说明（可选）>
```

类型：feat, fix, refactor, test, docs

---

## Phase 7: 审查 (Standard及以上)

### 目标

通过三层质量网，在不同层面捕获问题。

### 第一层：自我审查（所有模式，30秒）

每完成一个任务立即执行：

**代码完整性**:
- 无TODO/FIXME/HACK遗留
- 无注释掉的代码
- 无调试用临时代码

**测试覆盖**:
- 正常路径有测试
- 边界情况有测试
- 错误路径有测试

**安全基线**:
- 用户输入有验证和清洗
- 无SQL拼接（使用参数化查询）
- 无XSS风险（输出有转义）
- 敏感信息未暴露在日志或错误消息中
- 无硬编码密钥或凭证

详细清单见 `review-verify.md`

### 第二层：规范符合审查（仅Strict，子agent）

Dispatch `spec-reviewer` 子agent：
- 对比specs/中的每个Requirement和Scenario
- 检查实现是否完整覆盖所有规范要求
- 标记偏差——是改进还是遗漏

详见 `agents/spec-reviewer.md` 和 `review-verify.md`

### 第三层：代码质量审查（Standard+，子agent）

Dispatch `code-reviewer` 子agent：
- 架构设计合理性
- 代码风格与项目约定一致
- 错误处理完善
- 无过度工程或过少工程
- 问题分级：Critical / Important / Suggestion

详见 `agents/code-reviewer.md` 和 `review-verify.md`

### 审查结果处理

- **Critical**: 必须修复，阻塞完成
- **Important**: 应该修复，除非有充分理由不修
- **Suggestion**: 记录但不阻塞，由用户决定

对每个审查意见做技术评估，不要表演性同意。如果审查意见有误，说明为什么。

---

## Phase 8: 验证

### 目标

提供可验证的证据，证明变更达到了预期效果。

### 验证原则

1. **运行而非声称**: 不是"我认为测试应该通过"，而是"我运行了测试，结果如下"
2. **完整而非抽样**: 运行全部测试套件，不只是新增的
3. **真实而非模拟**: 如果可以集成测试，优先于mock
4. **捕获输出**: 把运行结果作为证据

### 验证清单

**必选项（所有模式）**:
- [ ] 运行完整测试套件，附上完整输出
- [ ] 新增测试数量和覆盖内容
- [ ] 无跳过(skip)的测试

**Standard+额外项**:
- [ ] 构建成功（如适用）
- [ ] Lint通过（如适用）
- [ ] 类型检查通过（如适用）

**Strict额外项**:
- [ ] 所有规范场景都有对应通过的测试
- [ ] 性能基准测试（如有要求）
- [ ] 安全扫描（如有要求）

### 验证报告格式

```markdown
## 验证结果

### 自动化测试
命令: `npm test`
结果:
```
通过: 47 | 失败: 0 | 跳过: 0
```
新增: 5个测试

### 构建验证
命令: `npm run build`
结果: 成功，无警告

### 手动验证（如适用）
- [x] 创建用户 → 返回201，数据正确
- [x] 重复邮箱 → 返回409，错误信息友好
```

详见 `review-verify.md`

---

## Phase 9: 归档（仅Strict模式）

### 目标

保留上下文供将来追溯。三个月后新同事问"这个为什么这样设计"，可以直接指向archive。

### 归档步骤

1. **合并Delta规范**（如有）
   - 将specs/中的Delta规范合并到主规范 `docs/spec-power/specs/`
   - 应用ADDED/MODIFIED/REMOVED操作

2. **移动变更目录**
   ```bash
   mv docs/spec-power/changes/<change-name>-YYYYMMDDHHMMSS \
      docs/spec-power/archive/YYYY-MM-DD-<name>/
   ```

3. **保留完整上下文**
   - archive中保留完整的proposal、design、tasks、specs
   - 这些文档记录了决策的"为什么"

### 归档价值

- 历史追溯：理解"为什么当时这样设计"
- 模式复用：类似问题可参考之前的方案
- 团队学习：新人了解系统演化历程

---

## Phase 10: 收尾清理

### 目标

闭合 Git Worktree 生命周期——整合分支、清理隔离环境、更新变更状态。没有这一步，worktree 和分支会在本地持续积累，`git worktree list` 和 `git branch` 越来越乱。

### 适用条件

- **Strict 模式**: 必需（因为 Strict 强制使用 worktree）
- **Standard/Flow 模式**: 如果创建了 worktree 则必需，否则跳过
- **前置条件**: Phase 8 验证通过，Phase 9 归档完成（如适用）

### Step 1: 确认测试通过

在提供选项之前，必须验证当前测试全部通过：

```bash
# 运行项目的测试套件
npm test / cargo test / pytest / go test ./...
```

**测试失败则停止**，不提供后续选项。先修复问题再继续。

### Step 2: 确定基准分支

```bash
# 检测基准分支
git merge-base HEAD main 2>/dev/null || git merge-base HEAD master 2>/dev/null
```

或直接确认："这个变更是从 main 分出来的，对吗？"

### Step 3: 提供结构化选项

不问开放性问题，直接提供 4 个选项：

```
实现完成，验证通过。选择收尾方式：

1. 合并到 <base-branch> 并清理
2. 推送并创建 Pull Request
3. 保留当前状态（稍后处理）
4. 废弃此变更
```

### Step 4: 执行用户选择

#### 选项 1: 合并到主分支并清理

```bash
# 切到基准分支
git checkout <base-branch>

# 拉取最新
git pull

# 合并变更分支
git merge spec-power/<change-name>-YYYYMMDDHHMMSS

# 合并后再次验证测试
<test command>

# 测试通过后删除分支
git branch -d spec-power/<change-name>-YYYYMMDDHHMMSS
```

然后执行 Step 5 清理 worktree。

更新 `.specpower.yaml`:
```yaml
status: done
```

#### 选项 2: 推送并创建 PR

```bash
# 推送分支
git push -u origin spec-power/<change-name>-YYYYMMDDHHMMSS

# 创建 PR
gh pr create --title "<标题>" --body "$(cat <<'EOF'
## 变更概要
<2-3 条要点>

## 验证
- [x] 测试全部通过
- [x] <其他验证项>
EOF
)"
```

然后执行 Step 5 清理 worktree。

更新 `.specpower.yaml`:
```yaml
status: review
```

#### 选项 3: 保留当前状态

报告："保留分支 `spec-power/<name>` 和 worktree `.worktrees/<name>/`。"

**不清理 worktree，不更新 status**。

#### 选项 4: 废弃变更

**必须先确认**，列出将要删除的内容：

```
即将永久删除：
- 分支: spec-power/<change-name>-YYYYMMDDHHMMSS
- Worktree: .worktrees/<change-name>-YYYYMMDDHHMMSS/
- 包含的提交: <commit list>

确认废弃请输入 'discard'。
```

等待用户确认后执行：

```bash
git checkout <base-branch>
git branch -D spec-power/<change-name>-YYYYMMDDHHMMSS
```

然后执行 Step 5 清理 worktree。

更新 `.specpower.yaml`:
```yaml
status: archived
```

### Step 5: 清理 Worktree

**选项 1、2、4** 需要清理；**选项 3** 保留。

**Claude Code（自动）**:

```
# 选项 1、4（完全清理）
ExitWorktree(action="remove")

# 选项 2（保留到 PR 合并，或先清理）
ExitWorktree(action="keep")  # 或 action="remove" 如果代码已推送
```

**其他平台（手动）**:

```bash
# 退出 worktree 目录
cd <原始项目根目录>

# 移除 worktree
git worktree remove .worktrees/<change-name>-YYYYMMDDHHMMSS

# 如果 worktree remove 失败（有未提交修改），强制移除（仅选项 4）
git worktree remove --force .worktrees/<change-name>-YYYYMMDDHHMMSS
```

**收尾脚本（可选）**:

```bash
./scripts/finish-change.sh <change-name>-YYYYMMDDHHMMSS [merge|pr|keep|discard]
```

### 选项速查表

| 选项 | Merge | Push | 保留 Worktree | 清理分支 | status |
|------|-------|------|--------------|---------|--------|
| 1. 合并并清理 | Yes | - | No | Yes | done |
| 2. 创建 PR | - | Yes | 可选 | No | review |
| 3. 保留现状 | - | - | Yes | No | 不变 |
| 4. 废弃 | - | - | No | Yes (force) | archived |

### 安全原则

**永远不要**:
- 在测试失败时提供选项
- 在合并后不验证测试
- 不确认就废弃变更
- 未经请求 force push

**永远**:
- 先验证测试再提供选项
- 废弃前要求用户输入 'discard' 确认
- 合并后再次运行测试
- 选项 1 和 4 清理 worktree，选项 3 保留

---

## 平台适配总结

| 能力 | Claude Code | Cursor | Copilot/其他 |
|------|------------|--------|-------------|
| 子agent并行 | Yes | No | No |
| Git worktree (Strict) | 自动 | 手动必需 | 手动必需 |
| Git worktree (Standard/Flow) | 自动 | 手动可选 | 手动可选 |
| Worktree 收尾清理 | ExitWorktree | 手动/脚本 | 手动/脚本 |
| 工件系统 | Yes | Yes | Yes |
| TDD流程 | Yes | Yes | Yes |
| 两阶段审查 | 子agent | 内联 | 内联 |

无子agent时的降级策略：
- 审查改为自我审查（用清单代替独立子agent）
- 并行执行改为顺序执行
- 所有工件和质量规则不变

---

## 常见问题

### 如何判断某个步骤是否可以跳过？

不能跳过的：
- TDD流程（任何模式）
- 自我审查（任何模式）
- 验证（任何模式）

可以根据模式简化的：
- 提案（Flow：口头；Standard+：文档）
- 设计（Flow：无；Standard+：必需）
- 规范（仅Strict：必需）
- 多层审查（Flow：自审；Standard：自审+代码审查；Strict：全部三层）

### 如果中途想切换模式怎么办？

- **降级**（Strict→Standard→Flow）：随时可以，保留已完成的工件
- **升级**（Flow→Standard→Strict）：补充缺失的工件（提案、设计、规范）

### 工件文件应该由谁创建？

- **脚本创建结构**：使用 `scripts/init-change.sh` 创建目录和模板
- **Claude填充内容**：所有占位符由Claude根据实际需求填充
- **人工参与**：在关键决策点（模式选择、方案对比）与用户确认
