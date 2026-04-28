# Changelog

本文档记录 SpecPower 技能的所有重要变更。

版本号遵循 [Semantic Versioning](https://semver.org/lang/zh-CN/)：
- **主版本号**：不兼容的 API 修改
- **次版本号**：向下兼容的功能性新增
- **修订号**：向下兼容的问题修正

---

## [1.9.0] - 2026-04-28

### 重构 🔨

- **artifact-system 按渐进披露分层拆分**
  - 原 505 行 `artifact-system.md` 拆分为三个独立文件，按用户所在 Phase 按需路由
  - `artifact-system.md`（105 行）：保留 DAG、状态机、`.specpower.yaml` 格式，作为结构总览
  - `templates.md`（新，277 行）：集中 proposal / design / 多角色 / tasks / behavior-changes 五个模板
  - `artifact-delta-specs.md`（新，171 行）：Delta 格式 + RFC 2119 + 场景编写 + Delta 合并 + 棕地基线规范，Strict 专用
  - 同步更新 SKILL.md、phase-guide-planning/execution 共 5 处模板引用指向

- **验证纪律统一 review-verify 为单一权威源**
  - 将 5 步验证门函数、反合理化借口对照、Red Flags 触发词等操作性细节从 `mindset.md` 迁入 `review-verify.md`
  - `review-verify.md` 声明为验证纪律单一权威源（293→370 行）
  - `mindset.md` 压缩为心态铁律 + 引用指向（272→199 行，内容守恒无信息丢失）
  - `phase-guide-execution.md` Phase 6 验证纪律指引改指 `review-verify`

- **Strict 三视角强制差异化输出维度**
  - 原 architect / perf-expert / senior-dev 三个 agent 的"架构概要"章节输出格式完全同构，方案对比易流于形式
  - `architect.md`：新增模块依赖图（ASCII）+ 关键边界接口签名（≥3 个）必填清单
  - `perf-expert.md`：新增热路径 vs 冷路径标注（带 QPS 估算）+ 关键操作延迟预估（p50/p95/p99）必填清单
  - `senior-dev.md`：新增项目内复用清单（≥3 条，按"对象 → 用途"格式）+ 新增 vs 修改代码比例估算必填清单

- **SKILL.md description 瘦身聚焦触发场景**
  - 原 description 含 12 个触发关键词及大量实现细节，违反冷启动 30s 判断原则
  - 缩减至约 180 字，聚焦 7 个核心使用场景，明确正负边界
  - 加入"避免大改动无计划翻车"的 why 句提升触发吸引力，具体机制下沉至 SKILL.md 正文

### 修复 🐛

- **审查阈值建立单一权威源**
  - `phase-guide-execution.md` Phase 6 新增"子 agent 审查触发阈值（权威表）"
  - `spec-reviewer.md` 与 `code-reviewer.md` 改为指向此表，不再独立维护数字
  - 消除此前 spec ≥100 vs code ≥10/20/100 数字不一致，以及"Strict 逐任务"与"Strict ≥10 行"的潜在矛盾

- **implementer 与 execution-guide 在 TDD/状态码上去冲突**
  - `implementer.md` 原写"TDD 是铁律，不允许例外"，与 `execution-guide.md` 豁免场景直接冲突
  - 改为逻辑变更遵循 TDD、其他场景按 execution-guide 豁免表执行，并附"为什么不是铁律"的理由
  - 状态码说明改为指向 execution-guide"子 agent 状态处理"权威表，不再在 agent prompt 中独立维护语义

- **强制逐任务 git 提交 + Phase 9 归档持久化**
  - Phase 6 新增提交门控：控制器在全部审查通过后执行 commit，按模式区分提交时机
  - 任务模板 commit 步骤改为控制器职责，防止 implementer 子 agent 自行提交
  - Git 提交规范升级为与 TDD 同等级别的铁律
  - Phase 9 归档新增强制 commit，防止 worktree 清理时丢失 untracked 归档文件

- **Claude Code worktree 创建改用先建后进两步法**
  - `EnterWorktree(name=...)` 不支持指定 base_branch，改为先 `git worktree add` 显式指定基准，再 `EnterWorktree(path=...)` 进入
  - 兼顾基准精确性和会话状态管理，避免分支基于错误 commit

- **根据自动化测试报告进行流程优化**

---

## [1.8.2] - 2026-04-27

### 新增 ✨

- **棕地项目按需局部基线规范生成**
  - Strict 模式 Phase 1 新增棕地基线检测步骤（Step 5）
  - 当已有代码库首次使用时，逐模块判断是否涉及 MODIFIED/REMOVED
  - 仅为需要的模块按需生成局部基线规范（`docs/spec-power/specs/<domain>/spec.md`）
  - 基线使用标准 Requirement + Scenario 格式，带 `type: baseline` frontmatter 标注
  - 解决 Delta Spec 缺少行为基线导致 MODIFIED/REMOVED 的"之前"描述无参照的问题

- **规范审查增强棕地基线验证**
  - spec-reviewer agent 新增"基线规范"输入节和 "MODIFIED/REMOVED 基线验证"检查项
  - 校验 MODIFIED/REMOVED 的"之前"描述是否与基线/主规范一致

- **Phase 3 棕地来源优先级提示**
  - MODIFIED/REMOVED 的 "(之前: ...)" 内容来源优先级：主规范 > Phase 1 局部基线 > 代码推断（需标注）
  - Delta 规范自检清单新增棕地场景检查项

- **归档阶段棕地首次合并支持**
  - Phase 9 归档新增主规范不存在时的处理逻辑（有基线以基线为起点、无基线全 ADDED 直接创建）
  - 合并完成后自动移除基线 frontmatter 元信息

### 修复 🐛

- **Worktree 基准分支确认与验证机制**
  - Worktree 创建步骤从 closing.md 参考章节迁移至 planning.md，作为独立的 Phase 路由入口
  - 新增 Step 1 基准分支确认（向用户确认当前 HEAD 是否为期望分支）
  - 新增 Step 4 创建后验证（对比 commit hash 确保分支基准正确）
  - 添加关键约束：确认分支后到调用 EnterWorktree 之间禁止改变 HEAD 的 git 命令
  - 修正 SKILL.md 检查清单标注从 "Phase 0" 改为 "模式确认后"

---

## [1.8.1] - 2026-04-21

### 新增 ✨

- **审查阈值模式差异化**
  - 审查阈值按模式区分：Strict >= 10行 / Standard >= 20行 / Flow >= 100行
  - Strict 模式更保守，体现高风险任务的审查要求
  
- **强制审查例外清单扩展**
  - 新增 SQL/数据库查询（查询构造、schema 变更、迁移脚本）
  - 新增正则表达式修改（ReDoS 风险，尤其用户输入场景）
  - 新增并发/锁相关（mutex、semaphore、atomic、race condition）
  - 新增金额/货币计算（浮点运算、精度、舍入）
  - 新增错误处理路径删除（移除 catch、移除校验逻辑）

### 改进 ⚡

- **Phase 7 小变更补位审查**
  - 新增职责：回顾所有因低于阈值而跳过子agent审查的变更
  - 验证跳过审查的变更中是否存在遗漏的强制例外情况
  - 补偿累积的审查遗漏风险
  
- **实现者 agent 执行约束强化**
  - 新增手术式改动原则：约束每行 diff 可溯源到任务定义
  - 新增孤儿清理规则：区分自己造成的废弃代码 vs 已有死代码
  - 修正"改进你接触的代码"矛盾措辞，明确"不顺手改进"约束
  - 防止 LLM "顺手优化"导致的范围蔓延

### 修复 🐛

- **版本号一致性**
  - 统一所有文档中的版本号为 1.8.1
  - 更新 SKILL.md frontmatter、CHANGELOG.md 和 README.md

---

## [1.8.0] - 2026-04-20

### 新增 ✨

- **轻量注入原则**
  - 子agent上下文注入添加 token 预算控制（实现者<3000/审查者<2000/设计者<4000）
  - 上下文注入模板细化为4层，每层标注 token 目标
  - 所有 agents/*.md 添加注入量目标和触发阈值标注

- **审查阈值规则**
  - diff < 20 行跳过子agent审查（自审即可）
  - diff 20-100 行触发代码审查
  - diff 100+ 行触发完整三层审查
  - 安全/核心API变更例外：无论大小必须审查

### 重构 🔨

- **SKILL.md 精简为路由层**
  - 从 582 行精简至 206 行（减少 65%）
  - 只保留模式选择逻辑 + Phase 路由表 + 快速参考索引
  - 详细方法论通过 READ 指令按需加载 references
  - 预计入口 token 消耗减少 ~65%

- **references 内容补全与去重**
  - phase-guide-execution.md 新增"阶段回退协议"
  - phase-guide-closing.md 新增"变更目录管理"和"平台适配表"
  - 消除 SKILL.md 与 references 之间的内容重复
  - 确保每个 READ 引用均有对应目标章节

### 文档 📝

- 新增 `docs/analysis-openspec-superpowers-fusion.md` — OpenSpec + Superpowers 融合分析

---

## [1.7.1] - 2026-04-15

### 修复 🐛

- **worktree 基准分支动态检测**
  - worktree 基准分支从硬编码 `main` 改为动态检测当前分支
  - 支持基于多个分支创建 worktree，避免分支冲突问题

### 重构 🔨

- **移除辅助脚本**
  - 移除 `init-change.sh` 和 `finish-change.sh` 辅助脚本
  - 精简项目结构，通过技能引导完成相同功能

- **Phase 入口指令统一**
  - SKILL.md 各 Phase 入口统一添加 READ 加载指令
  - 改善文档加载规范化和一致性

---

## [1.7.0] - 2026-04-12

### 重构 🔨

- **执行阶段流程优化**
  - Phase 6/7 融合：审查从批量后置改为**逐任务内嵌 + 全局收尾**
  - 每个任务完成后立即审查，发现问题立即修复，避免问题堆积
  - 引入**修复→重审闭环**（最多3轮，超过则升级用户决策）
  - 增加 `DONE_WITH_CONCERNS` 子 agent 状态（任务完成但有非阻塞性建议）
  
- **子 Agent 调度原则强化**
  - 强化上下文隔离原则：每个任务启动**全新子 agent**（fresh per task）
  - 控制器负责注入完整上下文（规范全文 + 任务定义 + 约束条件）
  - 子 agent 输出保持纯粹：代码变更 + 测试结果 + 状态标识
  - 新增"何时不用子 agent 并行"场景列表（故障关联/共享状态/探索性调试/强依赖链）
  
- **实现者（Implementer）能力提升**
  - 增加"开始前提问"机制：任务定义模糊时主动澄清而非猜测
  - 增加升级指南：遇到阻塞时如何升级回控制器
  - 明确输出约束：不解释背景、不总结收尾、只交付代码和结果

- **验证纪律贯穿化**
  - mindset.md 新增完整验证纪律章节
  - 提炼验证铁律：每个声称必须有证据，每个证据必须可验证
  - 新增反合理化表格（7种常见验证失败场景的"需要 vs 不够"对照）
  - 新增 Red Flags 语言信号（模糊词/推测词/满意表达等停止信号）
  
- **Agent Prompt 质量指南**
  - execution-guide.md 新增常见错误表（太宽泛/缺上下文/无约束/输出模糊）
  - 提供每类错误的具体案例和改进方法

### 修复 🐛

#### Critical 级别

- **BUG-1: 工件 DAG 依赖错误**
  - `verification` 工件依赖从 `implementation` 改为 `review`(Standard+) 或 `implementation`(Flow)
  - 确保验证阶段不能跳过全局审查，保持质量门控完整性
  
- **BUG-2: Flow 模式恢复机制断裂**
  - 恢复机制增加目录存在性检查
  - 明确说明：Flow 模式不创建变更目录，不支持跨会话恢复
  - Flow 任务应在单次会话内完成

#### Important 级别

- **BUG-3: Phase 7 全局审查闭环缺失**
  - 增加修复→重审循环（最多2轮）
  - 超过2轮升级用户决策，避免无限循环
  
- **BUG-4: Phase 7 与 Phase 8 职责重叠**
  - Phase 7 全量回归测试改为**交叉影响检查**
  - 避免与 Phase 8 完整验证的重复工作
  
- **BUG-5: Status 状态机不完整**
  - 补充 status 状态流转说明
  - 明确 `review → done` 需 PR 合并后手动更新
  
- **BUG-6: Strict 完整性检查遗漏**
  - Strict 模式检查说明中补充 Phase 1.5 跳过条件
  - 完善需求澄清阶段的豁免场景
  
- **BUG-7: 审查顺序错误**
  - 强制 spec 审查通过后才执行 code 审查
  - 避免在规范错误时浪费代码审查时间

#### Moderate 级别

- **BUG-8: Flow 流程图注解不清晰**
  - 增加注解说明 `execute` 包含 TDD + 自我审查
  - 避免误解为"只写代码不审查"
  
- **BUG-9: 回退协议路径不完整**
  - 补充 Phase 7→6 和 Phase 8→6 回退路径
  - Phase 7 发现架构问题 → 回退 Phase 6 重新实现
  - Phase 8 验证失败 → 回退 Phase 6 修复根因
  
- **BUG-10: Phase 10 worktree 处理不明确**
  - 选项2（创建 PR）明确推荐 remove worktree
  - 避免 worktree 泄漏累积
  
- **BUG-11: 文档描述不同步**
  - review-verify.md 三层质量网描述同步为逐任务审查新结构
  - 保持文档一致性

### 改进 📝

- **文档质量提升**
  - 删除过时示例文件 `examples/add-user-avatars/multi-role-design.md`
  - 补全各阶段的边界条件和异常处理说明
  - 强化子 agent 使用指导的实操性

- **质量保障体系完善**
  - 从"批量审查"升级为"逐任务闭环"，缩短反馈周期
  - 从"状态报告"升级为"证据验证"，提高验证标准
  - 从"主观判断"升级为"信号检测"，减少合理化偏误

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

### 近期计划

- **1.8.0**: 架构优化
  - phase-guide.md 按阶段分组拆分（规划/执行/收尾）
  - SKILL.md Phase 6 章节精简回路由器定位
  - 引用文档加载时机指令化

- **1.9.0**: 更多示例和工具
  - 添加 Flow / Strict 模式端到端完整示例
  - 验证脚本 `scripts/validate-change.sh`
  - Delta 合并脚本 `scripts/merge-delta.sh`
  - init-change.sh 与 worktree 联动（Strict 自动创建）
  - Eval 测试用例纳入仓库

- **2.0.0**: 可能的破坏性变更
  - 工件格式优化
  - 模式选择算法改进
  - 跨项目规范复用
