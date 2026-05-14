# 产物化审查协议 (v1.11.0 新增)

> 本协议把"审查做没做"从对话断言升级为 filesystem 可验证事实。
> 适用模式: Standard, Strict (Flow 模式完全不适用——Flow 不创建变更目录)。

---

## 核心原则

**每一次审查(包括跳过)都必须落盘为文件产物。**

对话中的声明可以编造、可以遗忘、跨会话会丢失;产物文件不会。审查是否做过、跳过是否合理,都能通过文件存在性、结构化字段、git 历史三层交叉验证。

这是对 v1.10.0 "任务完成声明" 机制的升级: 声明不再只存在于对话,而是以 markdown 文件形式写入变更目录的 `reviews/` 子目录,并被 git commit trailer 引用。

---

## 审查产物目录结构

```
docs/spec-power/changes/<name>-<timestamp>/
├── .specpower.yaml
├── proposal.md
├── design.md
├── tasks.md
└── reviews/                    # 新增目录, Standard+ 必需
    ├── task-1-self.md          # 自审报告 (所有任务强制)
    ├── task-1-spec.md          # 规范审查报告 (执行时)
    ├── task-1-spec-skip.md     # 规范审查跳过声明 (跳过时; 与 task-1-spec.md 互斥)
    ├── task-1-code.md          # 代码审查报告 (执行时)
    ├── task-1-code-skip.md     # 代码审查跳过声明 (跳过时; 与 task-1-code.md 互斥)
    ├── task-2-self.md
    ├── ...
    └── global-review.md        # Phase 7 全局审查报告 (Standard+ 必需)
```

**强制约束**:
- 每个任务至少产生 1 个 `task-N-self.md` (自审, 不可跳过)
- 每个任务必须有 `task-N-spec.md` **或** `task-N-spec-skip.md` 二选一, 不可两者都无
- 每个任务必须有 `task-N-code.md` **或** `task-N-code-skip.md` 二选一, 不可两者都无
- Phase 7 结束必须有 `global-review.md`

---

## 审查报告文件格式

### `task-N-self.md` — 自审报告

```markdown
---
task: N
type: self-review
timestamp: 2026-04-30T10:15:00Z
diff_lines: 42
files_changed: [src/foo.ts, tests/foo.test.ts]
tdd_evidence: runtime-red | exempt-config | exempt-style | exempt-doc | exempt-infra | exempt-static
---

# Task N 自审报告

## 代码完整性
- [x] 无 TODO/FIXME/HACK
- [x] 无注释掉的代码
- [x] 无调试用临时代码

## 测试覆盖
- [x] 正常路径有测试
- [x] 边界情况有测试
- [x] 错误路径有测试

## 安全基线
- [x] 输入验证 (不涉及/已验证)
- [x] 无 SQL 拼接
- [x] 敏感信息未暴露
- [x] 无硬编码凭证

## 强制例外检查
触发: 无 | 涉及(安全/SQL/并发/金额/公开API)
说明: <如触发,说明具体条目>

## TDD 证据

### tdd_evidence: runtime-red 时 (强制流程)
**RED 阶段**:
- 执行命令: `<例如 ./gradlew :app:testDebugUnitTest --tests "..."> `
- 关键输出 (≤30 行 stderr/stdout, 必须包含 runtime assertion 失败行):
  ```
  <从 implementer 报告原样粘贴>
  ```
- stub 故意错误说明: <一句话, 例如 "isContinuousDialogTarget stub 永远 return false">

**GREEN 阶段**:
- 执行命令: `<同上>`
- 关键输出 (≤20 行, 测试全绿摘录):
  ```
  <从 implementer 报告原样粘贴>
  ```

### tdd_evidence: exempt-* 时
- 豁免类别: <config / style / doc / infra / static>
- 豁免理由: <一句话, 为什么这次改动不需要自动化测试>
- 替代验证方法: <运行系统观察 / 视觉检查 / 渲染效果 / 加载测试>
- 替代验证结果: <≤5 行说明>

## 结论
通过 | 发现问题: <描述>
```

> **`tdd_evidence` 字段语义**:
> - `runtime-red`: 本任务做了 stub-first runtime RED + GREEN, body 必须有 `## TDD 证据` 章节附两段原始输出 (从 implementer 完成报告复制)
> - `exempt-config` / `exempt-style` / `exempt-doc` / `exempt-infra` / `exempt-static`: 命中 `references/execution-guide.md` "TDD 适用范围" 中的豁免列表; 不需要 RED/GREEN 证据但 body 必须有替代验证摘要
>
> `verify-task-reviews.sh` 强制校验该字段及对应 body 章节存在; 详见下方 "Pre-commit 校验脚本"。

### `task-N-spec.md` — 规范审查报告

由 `spec-reviewer` 子 agent 产出, 格式见 `agents/spec-reviewer.md`。保存时必须在文件首部增加 frontmatter:

```markdown
---
task: N
type: spec-review
reviewer: spec-reviewer
timestamp: 2026-04-30T10:20:00Z
diff_lines: 42
forced_exception: false  # true 表示命中强制例外
verdict: pass | fail | pass-with-concerns
---

# Task N 规范符合审查报告

<子 agent 的结构化输出, 含覆盖总结、偏差报告、场景覆盖、确认通过需求、总结>
```

### `task-N-code.md` — 代码审查报告

由 `code-reviewer` 子 agent 产出, 同理, 首部 frontmatter:

```markdown
---
task: N
type: code-review
reviewer: code-reviewer
timestamp: 2026-04-30T10:25:00Z
diff_lines: 42
forced_exception: false
verdict: pass | fail | pass-with-concerns
---

# Task N 代码质量审查报告

<子 agent 的结构化输出, 含总体评估、问题列表、亮点、总结>
```

