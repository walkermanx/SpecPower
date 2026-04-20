---
name: spec-power
version: "1.7.1"
description: "SpecPower - 规范驱动的开发工作流。触发关键词:'开发新功能'、'重构模块'、'复杂bug'、'架构设计'、'写计划'、'分步做'、'规范化开发'、'拆解任务'、'团队协作'、'核心系统'、'多模块'、'TDD'。自动推荐Flow(快速)/Standard(日常)/Strict(关键)三档模式。Standard+模式含需求澄清阶段(逐个澄清、方向速览、范围确认),强制测试驱动开发,三层质量审查(自审/规范审查/代码审查),支持子agent并行执行。Strict模式Phase 4采用多角色方案对比(架构师/性能专家/资深开发三视角)。适用于所有需要结构化规划的开发工作,不适用于简单查询或单行代码修改。"
---

# SpecPower: 规范驱动的超能力开发工作流

> **更新日志**: [CHANGELOG.md](CHANGELOG.md)

SpecPower 融合了 OpenSpec 的结构化规划能力和 Superpowers 的执行纪律，形成一套完整的软件开发方法论。核心理念：**规划深度匹配任务复杂度，质量门控保障关键节点，灵活迭代而非瀑布僵化**。

---

## 恢复进行中的变更

如果你在新对话中打开项目，检测到有进行中的变更时：

1. **扫描变更目录**
   ```bash
   [ -d docs/spec-power/changes ] && find docs/spec-power/changes -name ".specpower.yaml" -exec grep -l "status: in-progress" {} \;
   ```
   **注意**: Flow 模式不创建变更目录，因此不支持跨会话恢复。Flow 任务应在单次会话内完成。

2. **读取变更状态** — 读取 `.specpower.yaml` 确认模式、工件状态，加载已完成工件。

3. **向用户确认** — 列出变更名、模式、当前阶段，提供：继续 / 新变更 / 查看详情。

4. **恢复上下文** — 切换到对应 worktree（如有）→ 加载工件 → 从第一个 `blocked` 或 `pending` 工件继续。

---

## 模式选择

### Flow 模式 (快速迭代)

```
propose ──► execute ──► verify ──► (finish)
```

**适用**: 单文件修改、小bug修复、简单配置变更、明确的小任务
**判定**: 影响范围 ≤ 2个文件，无跨模块依赖，需求明确无歧义

### Standard 模式 (日常开发)

```
clarify ──► propose ──► design ──► tasks ──► execute ──► review ──► verify ──► (finish)
```

**适用**: 新功能开发、多文件修改、API变更、需要设计决策的任务
**判定**: 影响 3+ 文件，涉及新接口或数据结构，需要权衡取舍

### Strict 模式 (关键系统)

```
explore ──► clarify ──► propose ──► specs ──► design ──► tasks ──► execute ──► review ──► verify ──► archive ──► finish
```

**适用**: 跨模块重构、核心系统修改、团队协作、需要长期维护的功能
**判定**: 影响多个模块，行为变更需要精确记录，多人参与或将来需要追溯
**隔离要求**: 必须使用 Git Worktree 物理隔离

### 如何推荐

**两阶段**: 初判 → 快速验证（边界时） → 确认

**初判信号**:
- Flow: "修改 X.ts"、"修 typo"、"改配置值"、"快速搞定"
- Standard: "重构XX模块"、"添加功能"、涉及 API 和前端
- Strict: "跨多个模块"、"核心系统"、"团队协作"、"仔细做"

**快速验证**（~30s，仅边界情况触发）: Glob 扫描影响范围、Grep 检查耦合度、检查测试覆盖。

**边界保守原则**: Standard/Strict 边界疑似标准就选标准。用户说"快速搞定"降一档，"仔细做"升一档。

> 详细模式评估流程见 `references/phase-guide-planning.md` - Phase 0

---

## Phase 路由

每个 Phase 进入前按指示 READ 对应参考文件。

### Phase 1: 探索 (Strict only)

理解全局上下文：项目扫描、现有模式、影响范围、约束发现。产出体现在提案 Context 部分。

> READ `references/phase-guide-planning.md` - Phase 1

### Phase 1.5: 需求澄清 (Standard+)

对话澄清模糊需求：逐个提问 → 方向速览 → 范围确认。Standard 1-3 个关键问题；Strict 完整流程；需求已明确时可跳过。

> READ `references/phase-guide-planning.md` - Phase 1.5

### Phase 2: 提案 (All modes)

明确动机、范围、影响。Flow: 口头30s。Standard+: 创建 `proposal.md`。

