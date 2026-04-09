# Changelog

本文档记录 SpecPower 技能的所有重要变更。

版本号遵循 [Semantic Versioning](https://semver.org/lang/zh-CN/)：
- **主版本号**：不兼容的 API 修改
- **次版本号**：向下兼容的功能性新增
- **修订号**：向下兼容的问题修正

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
