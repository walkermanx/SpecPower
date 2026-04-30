# 跳过规则与理由规范 (Standard+)

> **核心铁律**: 任何 "可跳过/触发时执行" 的步骤, 跳过时 MUST 落盘产物 + 声明原因。沉默 = 违规。
> v1.11.0 起, 跳过必须产出 `task-N-{spec|code}-skip.md` 文件 (见 `review-artifact-protocol.md`)。

---

## 可跳过的步骤与前置条件

| 步骤 | 可跳过的前置条件 | 落盘位置 |
|------|----------------|---------|
| Phase 1.5 需求澄清 | 用户需求已包含完整输入/输出/边界/约束 | 提案中加一行说明 |
| Phase 6 Step 3 规范符合审查 | Standard: diff < 100 行 且 无强制例外 | `reviews/task-N-spec-skip.md` |
| Phase 6 Step 4 代码质量审查 | Standard: diff < 20 行 且 无强制例外 | `reviews/task-N-code-skip.md` |
| Worktree 隔离 (Standard/Flow) | 非共享环境、单人短期任务 | 无需产物, 对话说明即可 |

**强制例外清单** (无论行数、无论模式, 必须审查):
- 安全 (认证 / 授权 / 注入 / 敏感数据)
- SQL 与数据库交互 (查询构造 / schema 变更 / 迁移脚本)
- 并发 / 锁 / 事务
- 金额 / 精度 / 舍入
- 公开 API / 契约变更

**Strict 模式**: 所有 Step 3 / Step 4 逐任务强制触发, 不存在跳过场景 (无需产出 -skip 文件)。

---

## 有效跳过理由 (✅ 示例)

所有有效理由的共同点: **具体 + 有数据 (行数) + 显式检查过强制例外**。

- ✅ "Task 1 diff 仅 8 行, 修改 XML 布局属性, 不涉及安全/SQL/并发/金额/公开API, 跳过代码审查"
- ✅ "Task 2 为纯数据类定义 (15 行), 无业务逻辑, 跳过规范审查"
- ✅ "用户需求已给出完整输入输出和 5 条约束, 跳过 Phase 1.5 澄清"
- ✅ "Task 5 diff 42 行修改 CSS 变量定义, 用 grep 确认未命中强制例外清单任一条目, 跳过代码审查"

---

## 无效跳过理由 (❌ 黑名单)

以下措辞 **即使其他字段完整** 也视为违规声明:

- ❌ "代码简单" / "明显正确" / "这里不需要审查" — 模糊, 无法核实
- ❌ 未说明 diff 行数
- ❌ 未提及是否检查过强制例外清单
- ❌ "最后一起审" / "等 Phase 7 全局审查再看" — 违反逐任务循环铁律
- ❌ "先提交再说" / "后续任务一起审" — 同上
- ❌ **沉默不声明 / 不产出 skip 文件** — 直接视为违规

---

## 产物填写规范

跳过声明文件 (`task-N-{spec|code}-skip.md`) 必须包含:

1. **frontmatter** — `task`, `type`, `timestamp`, `diff_lines`, `threshold`, `forced_exception_check` 五个必填字段
2. **跳过依据** — diff 行数 vs 阈值的对比
3. **强制例外清单勾选** — 5 条逐一标注 "未命中" 或 "命中 (命中则不应跳过)"
4. **变更性质描述** — 一两句话说明任务实际内容, 供审阅者判断是否真属于可跳过类别

详细格式见 `review-artifact-protocol.md` → "`task-N-spec-skip.md` / `task-N-code-skip.md`"。

---

## 校验机制

- **自动校验** — `scripts/verify-task-reviews.sh` 在 commit 前扫描 frontmatter 必填字段、对比 `diff_lines` 与实际 staged diff (容差 ±20%)
- **对话校验** — 控制器读取 skip 文件的 "变更性质描述", 如与 diff 内容明显不符 (例如声明 "纯 UI 调整" 但 diff 含 SQL), 视为违规
- **事后校验** — Phase 7 "小变更补位审查" 回顾所有 `-skip` 文件, 确认没有遗漏的强制例外

三层校验任一触发违规 → 按 `discipline-recovery.md` 处置流程执行。
