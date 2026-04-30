# 任务完成声明模板 (Standard+)

> **定位变化 (v1.11.0)**: 自 v1.11.0 起, 审查是否做过 **以 `reviews/` 产物文件为权威** (见 `review-artifact-protocol.md`)。
> 对话声明不再是唯一证据, 降级为 **给控制器/用户看的快速摘要**。

---

## 何时输出

每个任务在执行 `TaskUpdate` 标记 `completed` 之前, 控制器输出一次声明。声明内容应 **从 `reviews/` 产物文件派生**, 不要手工编造。

---

## 精简声明模板 (推荐, v1.11.0)

```
## Task N 完成声明 (摘要)
- **TDD**: RED ✅ → GREEN ✅ → REFACTOR ✅
- **Reviews**: self ✅ | spec ✅执行 / ⏭跳过 | code ✅执行 / ⏭跳过
- **产物**: reviews/task-N-self.md, task-N-spec(-skip).md, task-N-code(-skip).md
- **修复闭环**: 无问题 | 已修复 N 项 Critical/Important
- **Commit**: `<hash>` — <type>(<scope>): <任务简述>
```

控制器可直接 `cat reviews/task-N-*.md` 的 frontmatter `verdict` 字段填充, 无需手写判断。

---

## 详细声明模板 (兼容 v1.10.0)

如果团队尚未启用产物化机制 (v1.11.0 过渡期), 继续沿用 v1.10.0 的详细模板:

```
## Task N 完成声明
- **TDD**: RED ✅ → GREEN ✅ → REFACTOR ✅
- **自审**: ✅ (代码完整性 / 测试覆盖 / 安全基线)
- **规范审查**: ✅ 已执行 | ⏭️ 跳过 (原因: diff X 行 < 100, 无强制例外)
- **代码审查**: ✅ 已执行 | ⏭️ 跳过 (原因: diff X 行 < 20, 无强制例外)
- **修复闭环**: 无问题 | 已修复 N 项 Critical/Important
- **Commit**: `<hash>` — <type>(<scope>): <任务简述>
```

**跳过理由规范**: 有效/无效理由示例见 `skip-policy.md`。

---

## 与产物文件的关系

| 声明字段 | 对应产物 | 权威源 |
|---------|---------|--------|
| TDD 状态 | 测试运行输出 | 终端输出 |
| 自审 | `reviews/task-N-self.md` | 产物文件 |
| 规范审查 | `reviews/task-N-spec.md` 或 `-skip.md` | 产物文件 |
| 代码审查 | `reviews/task-N-code.md` 或 `-skip.md` | 产物文件 |
| 修复闭环 | `task-N-*.md` 的 `verdict` + 后续修复 commit | 产物文件 + git log |
| Commit | `git log -1 --format=%H` | git 历史 |

**规则**: 声明字段与产物冲突时, **产物优先**。声明用于人类阅读, 产物用于机器校验。

---

## 违规判定

### v1.10.0 判定 (声明驱动, 过渡期仍有效)

- 未输出声明 → 违规
- 声明中跳过理由在黑名单内 → 违规
- 声明字段虚报 (例如声明 "已执行" 但实际未 dispatch 子 agent) → 违规

### v1.11.0 判定 (产物驱动, 主判定路径)

- `reviews/` 目录下缺少任一必需文件 → 违规 (由 `verify-task-reviews.sh` 自动检测)
- 跳过声明 frontmatter 缺字段 → 违规
- 跳过声明中 `diff_lines` 与实际 staged diff 偏差 > 20% → 违规

**两路判定并存**: 无论走哪一路, 触发违规均按 `discipline-recovery.md` 处置。

---

## 快速使用指引

执行 Phase 6 Step 5.5 时:

1. `ls reviews/task-N-*.md` — 列出已产出的审查文件
2. 逐文件提取 frontmatter 中的 `verdict` 或 `type`, 填充上面精简模板的对应字段
3. 粘贴 commit hash (Step 6 产生)
4. 输出到对话 → 执行 `TaskUpdate` 标记 completed
