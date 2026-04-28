# 工件系统概览

本文档讲工件依赖图、状态机与 `.specpower.yaml` 元数据格式——也就是"SpecPower 的工作流结构"。具体模板和 Delta 语法在单独文件里,按需查阅:

- **工件模板**(proposal / design / 多角色 / tasks / behavior-changes) → `templates.md`
- **Delta 规范 + 基线规范**(Strict 模式的 specs/ 内容) → `artifact-delta-specs.md`

---

## DAG 模型

工件形成有向无环图(DAG),依赖关系决定了创建顺序,但不是硬性门控——满足依赖的工件可以并行创建。

### 工件定义

| 工件 | 生成文件 | 依赖 | 所属模式 |
|------|---------|------|---------|
| explore | (结论内嵌于proposal) | 无 | Strict |
| clarify | (结论内嵌于proposal) | explore(如有) | Standard+ |
| proposal | `proposal.md` | clarify(如有) | 所有 |
| specs | `specs/**/*.md` | proposal | Strict |
| design | `design.md` | proposal | Standard+ |
| tasks | `tasks.md` | specs(如有) + design | Standard+ |
| implementation | 源代码(含逐任务审查) | tasks(Standard+) 或 proposal(Flow) | 所有 |
| review | (全局审查记录) | implementation | Standard+ |
| verification | (验证报告) | review(Standard+) 或 implementation(Flow) | 所有 |
| behavior-changes | `behavior-changes.md` | verification | Standard+ |
| archive | `archive/` 目录 | verification | Strict |
| finish | (分支整合) | verification + archive(如有) | 所有 |

**注**: explore 和 clarify 虽不生成独立文件,但在 `.specpower.yaml` 中追踪以反映工作流进度。

### 状态转移

每个工件有三种状态:

```
BLOCKED ──► READY ──► DONE
```

- **BLOCKED**: 有未完成的依赖
- **READY**: 所有依赖已完成,可以开始创建
- **DONE**: 文件已存在且通过自审

### 并行机会

在 Strict 模式中,specs 和 design 都只依赖 proposal,可以并行创建。识别这种机会能显著加速工作流。

---

## .specpower.yaml 格式

每个变更目录根下都有一个 `.specpower.yaml`,记录模式、基准分支、状态和工件进度。跨会话恢复时,skill 读此文件判断从哪里继续。

### Standard 模式示例

```yaml
name: add-user-avatars-20260407143025
mode: standard              # flow | standard | strict
created: 2026-04-07
base_branch: main           # 创建时所在的分支(收尾时合并回此分支)
status: in-progress          # in-progress | review | done | archived
# 状态流转: in-progress → done (合并) | in-progress → review (PR) → done (PR合并后手动更新) | in-progress → archived (废弃)
artifacts:
  clarify: done
  proposal: done
  design: done
  tasks: in-progress
  implementation: blocked
  review: blocked
  verification: blocked
  finish: blocked
```

### Strict 模式示例

```yaml
name: refactor-auth-20260407143025
mode: strict
created: 2026-04-07
base_branch: feature/api-v2  # 创建时所在的分支(收尾时合并回此分支)
status: in-progress
artifacts:
  explore: done
  clarify: done
  proposal: done
  specs: done
  design: done
  tasks: in-progress
  implementation: blocked
  review: blocked
  verification: blocked
  archive: blocked
  finish: blocked
```

Flow 模式不创建变更目录,不生成 `.specpower.yaml`,因此 Flow 任务不支持跨会话恢复,应在单次会话内完成。

---

## 按需查阅

- 需要**具体模板**(proposal.md、design.md、tasks.md 等怎么填)→ `templates.md`
- 需要 **Delta 规范格式**(ADDED/MODIFIED/REMOVED、RFC 2119、场景编写、基线规范)→ `artifact-delta-specs.md`
- 需要各 Phase 的执行步骤和清单 → `phase-guide-planning.md` / `phase-guide-execution.md` / `phase-guide-closing.md`
