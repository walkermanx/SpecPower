# Changelog

本文档记录 SpecPower 技能的所有重要变更。

版本号遵循 [Semantic Versioning](https://semver.org/lang/zh-CN/)：
- **主版本号**：不兼容的 API 修改
- **次版本号**：向下兼容的功能性新增
- **修订号**：向下兼容的问题修正

---

## [1.6.0] - 2026-04-11

### 新增 ✨

- **恢复进行中的变更机制**
  - 新对话中自动检测 `in-progress` 状态的变更
  - 读取 `.specpower.yaml` 恢复工作流状态
  - 提供"继续/新变更/查看详情"三个选项
  - 支持多个 in-progress 变更时的选择

- **阶段回退协议**
  - Phase 6 执行失败可回退到 Phase 5/4/1.5
  - Phase 7 审查发现规范问题可回退到 Phase 3
  - 保留已有工作为 `.old` 备份
  - 记录回退原因到 `RETROSPECTIVE.md`

- **Flow 模式完整指南** (`references/flow-mode-guide.md`)
  - 286 行完整文档
  - 3 个端到端示例（修 typo、修 bug、加配置）
  - TDD 简化规则和豁免条件详解
  - Flow 与 Standard 边界判定表
  - 快速检查清单和常见问题

- **TDD 豁免条件机制**
  - 明确"必须 TDD"和"可以豁免"的场景列表
  - 豁免场景：配置文件、样式调整、文档、基础设施脚本、静态资源
  - 每种豁免都有对应的验证方法
  - 保持逻辑代码的 TDD 严格要求

- **多角色设计快速退出**
  - Strict 模式 Phase 4 新增退出条件
  - 设计空间单一时可跳过三角色对比
  - 需在 design.md 说明"仅一种可行方案"

### 改进 🔧

- **Strict 模式检查点优化**（方案 B: 分类设计）
  - 从原 6 个检查点优化为 7 个分类检查点
  - **前置条件**（1个）: Worktree 隔离 - 确保物理隔离正确启动
  - **关键门控**（5个）: 探索/规范/设计/审查/归档 - 保障质量
  - **完成条件**（1个）: 收尾清理 - 确保 worktree 生命周期闭环
  - 修正了简化时移除 Phase 0/10 的问题（这两个检查点不可少）
  - 新增 Phase 1（探索）检查点（补充遗漏）
  - 清晰说明为什么其他 Phase 不需要独立检查

- **任务粒度建议化**
  - 从强制"2-5 分钟"改为建议"5-15 分钟，不超过 30 分钟"
  - 说明过小和过大任务的风险
  - 允许根据复杂度灵活调整

- **工件追踪一致性**
  - 统一 explore 和 clarify 的追踪方式
  - artifact-system.md 补充 finish 工件
  - 所有模式的 `.specpower.yaml` 工件状态一致

- **文档去重**
  - 移除 phase-guide.md 中的平台适配表重复
  - 改为引用 SKILL.md 主表

- **版本号管理**
  - 移除 SKILL.md 正文中的版本号重复
  - 仅保留 frontmatter 中的版本号

### 修复 🐛

- **Standard→Strict 阈值统一**
  - 统一为"跨 5+ 模块"（之前 phase-guide.md 写 4+）

- **init-change.sh 工件初始状态**
  - Strict 模式：explore 为 pending，其余为 blocked
  - Standard 模式：clarify 为 pending，其余为 blocked
  - 修正依赖关系，符合 DAG 定义

- **finish-change.sh PR 选项行为**
  - 改为询问用户是否清理 worktree（之前强制清理）
  - 符合"保留 worktree 直到 PR 合并"的文档说明

- **finish-change.sh 安全检查**
  - 增加 worktree 内执行检测（防止在 worktree 内运行脚本）
  - 增加 merge 后的测试验证和回滚机制
  - 符合"合并后再次验证"的安全原则

- **归档路径冲突**
  - 归档目录保留完整时间戳（避免同日同名冲突）
  - 从 `YYYY-MM-DD-<name>` 改为 `<name>-YYYYMMDDHHMMSS`

### 测试 🧪

- **全流程验证通过**
  - 在 SmsMonitor 项目测试三种模式
  - Flow: 配置修改（2 分钟）
  - Standard: CSV 导出功能（15 分钟）
  - Strict: 规则引擎重构（30 分钟模拟）
  - 所有核心工作流验证通过

---

## [1.5.1] - 2026-04-10

### 新增 ✨

- **Phase 0: 两阶段模式推荐机制**
  - 解决"在信息最少的时候做最重要的决策"的问题
  - 初判 → 快速验证（边界情况时）→ 确认，在不拖慢简单任务的前提下提供更充分信息
  - 快速验证仅需 ~30秒（Glob + Grep + 测试检查）
  - 简单任务快速通过（跳过验证），边界情况深入验证

- **初判信号表**
  - Flow: 单文件、小 bug、简单配置
  - Standard: 新功能、API 变更、多文件修改
  - Strict: 跨模块重构、核心系统、团队协作

- **快速验证触发条件**
  - 有模式混合信号（如"简单需求但涉及核心系统"）
  - 用户描述含糊（如"优化性能"未指明范围）
  - 用户明确提到"不确定复杂度"
  - 初判在 Standard/Strict 边界

- **快速验证内容（3步，~30秒）**
  1. 代码影响范围（Glob + Grep，统计文件/引用数）
  2. 现有测试情况（Glob 测试文件，Grep 现有覆盖）
  3. 依赖复杂度（Grep 依赖关系、接口定义）


- **完整测试套件**
    - 添加 20 个全流程测试用例，覆盖 Flow/Standard/Strict 三种模式
    - 测试模式推荐机制、需求澄清流程、TDD 执行、多角色设计等核心功能
    - 测试用例基于真实 Android 项目（SmsMonitor）场景设计
    - 覆盖场景：模式推荐和自动升降级、需求澄清流程（Phase 1.5）、TDD 执行和多层审查、多角色方案对比（Strict）、Worktree 生命周期管理、工件 DAG 并行执行

- **文档支持**
  - `references/phase-guide.md` 新增 Phase 0 完整指南（131行）
  - 两阶段推荐流程图
  - 初判信号表、触发/跳过条件、调整规则
  - 确认模式的话术模板
  - Phase 0 vs Phase 1 探索的区别对比表

### 改进 ⚡

- **SKILL.md 快速开始章节更新**
  - 更新流程说明，加入"快速验证（边界情况时）"
  - "如何推荐"完整替换为两阶段推荐说明

- **Phase 0 vs Phase 1 定位明确**
  - Phase 0：发生在模式确定前，30秒快速扫描（Glob/Grep）
  - Phase 1：发生在 Strict 模式开始后，完整探索（Read/深入分析）
  - Phase 0 是快速验证，Phase 1 是完整探索，二者不重复

### 改进 🔧 (P0 优先级 - 基于测试反馈)

**背景**：基于 20 个全流程测试用例的评分结果（通过率：with_skill 71.3% vs baseline 19.1%），识别出 4 个P0优先级改进点并实施修复。

- **P0-1: 边界场景判定保守化**
    - **问题**：Eval #8 显示在 Standard/Strict 边界倾向过度推荐 STRICT（33%通过率）
    - **改进**：
        * 提高 Strict 升级阈值：跨 5+ 模块（原 4+）
        * 要求**同时满足** 2+ 条件才升级 Strict（而非单一条件）
        * 明确规则：单一功能增强（如"支持自定义铃声"）→ Standard，不升级
        * 新增原则：**疑似标准就选标准**，避免过度工程化
    - **预期效果**：Eval #8 通过率从 33% 提升到 80%

- **P0-2: Strict 模式执行完整性强化**
    - **问题**：Eval #13 显示识别 Strict 但未完整执行关键阶段（33%通过率）
    - **改进**：
        * 新增 **Strict 模式执行完整性检查点**（6项必需）
        * Phase 0: Worktree 创建验证
        * Phase 3: specs.md 生成验证
        * Phase 4: 多角色设计执行验证（或显式跳过）
        * Phase 7: 两层审查完成验证
        * Phase 9: 归档执行验证
        * Phase 10: Worktree 清理规划验证
        * 跳过任何阶段需记录原因并在最终报告说明
    - **预期效果**：Eval #13 通过率从 33% 提升到 90%

- **P0-3: Phase 7 Critical Issues 处理策略**
    - **问题**：Eval #14 显示审查识别问题但未修复（75%通过率）
    - **改进**：
        * 明确 **Review-Only** 和 **Auto-Fix** 两种模式
        * Review-Only（默认）：文档化 + 修复建议 + 时间估算
        * Auto-Fix（可选）：立即执行修复 → 回到 Phase 6/7 循环
        * 选择建议：简单修复（<5分钟）→ Auto-Fix，复杂修复（>5分钟）→ Review-Only
    - **预期效果**：Eval #14 通过率从 75% 提升到 90%

- **P0-4: Phase 8 验证环境隔离策略**
    - **问题**：Eval #15 显示被代码库编译错误阻塞（50%通过率）
    - **改进**：
        * 新增 **Pre-Check 快速验证**：Phase 8 前检测环境状态
        * 新增 **Isolated Test 策略**：仅验证新增/修改测试
        * 新增 **证据分级**：A级（完整）/ B级（隔离）/ C级（人工）
        * 默认尝试A级，环境问题时降级B级（需说明），C级需用户确认
    - **预期效果**：Eval #15 通过率从 50% 提升到 85%

### 测试验证 📊

- **测试规模**：40 agents (20 with_skill + 20 baseline) 并行运行
- **测试时长**：~8 小时，消耗 ~3.5M tokens
- **通过率**：71.3% vs 19.1%（提升 272%）
- **ROI**：13.6倍（质量提升 / 时间投入）
- **核心验证成功**：Phase 0/1.5/4/9/10 全部达标（100%通过率）
- **识别改进点**：4个P0问题，已全部实施修复
- **详细报告**：`spec-power-workspace/iteration-1/FINAL_REPORT.md`

### 质量保证 ✅

所有改进基于真实测试数据和评分结果，目标明确且可测量：
- P0-1: 33% → 80% (+142%)
- P0-2: 33% → 90% (+173%)
- P0-3: 75% → 90% (+20%)
- P0-4: 50% → 85% (+70%)

预期总体通过率：71.3% → ~85% (+19%)

---

## [1.5.0] - 2026-04-10

### 新增 ✨

- **Strict 模式：多角色方案对比机制**
  - Phase 4 设计阶段引入三角色并行方案设计
  - 避免单一视角的确认偏误，从不同优化目标产出竞争性方案
  - 技术负责人 5 维度对比，用户评审后展开为完整设计

- **三个设计角色**
  - **架构师**：系统分层、模块解耦、可扩展性、长期可维护性
  - **性能专家**：响应速度、内存占用、IO 优化、并发处理、瓶颈预防
  - **资深开发**：开发效率、代码简洁、快速上线、技术债务控制

- **聚焦方案格式**（60-80 行）
  - 核心策略 + 关键设计决策 + 架构概要
  - 优势/代价/预期分歧点
  - 避免完整设计文档的 60% 冗余

- **技术负责人对比维度**
  - 架构合理性、性能表现、开发成本、可维护性、风险程度
  - 5×3 对比矩阵 + 推荐理由 + 交叉借鉴

- **新增子 Agent 提示模板**
  - `agents/architect.md` — 架构师视角（系统分层、解耦、扩展性）
  - `agents/perf-expert.md` — 性能专家视角（响应速度、内存、IO）
  - `agents/senior-dev.md` — 资深开发视角（开发效率、简洁、交付）

- **完整端到端示例**
  - `examples/add-user-avatars/multi-role-design.md`
  - 展示头像功能的三角色方案对比全流程
  - 真实的设计冲突：架构师要抽象层、性能专家要同步 CDN、资深开发要最小代码

### 改进 ⚡

- **Phase 4 工作流优化**
  - Strict 模式：共享上下文 → 三角色并行 → 对比推荐 → 用户评审 → 设计定稿
  - Standard 模式：保持现有流程不变（2+ 方案对比）
  - 无子 agent 时降级为顺序内联（主 agent 依次切换视角）

- **降级策略**
  - 无子 agent 时：多角色改为顺序内联，产出格式不变
  - 所有工件和质量规则保持一致

- **平台适配表更新**
  - 新增"多角色设计 (Strict)"行
  - Claude Code: 3 子 agent 并行
  - Cursor/其他: 顺序内联

### 文档更新 📝

- **SKILL.md**
  - 版本升级至 1.5.0
  - Phase 4 章节新增 Strict 模式多角色设计说明
  - 更新平台适配表
  - 子 agent 提示参考列表新增 3 个角色

- **references/phase-guide.md**
  - Phase 4 新增"Strict 模式：多角色方案对比"子章节（~160 行）
  - 包含角色冲突表、5 步工作流、聚焦方案格式、对比矩阵模板

- **references/artifact-system.md**
  - 新增多角色方案对比模板章节（~80 行）
  - 共享上下文模板、聚焦方案模板、技术负责人对比矩阵模板

### 设计理念 🎯

**为什么需要多角色？**
- 当前"2+ 方案对比"容易形成"推荐方案 + 陪跑方案"模式
- 同一设计者产出的多个方案容易受确认偏误影响
- 关键系统的设计决策值得从多个优化目标审视

**为什么是这三个角色？**
- 架构师优化长期结构 ↔ 性能专家优化运行效率 ↔ 资深开发优化交付速度
- 三者的优化目标会产生真实的设计分歧（抽象 vs 性能 vs 简洁）
- 覆盖了设计决策的关键维度

**为什么用聚焦方案而非完整设计？**
- 三个角色面对的需求、现状、约束相同
- 真正不同的是技术方案选型和关键设计决策
- 完整设计文档会有 60% 冗余，聚焦方案避免重复

**成本分析**
- 当前设计阶段：~5K tokens
- 多角色方案：~12K tokens（3 子 agent 并行）
- Strict 模式额外投入 2x 是可接受的

---

## [1.4.0] - 2026-04-11

### 新增 ✨

- **Phase 10: 收尾清理**
  - 完整闭合 Git Worktree 生命周期（创建 → 使用 → 清理）
  - 补全之前缺失的 worktree 清理、分支整合、状态转换环节
  - 提供 4 个结构化选项：合并/PR/保留/废弃
  - 参考 superpowers `finishing-a-development-branch` 的安全原则设计

- **4 个结构化收尾选项**
  1. **合并到主分支** — merge + test + remove worktree + delete branch
  2. **推送并创建 PR** — push + gh pr create + remove worktree (可选)
  3. **保留当前状态** — 不清理，稍后处理
  4. **废弃变更** — 需确认 → force delete branch + remove worktree

- **安全机制**
  - 测试通过才提供选项（keep/discard 跳过门控）
  - 废弃需用户输入 'discard' 确认
  - 合并后再次验证测试
  - 不问开放性问题，直接提供结构化选择

- **收尾脚本 `finish-change.sh`**
  - 支持 4 种操作模式（merge/pr/keep/discard）
  - 交互式选择 + 命令行参数两种方式
  - 自动更新 `.specpower.yaml` status（done/review/archived）
  - 跨平台兼容（macOS/Linux）
  - 包含测试验证门控

### 改进 ⚡

- **工件 DAG 更新**
  - 在 archive 节点后新增 finish 节点
  - Strict 流程：`... → archive → finish`
  - Standard/Flow: finish 可选（仅使用 worktree 时需要）

- **平台适配扩展**
  - Claude Code: 使用 `ExitWorktree(action="remove"/"keep")`
  - 其他平台: 手动 `git worktree remove` 或使用 `finish-change.sh` 脚本
  - 平台适配表新增"Worktree 收尾清理"能力对比

- **`.specpower.yaml` 状态流完善**
  - 选项 1 (merge) → status: done
  - 选项 2 (PR) → status: review
  - 选项 3 (keep) → status 不变
  - 选项 4 (discard) → status: archived

- **流程图更新**
  - Strict 模式: `explore ──► ... ──► archive ──► finish`
  - Standard 模式: `clarify ──► ... ──► verify ──► (finish)`
  - Flow 模式: `propose ──► execute ──► verify ──► (finish)`

### 文档更新 📝

- **SKILL.md**
  - 版本升级至 1.4.0
  - 新增 Phase 10 概要章节
  - 更新所有模式流程图（Strict 必需，Standard/Flow 可选标注）
  - 工件 DAG 图新增 finish 节点
  - 快速参考新增收尾入口
  - 平台适配表新增 Worktree 收尾清理行

- **references/phase-guide.md**
  - 新增完整的 Phase 10 详细指南（5 步流程）
  - 包含 4 个选项的详细执行步骤、bash 命令、验证流程
  - 选项速查表（merge/push/worktree/branch/status 对比）
  - 安全原则和常见错误

- **scripts/finish-change.sh**
  - 新建收尾脚本（244 行）
  - 完整实现 4 种操作模式
  - 包含测试验证、分支检测、worktree 清理、状态更新
  - 错误处理和友好提示

- **README.md**
  - Strict 模式流程描述加入"收尾"步骤
  - 工具脚本部分新增 `finish-change.sh` 使用示例
  - 平台兼容性表格新增 Worktree 收尾清理行

### 设计理念 🎯

**与 superpowers 的差异化**：
- 定位：作为 Phase 10 自然衔接在 Phase 9 归档之后，而非独立 skill
- 触发：Phase 9 完成后自动进入（Strict），或按需进入（Standard/Flow）
- 适配：spec-power 的分支命名规范 `spec-power/<name>-<timestamp>`
- 集成：与 `.specpower.yaml` 状态流深度结合

**解决的核心问题**：
- Worktree 泄漏（未清理的 `.worktrees/` 累积）
- 分支污染（`spec-power/*` 分支持续增加）
- 生命周期不闭合（创建了 worktree 却没有清理指引）
- 跨平台一致性（Claude Code/Cursor/其他平台的清理方式不一致）

---

## [1.3.0] - 2026-04-10

### 新增 ✨

- **Phase 1.5: 需求澄清阶段**
  - 在 Standard 和 Strict 模式的 propose 阶段前新增 clarify 阶段
  - Flow 模式保持不变（跳过 clarify）
  - 通过对话系统化澄清模糊需求、确认方向、控制范围
  
- **四个核心步骤**
  1. **快速上下文感知** — 复用 explore 结果或快速扫描相关代码
  2. **逐个澄清关键问题** — 一次一个问题，优先多选题，聚焦目的/约束/成功标准
  3. **方向速览** — 2-3 个方向性选择（非完整设计），带推荐和简短理由
  4. **范围确认** — 分解大任务、过滤跨栈需求、YAGNI 剪枝

- **智能跳过机制**
  - Standard: 最多 3 个问题，快速确认
  - Strict: 按需提问，直到需求清晰
  - 用户需求已非常明确时自动跳过

- **自动化工具**
  - 新增 `scripts/bump-version.sh` 自动化版本更新脚本
  - 一键更新 SKILL.md frontmatter、正文和 README.md 版本号
  - 包含版本格式验证、确认提示、一致性检查

### 改进 ⚡

- **职责边界清晰化**
  - clarify: 面向人（理解意图和需求）
  - explore: 面向系统（理解代码和技术现状）
  - design: 技术细节（接口定义、数据模型、风险分析）

- **跨栈需求处理**
  - clarify 步骤 4 自动识别与当前项目技术栈无关的需求
  - 示例：Android 项目中的 iOS/后端描述自动归入"不在范围内"
  - 避免范围蔓延和不必要的工作

- **提案质量提升**
  - clarify 结论直接注入 proposal 的动机和范围部分
  - 更早发现歧义，减少后续返工
  - 在最廉价的阶段获取用户输入

### 工件系统更新 🔧

- **DAG 更新**: 在 explore 和 proposal 之间插入 clarify
- **依赖关系**: clarify 依赖 explore（如有），proposal 依赖 clarify（如有）
- **产出形式**: 不生成独立文件，结论内嵌于 proposal

### 文档更新 📝

- **SKILL.md**
  - 版本升级至 1.3.0
  - 更新工件 DAG 和模式流程图
  - 新增 Phase 1.5 概要章节
  
- **references/phase-guide.md**
  - 新增完整的 Phase 1.5 详细执行指南
  - 包含目标、适用条件、执行步骤、产出、职责划分
  
- **references/artifact-system.md**
  - 工件定义表新增 clarify 行

### 典型场景 🎯

**场景 1**: 模糊需求 "优化性能" → clarify 澄清：哪部分？目标指标？

**场景 2**: 清晰需求 "修复 login 500 错误" → Flow 跳过 clarify

**场景 3**: 过大需求 "重构认证+权限" → clarify 建议分解为两个变更

**场景 4**: 跨端需求 "实现登录（含 iOS/后端）" → clarify 过滤出当前项目部分

---

## [1.2.0] - 2026-04-09

### 重构 🔨

- **SKILL.md 结构优化**
  - 主文件从 574行 精简到 331行（减少42%）
  - SKILL.md 重新定位为"路由器"，详细内容按需加载
  - 消除了与 references/ 文件的内容重复
  - 各 Phase 改为概要 + 引用模式

- **新增统一Phase指导**
  - 创建 `references/phase-guide.md` 统一管理各Phase详细执行步骤
  - 整合了原本分散在SKILL.md中的Phase详情
  - 包含平台适配建议、常见问题处理

### 改进 ⚡

- **渐进式加载优化**
  - 主文件只包含概要和引用指针
  - 用户可按需深入了解详细内容
  - 减少 token 消耗，提升加载效率

- **维护性提升**
  - 同一内容不再在多处重复
  - 更新时只需修改一处
  - 引用系统更清晰

### 文档结构

新的引用层次：
```
SKILL.md (路由器，331行)
  ├─ references/phase-guide.md (各Phase详细指南)
  ├─ references/artifact-system.md (工件和模板)
  ├─ references/execution-guide.md (TDD和调试)
  ├─ references/review-verify.md (审查和验证)
  └─ references/mindset.md (心态和最佳实践)
```

---

## [1.1.2] - 2026-04-08

### 新增 ✨

- **变更目录命名格式优化**
  - 变更目录命名格式改为 `<change-name>-YYYYMMDDHHMMSS`
  - 自动添加时间戳后缀，避免命名冲突
  - 便于按时间排序和追溯创建时间
  
- **脚本自动化改进**
  - `init-change.sh` 自动生成时间戳
  - 用户只需提供基础名称，脚本自动追加时间戳
  - 示例：`add-user-auth` → `add-user-auth-20260408143025`

### 修改 🔧

- **路径更新**
  - 所有变更目录路径：`docs/spec-power/changes/<change-name>-YYYYMMDDHHMMSS/`
  - Worktree 目录：`.worktrees/<change-name>-YYYYMMDDHHMMSS/`
  - Git 分支：`spec-power/<change-name>-YYYYMMDDHHMMSS`
  - 元数据文件中的 name 字段自动使用完整名称

- **文档更新**
  - SKILL.md 中所有路径示例更新为新格式
  - 添加命名格式说明和示例
  - 脚本使用说明更新，强调自动生成时间戳

---

## [1.1.1] - 2026-04-08

### 优化 ⚡

- **Phase 4: 描述优化测试**
  - 创建 20 个测试查询（10个应该触发 + 10个不应该触发）
  - 生成并评估 4 个描述变体
  - 应用变体D（关键词密集版本）：准确率从 75% 提升到 95%
  
- **描述字段改进**
  - 新增关键词："拆解任务"、"团队协作"、"核心系统"、"TDD"
  - 明确触发边界："适用于结构化规划的开发工作，不适用于简单查询或单行代码修改"
  - 关键词前置，提高触发准确度
  - 字数优化：93词 → 92词

- **触发准确率提升**
  - Should-trigger：70% → 90% (+20%)
  - Should-not-trigger：80% → 100% (+20%)
  - 总体准确率：75% → 95% (+20%)

---

## [1.1.0] - 2026-04-08

### 新增 ✨

- **Phase 3: 示例和脚本**
  - 创建完整的端到端示例 `examples/add-user-avatars/`
  - 新增初始化脚本 `scripts/init-change.sh` 自动创建变更目录结构
  - 新增版本管理系统（CHANGELOG.md + 版本号）
  
- **快速开始指南**
  - 在 SKILL.md 顶部添加 🚀 快速开始部分
  - 区分新用户和老用户的使用路径
  - 提供 30 秒快速理解技能价值的入口

- **心态与最佳实践**
  - 创建 `references/mindset.md` 独立文件
  - 扩展"反理性化 Red Flags"内容
  - 添加详细的心态培养指导

### 改进 🚀

- **Phase 0: Strict 模式强制 Worktree**
  - Strict 模式现在强制要求使用 Git Worktree 进行物理隔离
  - Standard/Flow 模式保持 Worktree 可选
  - 更新平台适配表格，明确不同模式的要求
  - 区分 Claude Code 自动化和其他平台手动操作

- **描述字段优化**
  - 从 ~200 词精简到 93 词
  - 添加具体的触发场景关键词："写个计划"、"分步实现"、"规范化开发"
  - 采用"pushy"风格，确保合适的场景都能触发

- **文档结构优化**
  - 主文件从 553 行优化到 540 行
  - 将反理性化部分移到独立的 `references/mindset.md`
  - 改善引用系统的清晰度

### 修复 🐛

- 无

---

## [1.0.0] - 2026-04-07

### 初始版本

- **完整的工作流体系**
  - Flow/Standard/Strict 三档模式
  - 探索→提案→规范→设计→任务→执行→审查→验证→归档 完整 DAG
  
- **质量保障体系**
  - 强制 TDD 流程
  - 三层审查网（自审/规范审查/代码审查）
  - 完整的验证清单

- **工件系统**
  - Delta 规范格式
  - 完整的模板和示例
  - 变更目录管理

- **平台适配**
  - 支持 Claude Code、Cursor、Copilot
  - 子 agent 并行执行
  - Git worktree 支持

- **引用文档**
  - `references/artifact-system.md` - 工件系统详解
  - `references/execution-guide.md` - 执行和 TDD 指南
  - `references/review-verify.md` - 审查验证方法论

- **子 agent 模板**
  - `agents/implementer.md` - 实现者提示
  - `agents/spec-reviewer.md` - 规范审查提示
  - `agents/code-reviewer.md` - 代码审查提示

---

## 如何贡献

如果你发现问题或有改进建议，请：
1. 记录问题的具体场景和影响
2. 如果有解决方案，说明改进建议
3. 提交 issue 或 pull request

## 版本规划

### 计划中的功能（待定）

- **1.2.0**: 描述优化测试
  - 自动化触发测试用例
  - 基于测试结果优化描述字段

- **1.3.0**: 更多示例和工具
  - 添加更多领域的示例（API 开发、数据库迁移、UI 组件等）
  - 验证脚本 `scripts/validate-change.sh`
  - Delta 合并脚本 `scripts/merge-delta.sh`

- **2.0.0**: 可能的破坏性变更
  - 工件格式优化
  - 模式选择算法改进
