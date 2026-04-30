# SpecPower

> **规范驱动的超能力开发工作流** — 让复杂开发变得可控、可追溯、高质量

[![Version](https://img.shields.io/badge/version-1.11.0-blue.svg)](CHANGELOG.md)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

**SpecPower** 是一套完整的软件开发方法论,融合结构化规划能力和执行纪律,通过**规划深度匹配任务复杂度**、**质量门控保障关键节点**、**灵活迭代而非瀑布僵化**三大原则,帮助开发者高效完成从简单修复到复杂重构的各类任务。

---

## ✨ 核心特性

- 🎯 **两阶段智能推荐** — 初判 → 快速验证（边界情况）→ 确认，避免"信息最少时做最重要决策"
- 🔄 **恢复进行中变更** — 新对话自动检测 in-progress 变更，无缝继续工作
- ↩️ **阶段回退协议** — 发现问题时可回退到前置阶段，保留已有工作
- 💬 **需求澄清机制** — Standard+ 模式自动澄清模糊需求、确认方向、控制范围
- 🧪 **灵活的测试驱动** — TDD 核心流程 + 合理豁免（配置/样式/文档）
- 📘 **Flow 模式完整指南** — 轻量任务专属文档，3 个端到端示例
- 🔍 **多层质量审查** — 自审 + 代码审查 + 规范审查，层层把关
- 📝 **禁止静默跳过**（v1.10.0）— 审查跳过必须显式声明原因，任务完成声明作为审计留痕
- 🗂️ **产物化审查**（v1.11.0 ⭐）— 每次审查(含跳过)必须落盘到 `reviews/`,`verify-task-reviews.sh` 校验产物齐全性,commit 前硬强制
- 🪶 **Flow 模式超轻量**（v1.11.0 ⭐）— Flow 不再创建变更目录/审查文件,只要口头提案 + TDD + commit,避免纪律过重被用户绕开
- 📑 **SKILL.md 规则分层瘦身**（v1.11.0 ⭐）— 主文件从 321 行压至 163 行,跳过规则/声明模板/违规处置下沉到按需加载的 references
- 🚀 **子 Agent 并行执行** — 独立任务并行处理，大幅提升效率
- 📋 **完整工件追溯** — 从提案到归档，每个决策都有据可查
- 🔒 **Git Worktree 隔离** — 关键变更物理隔离，保障主分支稳定
- 📐 **Delta 规范格式** — 增量式行为描述，多变更无冲突

---

## 🚀 快速开始

### 前置要求

- Git 2.25+
- 支持的 AI 编码助手:
  - **Claude Code** (推荐,支持所有特性)
  - Cursor (支持核心工作流,需手动 worktree)
  - GitHub Copilot / 其他 (支持基础流程)

### 安装

**方法 1: 使用安装脚本（推荐）**

```bash
# 克隆仓库
git clone https://github.com/walkermanx/SpecPower.git
cd SpecPower

# 运行安装脚本
./scripts/link-skill.sh

# 脚本会自动:
# - 检测包含 SKILL.md 的 Skill 目录
# - 列出可用的安装目标（项目级/用户级）
# - 通过软链接安装到选定位置
```

**方法 2: 手动安装**

```bash
# 下载或克隆仓库
git clone https://github.com/walkermanx/SpecPower.git

# 复制到对应平台的 skills 目录
# 用户级安装（所有项目可用）
cp -r SpecPower ~/.claude/skills/spec-power

# 或项目级安装（仅当前项目）
cp -r SpecPower /path/to/your-project/.claude/skills/spec-power
```

**支持的平台**:
- **Claude Code**: `~/.claude/skills/` (用户级) 或 `.claude/skills/` (项目级)
- **Cursor**: `~/.cursor/skills/` (用户级) 或 `.cursor/skills/` (项目级)
- **MiCode**: `~/.micode/skills/` (用户级) 或 `.micode/skills/` (项目级)
- **OpenCode**: `~/.config/opencode/skills/` (用户级) 或 `.opencode/skills/` (项目级)

安装后，在对话中使用 `/spec-power` 即可调用。

### 首次使用

告诉你的 AI 助手:

```
我想使用 SpecPower 开发一个新功能:添加用户头像上传
```

助手会自动:
1. ✅ 初判任务复杂度（基于描述关键信号）
2. ✅ 边界情况时快速验证（30秒代码扫描）
3. ✅ 推荐合适的模式（Flow/Standard/Strict）
4. ✅ 引导你完成各阶段工作
5. ✅ 自动应用 TDD + 质量审查

---

## 📖 使用指南

### 模式推荐机制

SpecPower 采用**两阶段推荐**，避免在信息不足时过早决策：

1. **初判** — 基于用户描述的关键信号快速分类
2. **快速验证** — 边界情况时进行30秒代码扫描（Glob/Grep）
3. **确认** — 说明最终推荐模式并解释调整原因

**简单任务快速通过，边界情况深入验证，不拖慢工作流程。**

---

### 三档工作模式

#### 🏃 Flow 模式 (快速迭代)

**适用场景**: 单文件修改、小 bug 修复、简单配置

**流程**: 口头提案 → TDD 执行 → 验证

**特点（v1.11.0 ⭐）**: 真正超轻量——**不创建** 变更目录、**不产出** `.specpower.yaml`、**不产出** `reviews/` 审查文件、**不输出** 结构化完成声明。只要 "一句话说清改什么" + TDD + `git commit`。

**示例任务**:
- 修复按钮点击事件的 typo
- 调整 CSS 样式
- 更新配置文件中的 API 地址

**时间**: 5-15 分钟

---

#### 🔨 Standard 模式 (日常开发)

**适用场景**: 新功能开发、API 变更、多文件修改

**流程**: 需求澄清 → 提案 → 设计 → 任务分解 → 执行 → 审查 → 验证

**示例任务**:
- 添加用户头像上传功能
- 重构数据库查询接口
- 实现搜索过滤器

**时间**: 1-4 小时

**✨ 新增**: 自动澄清模糊需求、确认技术方向、过滤无关内容

---

#### 🏗️ Strict 模式 (关键系统)

**适用场景**: 跨模块重构、核心系统、团队协作

**流程**: 探索 → 需求澄清 → 提案 → 规范 → 设计 → 任务 → 执行 → 审查 → 验证 → 归档 → 收尾

**示例任务**:
- 重构认证系统
- 数据库迁移方案
- 支付模块集成

**时间**: 1-3 天

**⚠️ 要求**: 必须使用 Git Worktree 隔离

**✨ 新增**: 完整需求澄清流程、自动分解过大任务、多角色方案对比（Phase 4）

---

### 典型工作流程

#### Standard 模式完整示例

```bash
# 1. 告诉 AI 助手
"使用 Standard 模式开发用户头像上传功能"

# 助手会自动:
# ✅ 创建 proposal.md (提案)
# ✅ 创建 design.md (技术设计)
# ✅ 创建 tasks.md (任务分解)
# ✅ 使用 TDD 执行每个任务
# ✅ 运行代码质量审查
# ✅ 执行完整验证

# 3. 查看变更文件
tree docs/spec-power/changes/add-user-avatars-20260409143025/
# ├── .specpower.yaml
# ├── proposal.md
# ├── design.md
# ├── tasks.md
# └── verification.md
```

---

## 📁 项目结构

```
your-project/
├── docs/spec-power/
│   ├── changes/              # 进行中的变更
│   │   └── <name>-<timestamp>/
│   │       ├── .specpower.yaml
│   │       ├── proposal.md
│   │       ├── design.md
│   │       ├── tasks.md
│   │       └── specs/        # Strict 模式专用
│   │
│   ├── specs/                # 主规范(Strict 模式合并目标)
│   │   └── <domain>/
│   │       └── spec.md
│   │
│   └── archive/              # 已完成变更归档
│       └── <name>-<timestamp>/
│
├── .worktrees/               # Git Worktree 隔离目录
│   └── <change-name>-<timestamp>/
│
└── SKILL.md                  # SpecPower 技能定义
```

---

## 🎯 核心概念

### TDD 铁律

SpecPower 强制执行测试驱动开发:

```
1. RED     → 写测试,运行,确认失败
2. 验证RED  → 失败原因是"功能未实现"
3. GREEN   → 写最小代码使测试通过
4. 验证GREEN → 运行所有测试,确认全部通过
5. REFACTOR → 改善代码,保持测试绿色
```

**铁律**: 不允许在没有失败测试的情况下写生产代码。

### 三层质量审查（逐任务内嵌）

每完成一个任务立即通过审查门控,问题在传染到下游前被捕获:

1. **自我审查** (30秒,所有模式) — 代码完整性、测试覆盖、安全基线
2. **规范符合审查** (Strict,子agent) — 对比 specs/ 检查覆盖和正确性
3. **代码质量审查** (Standard+,子agent) — 架构、风格、错误处理、性能

审查发现问题 → 修复 → 重审（最多3轮闭环,超过升级用户）

### Git Worktree 隔离

**为什么需要隔离?**
- 关键变更不影响主分支
- 多个变更可并行进行
- 测试失败时主分支可继续工作

**Strict 模式必需,Standard/Flow 可选**

---

## 📚 文档与工具

### 核心文档

- **[SKILL.md](SKILL.md)** — 完整方法论与工作流程
- **[CHANGELOG.md](CHANGELOG.md)** — 版本更新日志

### 参考资料

- **[references/phase-guide-planning.md](references/phase-guide-planning.md)** — 规划阶段 (Phase 0~3)
- **[references/phase-guide-execution.md](references/phase-guide-execution.md)** — 执行阶段 (Phase 4~8)
- **[references/phase-guide-closing.md](references/phase-guide-closing.md)** — 收尾阶段 (Phase 9~10)
- **[references/flow-mode-guide.md](references/flow-mode-guide.md)** — Flow 模式完整指南与示例
- **[references/artifact-system.md](references/artifact-system.md)** — 工件类型、DAG 模型、`.specpower.yaml` 格式
- **[references/templates.md](references/templates.md)** — proposal / design / 多角色 / tasks / behavior-changes 模板
- **[references/artifact-delta-specs.md](references/artifact-delta-specs.md)** — Delta 规范 + RFC 2119 + 棕地基线(Strict 专用)
- **[references/execution-guide.md](references/execution-guide.md)** — TDD 详细流程、子 agent 调度
- **[references/review-verify.md](references/review-verify.md)** — 审查方法论、验证清单
- **[references/review-artifact-protocol.md](references/review-artifact-protocol.md)** ⭐ v1.11.0 — 产物化审查协议 (目录结构 / 文件格式 / commit trailer)
- **[references/skip-policy.md](references/skip-policy.md)** ⭐ v1.11.0 — 跳过规则与有效/无效理由规范
- **[references/task-declaration.md](references/task-declaration.md)** ⭐ v1.11.0 — 任务完成声明模板 (精简版 + v1.10 兼容)
- **[references/discipline-recovery.md](references/discipline-recovery.md)** ⭐ v1.11.0 — 违规处置流程 + 规则退役机制
- **[references/mindset.md](references/mindset.md)** — 反理性化、验证纪律与最佳实践

### 子 Agent 提示

- **[agents/implementer.md](agents/implementer.md)** — 任务实现者提示模板
- **[agents/spec-reviewer.md](agents/spec-reviewer.md)** — 规范审查提示模板
- **[agents/code-reviewer.md](agents/code-reviewer.md)** — 代码审查提示模板
- **[agents/architect.md](agents/architect.md)** — 架构师视角设计（Strict）
- **[agents/perf-expert.md](agents/perf-expert.md)** — 性能专家视角设计（Strict）
- **[agents/senior-dev.md](agents/senior-dev.md)** — 资深开发视角设计（Strict）

### 示例

- **[examples/add-user-avatars/](examples/add-user-avatars/)** — 完整 Standard 模式端到端示例
- **[examples/add-user-avatars/multi-role-design.md](examples/add-user-avatars/multi-role-design.md)** — Strict 模式多角色方案对比示例

---

## 💡 最佳实践

### ✅ 推荐做法

- **让 AI 推荐模式** — 描述任务,由助手分析复杂度
- **关键系统用 Strict** — 核心逻辑、多人协作、需长期维护的代码
- **并行执行独立任务** — 充分利用子 agent 能力(Claude Code)
- **保留完整工件** — 不要删除提案、设计等文档,它们是决策依据
- **定期归档** — Strict 模式完成后及时归档到 `archive/`

### ❌ 避免做法

- **跳过测试** — 无论多简单的任务都要 TDD
- **提前优化** — 先让测试通过,再考虑优化
- **占位符提案** — 不允许"TBD"、"待定"等占位符
- **盲目跟随审查** — 对审查意见做技术评估,有误要说明
- **忽略验证** — 声称完成前必须有证据
- **静默跳过审查** — Standard+ 模式下跳过任一审查步骤必须显式声明理由（含 diff 行数 + 强制例外检查），沉默视为违规

---

## 🔧 平台兼容性

| 能力 | Claude Code | Cursor | Copilot/其他 |
|------|------------|--------|-------------|
| 三档模式 | ✅ | ✅ | ✅ |
| TDD 流程 | ✅ | ✅ | ✅ |
| 子 agent 并行 | ✅ | ❌ | ❌ |
| 多角色设计 (Strict) | ✅(3子agent并行) | ✅(顺序内联) | ✅(顺序内联) |
| 自动 worktree | ✅ | ❌(需手动) | ❌(需手动) |
| Worktree 收尾清理 | ✅(ExitWorktree) | ✅(手动/脚本) | ✅(手动/脚本) |
| 三层审查 | ✅(子agent) | ✅(内联) | ✅(内联) |

**无子 agent 时的降级策略**:
- 审查改为自我审查(用清单)
- 并行执行改为顺序执行
- 所有工件和质量规则不变

---

## 🤝 贡献

欢迎贡献改进建议!

1. Fork 项目
2. 创建特性分支 (`git checkout -b feature/amazing-improvement`)
3. 提交变更 (`git commit -m 'Add amazing improvement'`)
4. 推送到分支 (`git push origin feature/amazing-improvement`)
5. 创建 Pull Request

---

## 📄 许可证

MIT License - 详见 [LICENSE](LICENSE) 文件

---

## 🆘 常见问题

### Q: 简单任务也要走完整流程吗?

A: 不需要。Flow 模式专为简单任务设计,只需提案→执行→验证,无需设计文档。

### Q: 可以跳过 TDD 吗?

A: **逻辑代码不可以**——任何含 if/else、循环、数据处理、API 修改的代码必须先写测试。纯配置文件、纯样式调整、文档修改可以豁免 TDD,但必须有替代验证方式（运行系统确认配置生效、视觉检查等）。豁免不等于不验证。

### Q: Standard 和 Strict 有什么区别?

A: 主要区别:
- Standard: 无需规范文档,适合日常功能开发
- Strict: 需要 Delta 规范 + 强制 worktree 隔离,适合关键系统和团队协作

### Q: 为什么需要时间戳后缀?

A: 避免命名冲突,自动记录创建时间,多变更可并行进行。

### Q: 可以中途切换模式吗?

A: 可以升级(Flow→Standard→Strict),不建议降级。升级时补充缺失的工件即可。

### Q: 不用 Claude Code 可以吗?

A: 可以。Cursor、Copilot 等工具都支持核心工作流,只是需要手动管理 worktree,审查改为内联模式。

### Q: 如何处理审查意见?

A: 对每个意见做技术评估:
- Critical: 必须修复
- Important: 应该修复,除非有充分理由
- Suggestion: 记录但不阻塞,由你决定

如果审查意见有误,说明为什么,不要盲目同意。

---

## 📞 支持

- **文档**: [SKILL.md](SKILL.md)
- **问题反馈**: [GitHub Issues](https://github.com/walkermanx/SpecPower/issues)
- **个人邮箱**: [weizizhang51@gmail.com](mailto:weizizhang51@gmail.com)
- **Telegram**: [t.me/walkermanx](https://t.me/walkermanx)

---

<p align="center">
  <strong>SpecPower</strong> — 让复杂开发变得简单、可控、高质量
  <br>
  <sub>Built with ❤️ by developers, for developers</sub>
</p>