### `task-N-spec-skip.md` / `task-N-code-skip.md` — 跳过声明

```markdown
---
task: N
type: spec-review-skip | code-review-skip
timestamp: 2026-04-30T10:20:00Z
diff_lines: 8
threshold: 100 | 20
forced_exception_check: none  # none | sql | security | concurrency | money | public_api
---

# Task N <规范|代码>审查跳过声明

## 跳过依据
- Diff 行数: 8 行 (阈值: 100 行)
- 强制例外检查: 无命中

## 具体检查
- [x] 不涉及安全/认证/授权代码路径
- [x] 不涉及 SQL 或数据库查询构造
- [x] 不涉及并发/锁/事务
- [x] 不涉及金额/精度/舍入
- [x] 不涉及公开 API 或契约变更

## 变更性质描述
<一两句话说明本任务的实际内容, 例如: "修改 XML 布局属性, 将按钮宽度从 match_parent 改为 wrap_content, 纯 UI 调整">

## 结论
符合跳过条件, 按协议跳过本项审查。
```

---

## `.specpower.yaml` 扩展

在原有结构上增加 `tasks` 字段, 记录每个任务的审查产物:

```yaml
name: add-user-avatars-20260430101500
mode: standard
created: 2026-04-30
base_branch: main
status: in-progress
artifacts:
  proposal: done
  design: done
  tasks: done
  implementation: in-progress
  review: blocked
  verification: blocked
  finish: blocked
tasks:                              # 新增字段
  - id: 1
    status: completed
    reviews:
      self: reviews/task-1-self.md
      spec: reviews/task-1-spec-skip.md   # 可以是 -skip 或正式报告
      code: reviews/task-1-code.md
    commit: a3f2b1c
  - id: 2
    status: in_progress
    reviews: {}                     # 尚未产出
```

**校验脚本会读取此字段**, 对每个 `status: completed` 的任务检查 3 个 review 文件是否存在、是否可读、frontmatter 是否完整。

---

## Git Commit Trailer 约定

为了让 commit 历史也能追溯审查,控制器在执行 `git commit` 时必须在消息尾部添加 trailer:

```
feat(auth): 实现邮箱验证逻辑

<详细说明>

Task: 3
Reviews: reviews/task-3-self.md, reviews/task-3-spec.md, reviews/task-3-code-skip.md
```

**为什么用 trailer 而非正文**:
- `git log --grep="Reviews:"` 可批量查询
- 保留人类可读的 commit 消息主体
- 兼容 Conventional Commits 格式

---

## Pre-commit 校验脚本

位置: `scripts/verify-task-reviews.sh`

**调用时机**:
1. 手动: 控制器在执行 `git commit` 前调用一次
2. 自动: 配置为 git pre-commit hook (可选但推荐)

**校验内容**:
- 当前 staged diff 是否对应一个任务 (通过分支 / `.specpower.yaml` 推断)
- 该任务所需的 3 个 review 文件是否存在 (`self.md` + `spec.md|spec-skip.md` + `code.md|code-skip.md`)
- 每个文件的 frontmatter 是否含必填字段 (`task`, `type`, `timestamp`, `verdict` 或 `forced_exception_check`)
- **`task-N-self.md` 的 `tdd_evidence` 字段** (v1.13.0 起必填): 取值在白名单内 (`runtime-red` / `exempt-config` / `exempt-style` / `exempt-doc` / `exempt-infra` / `exempt-static`), 且当值为 `runtime-red` 时 body 必须含 `## TDD 证据` 章节
- 跳过声明中 `diff_lines` 字段与实际 staged diff 行数差距是否 ≤ 20% (防止虚报行数)

**通过条件**: 所有审查文件存在且 frontmatter 有效 → 退出码 0
**失败条件**: 任一缺失或 frontmatter 无效 → 退出码 1, 输出具体缺失项

脚本本身是"建议性工具", 默认在 Phase 6 Step 6 前调用。团队可以把它安装为 git hook 实现硬强制。

---

## 跨会话恢复

进入一个已有变更目录时, 除了读 `.specpower.yaml`, 还要:

1. 扫描 `reviews/` 目录, 列出已有产物
2. 对比 `tasks` 字段中记录的 review 路径, 发现不一致时报告冲突
3. 如果某任务 `status: completed` 但 review 文件缺失, 视为数据损坏, 回退到 `in_progress`

---

## 与 v1.10.0 "任务完成声明" 的关系

v1.10.0 要求在对话中输出结构化声明模板。v1.11.0 不取消该模板, 而是:

- **对话声明**: 保留, 作为人机沟通的快速摘要 (可由 LLM 从产物文件生成)
- **产物文件**: 升级为纪律载体, 不可编造、可交叉验证

换言之, **声明是摘要, 产物是底稿**。违规判定从"声明是否合规"变为"产物是否齐全且合规"。

当 v1.11.0 的产物化机制稳定运行 2-3 个 minor 版本后, 对话声明可以进一步精简 (见 `discipline-recovery.md` 规则退役节)。

---

## 快速参考

| 场景 | 应产出 | 位置 |
|------|--------|------|
| 任何任务完成 | `task-N-self.md` | `reviews/` |
| 规范审查执行 | `task-N-spec.md` | `reviews/` |
| 规范审查跳过 | `task-N-spec-skip.md` | `reviews/` |
| 代码审查执行 | `task-N-code.md` | `reviews/` |
| 代码审查跳过 | `task-N-code-skip.md` | `reviews/` |
| Phase 7 结束 | `global-review.md` | `reviews/` |
| 每次 commit | 消息含 `Reviews:` trailer | git log |
| 每次 commit 前 | 运行 `verify-task-reviews.sh` | 脚本 |