> READ `references/phase-guide-planning.md` - Phase 2 和 `references/artifact-system.md`

### Phase 3: 规范 (Strict only)

Delta 格式精确描述行为变更：ADDED/MODIFIED/REMOVED + RFC 2119 + GIVEN-WHEN-THEN 场景。

> READ `references/phase-guide-planning.md` - Phase 3 和 `references/artifact-system.md`

### Phase 4: 设计 (Standard+)

记录技术决策：现状、方案对比、决策理由、风险缓解。Strict 模式增加多角色并行方案对比（架构师/性能专家/资深开发）。

> READ `references/phase-guide-execution.md` - Phase 4 和 `references/artifact-system.md`

### Phase 5: 任务分解 (Standard+)

设计转化为可执行任务：5-15min 粒度、文件映射、依赖标注、TDD 步骤、验证命令。

> READ `references/phase-guide-execution.md` - Phase 5

### Phase 6: 执行与逐任务审查 (All modes)

TDD 铁律（RED→GREEN→REFACTOR）+ 逐任务审查（自审→spec审→code审）+ 修复闭环（最多3轮）。

> READ `references/phase-guide-execution.md` - Phase 6
> TDD: `references/execution-guide.md` | 审查: `references/review-verify.md` | Flow: `references/flow-mode-guide.md`

### Phase 7: 全局审查 (Standard+)

跨任务一致性：接口对接、架构评估、交叉影响、风格统一。修复闭环最多2轮。

> READ `references/phase-guide-execution.md` - Phase 7 和 `references/review-verify.md`

### Phase 8: 验证 (All modes)

提供可验证证据：运行不声称、完整不抽样、真实不模拟。证据分级 A/B/C。

> READ `references/phase-guide-execution.md` - Phase 8 和 `references/review-verify.md`

### Phase 9: 归档 (Strict only)

保留上下文：合并 Delta 规范到主规范、移动变更目录到 archive。

> READ `references/phase-guide-closing.md` - Phase 9

### Phase 10: 收尾清理 (使用了 Worktree 时)

闭合 Worktree 生命周期。4 选项：合并到主分支 / 推送创建 PR / 保留 / 废弃。

> READ `references/phase-guide-closing.md` - Phase 10

---

## Strict 模式完整性检查

进入 Strict 模式后，必须通过以下检查点：

- ✅ Worktree 隔离 (Phase 0)
- ✅ 探索阶段 (Phase 1)
- ✅ 规范阶段 (Phase 3): Delta 规范已生成
- ✅ 设计阶段 (Phase 4): 技术方案确定
- ✅ 全局审查 (Phase 7): 跨任务一致性
- ✅ 归档阶段 (Phase 9): 上下文归档完成
- ✅ 收尾清理 (Phase 10): Worktree 清理

---

## 快速参考

### 变更目录结构

```
docs/spec-power/changes/<name>-YYYYMMDDHHMMSS/
├── .specpower.yaml    (元数据+状态)
├── proposal.md
├── design.md
├── tasks.md
└── specs/             (Strict only)
```

> 详细变更目录管理、Worktree 隔离、平台适配见 `references/phase-guide-closing.md`
> 工件 DAG、Delta 格式、模板见 `references/artifact-system.md`
> 阶段回退协议见 `references/phase-guide-execution.md`

### 参考资源索引

| 文件 | 内容 |
|------|------|
| `references/phase-guide-planning.md` | Phase 0~3 详细执行步骤 |
| `references/phase-guide-execution.md` | Phase 4~8 详细执行步骤 |
| `references/phase-guide-closing.md` | Phase 9~10 + 变更目录管理 + 平台适配 |
| `references/artifact-system.md` | 工件 DAG、Delta 规范、所有模板 |
| `references/execution-guide.md` | TDD 流程、子agent调度、系统调试 |
| `references/review-verify.md` | 审查方法论、验证清单、问题分级 |
| `references/mindset.md` | 反合理化与验证纪律 |
| `references/flow-mode-guide.md` | Flow 模式完整指南 |

### 子agent提示

| 文件 | 角色 |
|------|------|
| `agents/implementer.md` | 任务实现者 |
| `agents/spec-reviewer.md` | 规范符合审查 |
| `agents/code-reviewer.md` | 代码质量审查 |
| `agents/architect.md` | 架构师视角 (Strict) |
| `agents/perf-expert.md` | 性能专家视角 (Strict) |
| `agents/senior-dev.md` | 资深开发视角 (Strict) |
