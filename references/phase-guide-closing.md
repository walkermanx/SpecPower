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
   - 将specs/中的Delta规范合并到主规范 `docs/spec-power/specs/`
   - 应用ADDED/MODIFIED/REMOVED操作

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

详见 SKILL.md 的"平台适配"章节。关键差异：
- Claude Code 支持子agent并行和自动 Worktree 管理
- 其他平台使用内联审查、手动 Worktree 操作、顺序执行

各阶段的具体平台适配说明见上文对应章节。

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
