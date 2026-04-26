# Phase 执行指南 — 收尾阶段 (Phase 9~10)

本文档详细说明 SpecPower 收尾阶段的执行细节。

> **其他阶段**:
> - 规划阶段 (Phase 0~3): `phase-guide-planning.md`
> - 执行阶段 (Phase 4~8): `phase-guide-execution.md`

---

## Phase 9: 归档（仅Strict模式）

### 目标

保留上下文供将来追溯。三个月后新同事问"这个为什么这样设计"，可以直接指向archive。

### 归档步骤

1. **合并Delta规范**（如有）
   - 将 specs/ 中的 Delta 规范合并到主规范 `docs/spec-power/specs/`
   - 应用 ADDED/MODIFIED/REMOVED 操作

   **主规范不存在时的处理**（逐模块判断）:
   - 有 Phase 1 局部基线（带 `type: baseline` 元信息）→ 以基线为起点，应用 Delta 操作
   - 无基线且全是 ADDED → 直接用 ADDED 内容创建主规范
   - 无基线但有 MODIFIED/REMOVED → 异常状态，回退到基于 Delta 中"(之前: ...)"描述重建后合并
   - 合并完成后，移除基线文件的 frontmatter 元信息（主规范不需要此标注）

2. **移动变更目录**
   ```bash
   mv docs/spec-power/changes/<change-name>-YYYYMMDDHHMMSS \
      docs/spec-power/archive/<change-name>-YYYYMMDDHHMMSS/
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

优先从 `.specpower.yaml` 的 `base_branch` 字段读取创建时记录的基准分支，找不到时回退检测：

```bash
# 优先: 从 .specpower.yaml 读取
grep '^base_branch:' docs/spec-power/changes/<change-name>/.specpower.yaml | awk '{print $2}'

# 回退: 检测 main 或 master
git rev-parse --verify main 2>/dev/null && echo "main" || echo "master"
```

向用户确认："这个变更的基准分支是 `<base_branch>`，对吗？"

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

然后执行 Step 5 清理 worktree（推荐 remove，代码已推送到远端）。

更新 `.specpower.yaml`:
```yaml
status: review
# PR 合并后需手动更新为 done
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

# 选项 2（代码已推送，推荐清理）
ExitWorktree(action="remove")
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

## 变更目录管理

### 创建变更

**命名格式**: `<change-name>-YYYYMMDDHHMMSS`

变更目录名称包含时间戳，避免命名冲突并自动记录创建时间。

**示例**:
- `add-user-auth-20260408143025` — 2026年4月8日 14:30:25 创建
- `refactor-payment-20260410091530` — 2026年4月10日 09:15:30 创建

```bash
mkdir -p docs/spec-power/changes/<change-name>-YYYYMMDDHHMMSS
```

### 元数据文件

`docs/spec-power/changes/<change-name>-YYYYMMDDHHMMSS/.specpower.yaml`:

```yaml
name: <change-name>-YYYYMMDDHHMMSS
mode: standard          # flow | standard | strict
created: 2026-04-08
base_branch: feature/login  # 创建时所在的分支（收尾时合并回此分支）
status: in-progress     # in-progress | review | done | archived
# 状态流转: in-progress → done (合并) | in-progress → review (PR) → done | in-progress → archived (废弃)
```

### Git Worktree 隔离

**Strict 模式必需，Standard/Flow 可选**

```
基准分支: <当前所在分支>（创建时自动检测并记录到 .specpower.yaml 的 base_branch 字段）
工作分支: spec-power/<change-name>-YYYYMMDDHHMMSS
Worktree: .worktrees/<change-name>-YYYYMMDDHHMMSS/
```

**Claude Code (自动)**:
```
1. 检测当前分支: git rev-parse --abbrev-ref HEAD → 记录为 base_branch
2. 调用 EnterWorktree(name="<change-name>-YYYYMMDDHHMMSS") 创建隔离环境
3. 将 base_branch 写入 .specpower.yaml
```

**其他平台 (手动)**:
```bash
git worktree add .worktrees/<change-name>-YYYYMMDDHHMMSS -b spec-power/<change-name>-YYYYMMDDHHMMSS $(git rev-parse --abbrev-ref HEAD)
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

### 无子agent时的降级策略

- 多角色设计改为顺序内联（主agent依次切换视角）
- 逐任务审查改为清单驱动的自审（审查维度不变，只是执行方式不同）
- 并行执行改为顺序执行
- 修复→重审闭环改为修复→自审验证
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

- **Claude创建**：根据模式和实际需求直接创建目录结构和工件内容
- **人工参与**：在关键决策点（模式选择、方案对比）与用户确认
