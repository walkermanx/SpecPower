# 违规处置与规则退役机制

> 本文档定义: (a) 检测到违反 SpecPower 铁律后的处置流程; (b) 规则退役机制 — 为什么规则总数不应单调增长。

---

## 违规检测触发器

任一触发器命中即视为违规, 执行下方处置流程:

### v1.11.0 产物驱动 (主路径)

- `scripts/verify-task-reviews.sh` 退出码非 0 (`reviews/` 文件缺失或 frontmatter 无效)
- Task status 为 `completed` 但 `.specpower.yaml` `tasks[].reviews` 字段为空
- commit message 缺少 `Reviews:` trailer
- 跳过声明中 `diff_lines` 与实际 staged diff 偏差 > 20%

### v1.10.0 声明驱动 (兼容路径, 仍生效)

- 未输出任务完成声明就调用 `TaskUpdate` 标记 `completed`
- 声明中跳过理由使用黑名单措辞 (见 `skip-policy.md`)
- 声明中未说明 diff 行数或未明确检查强制例外

### 其他铁律违反

- 批量提交 (单个 commit 跨越 2+ 任务)
- 跳过 TDD (修改了含逻辑的代码但没有先写失败测试)
- 静默跳过提案确认门 / 设计确认门
- 在 Strict 模式下未创建 Worktree 直接在主工作树修改

---

## 处置流程

### Step 1: 停止当前推进

- 立刻停止下一任务的实施
- 在对话中明确标注: "检测到违规: <具体触发器>。按 `discipline-recovery.md` 处置。"

### Step 2: 回退受影响任务状态

- 将违规任务及其后所有标记为 `completed` 的任务回退到 `in_progress`
- **不要**运行 `git reset` 或其他破坏性命令 — 保留现有 commit 作为证据
- 如果 `.specpower.yaml` 中 `tasks` 字段有更新, 一并回退 `status`

### Step 3: 补齐缺失内容

| 违规类型 | 补齐动作 |
|---------|---------|
| 缺少 `task-N-self.md` | 重新执行 30 秒自审清单, 写入文件 |
| 缺少 `task-N-spec.md` / `-skip.md` | Dispatch 子 agent 补审 或 按 skip-policy.md 写跳过声明 |
| 缺少 `task-N-code.md` / `-skip.md` | 同上 |
| 跳过声明 frontmatter 不完整 | 补全字段 |
| 跳过声明 `diff_lines` 偏差过大 | 重新计算并校正 |
| 缺少 commit trailer | 用 `git commit --amend` 补 trailer **仅在最近一个 commit** (不要 rebase 修改早期 commit) |

### Step 4: 重新校验

- 运行 `scripts/verify-task-reviews.sh <dir> <task-id>` 逐任务校验
- 全部通过后, 方可恢复任务执行

### Step 5: 后续任务独立提交

- 已打包的批量 commit **保留**, 作为历史证据
- 但从违规任务之后的所有任务, **每个任务必须独立 commit**, 不可再批量

---

## 规则退役机制 (v1.11.0 引入)

**原则**: 规则总数不应单调增长。每个 minor 版本发布时, 审视上一 minor 新增的规则, 若已被工具化机制覆盖 → 删除规则。

### 判定标准 "规则可退役"

一条规则可以退役, 当且仅当:

1. **工具能自动检测违规**: 存在可在 CI / pre-commit / commit trailer 中自动触发的检查
2. **违规已不可能绕过**: LLM 即使想绕过也会被工具拦截
3. **保留规则仅增加阅读成本**: 规则文本对开发者已经是冗余信息

### v1.11.0 已退役/降级的规则候选

以下规则在 v1.11.0 的产物化机制下已 **不再需要** 作为 SKILL.md 中的独立声明:

- ❌ "必须在对话中输出任务完成声明" → 降级为 `task-declaration.md` 中的参考模板, 权威判定转为 `verify-task-reviews.sh`
- ❌ "跳过理由必须含 diff 行数 + 强制例外结论" → 降级到 `skip-policy.md`, 由 frontmatter 必填字段自动强制
- ❌ "违规处置流程" → 不再在 SKILL.md 展开, 仅指针到本文档

### v1.11.0 保留的铁律

以下是无法工具化、必须留在 SKILL.md 的铁律:

- ✅ **TDD 铁律** — 无法通过文件校验, 依赖测试执行历史 + commit 时序
- ✅ **逐任务 commit** — 可部分工具化 (`verify-task-reviews.sh` 间接强制), 但需概念性强调
- ✅ **提案确认门 / 设计确认门** — 依赖用户对话交互, 无法工具化
- ✅ **禁止静默跳过** — 核心纪律, 虽然落地到产物层, 仍需理念级声明
- ✅ **验证必须运行** — 依赖证据而非声明, 纪律层面

### 退役的评估时机

- 每次发布 minor 版本时 (v1.12, v1.13, ...)
- 用户反馈 SKILL.md 过长时
- 发现某条规则连续 3 个 minor 版本没有被 "工具 + LLM" 任一路径违反时

---

## 为什么需要退役

v1.8 → v1.10 的教训: 每次 LLM 绕过一条规则就叠加一条新规则, SKILL.md 从 v1.8 的 206 行膨胀到 v1.10 的 320 行。这是 prompt-level 的军备竞赛, 收益递减。

v1.11.0 转向 **工具层强制 + 规则层瘦身** 的组合:
- 工具 (`verify-task-reviews.sh` + frontmatter + git trailer) 拦截具体违规
- 规则只保留 "工具无法覆盖" 的铁律
- 规则膨胀的源头 (声明模板 / 黑名单列表 / 违规处置) 被移到按需加载的 references

**目标**: 让 SKILL.md 长度随时间保持稳定或下降, 而非单调增长。

---

## 跨版本兼容性

v1.11.0 过渡期内:
- 旧版本的 changes 目录 (无 `reviews/`) 仍可推进, 但会收到警告, 推荐升级到 v1.11.0 产物化
- `.specpower.yaml` 缺少 `tasks` 字段时, `verify-task-reviews.sh` 降级为 "不强制校验" 模式, 退回到对话声明判定
- 从 v1.12.0 起, 产物化为硬要求, 不再支持对话声明作为唯一证据
