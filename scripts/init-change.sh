#!/bin/bash
# SpecPower 变更目录初始化脚本
# 用法: ./scripts/init-change.sh <change-name> [mode]
# 示例: ./scripts/init-change.sh add-user-auth standard

set -e  # 遇到错误立即退出

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 显示使用说明
usage() {
    echo "用法: $0 <change-name> [mode]"
    echo ""
    echo "参数:"
    echo "  change-name    变更名称（必需），例如: add-user-auth"
    echo "  mode           工作模式（可选），可选值: flow | standard | strict"
    echo "                 默认: standard"
    echo ""
    echo "示例:"
    echo "  $0 add-user-auth"
    echo "  $0 refactor-payment strict"
    echo ""
    exit 1
}

# 检查参数
if [ $# -lt 1 ]; then
    usage
fi

CHANGE_NAME=$1
MODE=${2:-standard}

# 验证模式
if [[ ! "$MODE" =~ ^(flow|standard|strict)$ ]]; then
    echo -e "${RED}错误: 无效的模式 '$MODE'${NC}"
    echo "可选值: flow, standard, strict"
    exit 1
fi

# 验证变更名称格式（只允许小写字母、数字、连字符）
if [[ ! "$CHANGE_NAME" =~ ^[a-z0-9-]+$ ]]; then
    echo -e "${RED}错误: 变更名称只能包含小写字母、数字和连字符${NC}"
    echo "示例: add-user-auth, fix-payment-bug"
    exit 1
fi

# 生成时间戳
TIMESTAMP=$(date +%Y%m%d%H%M%S)
FULL_NAME="${CHANGE_NAME}-${TIMESTAMP}"

# 确定基础路径
BASE_DIR="docs/spec-power/changes/$FULL_NAME"

# 检查目录是否已存在（理论上不会因为有时间戳，但保留检查）
if [ -d "$BASE_DIR" ]; then
    echo -e "${RED}错误: 变更目录已存在: $BASE_DIR${NC}"
    exit 1
fi

echo -e "${GREEN}正在创建 SpecPower 变更目录...${NC}"
echo "基础名称: $CHANGE_NAME"
echo "完整名称: $FULL_NAME"
echo "模式: $MODE"
echo "路径: $BASE_DIR"
echo ""

# 创建目录结构
mkdir -p "$BASE_DIR"

# 如果是 Strict 模式，创建 specs 目录
if [ "$MODE" == "strict" ]; then
    mkdir -p "$BASE_DIR/specs"
fi

# 获取当前日期
CURRENT_DATE=$(date +%Y-%m-%d)

# 创建 .specpower.yaml
cat > "$BASE_DIR/.specpower.yaml" <<EOF
name: $FULL_NAME
mode: $MODE              # flow | standard | strict
created: $CURRENT_DATE
status: in-progress      # in-progress | review | done | archived
artifacts:
  proposal: pending
EOF

# 根据模式添加不同的工件状态
if [ "$MODE" == "strict" ]; then
    cat >> "$BASE_DIR/.specpower.yaml" <<EOF
  explore: pending         # 无依赖，可立即开始
  clarify: blocked         # 依赖 explore
  specs: blocked           # 依赖 proposal
  design: blocked          # 依赖 proposal
  tasks: blocked           # 依赖 specs + design
  implementation: blocked
  review: blocked
  verification: blocked
  archive: blocked
EOF
elif [ "$MODE" == "standard" ]; then
    cat >> "$BASE_DIR/.specpower.yaml" <<EOF
  clarify: pending         # 可选，可立即开始
  design: blocked          # 依赖 proposal
  tasks: blocked           # 依赖 design
  implementation: blocked
  review: blocked
  verification: blocked
EOF
else  # flow
    cat >> "$BASE_DIR/.specpower.yaml" <<EOF
  implementation: blocked  # 依赖口头提案
  verification: blocked
EOF
fi

echo -e "${GREEN}✓${NC} 创建 .specpower.yaml"

# 创建 proposal.md
cat > "$BASE_DIR/proposal.md" <<EOF
# $CHANGE_NAME

## 动机

<为什么要做这个变更？解决什么问题？有什么背景？>

## 变更范围

### 新增能力

- \`capability-name\`: <描述>

### 修改能力

- \`existing-name\`: <什么变了，为什么>

### 不在范围内

- <明确列出不做的事情，避免范围蔓延>

## 影响分析

### 向后兼容性

<是否兼容？不兼容的话如何处理？>

### 性能影响

<预期的性能变化>

### 安全考虑

<是否引入新的攻击面？>

### 依赖变化

<新增或移除的依赖>

## 成功标准

<怎么算"做完了"？可量化的指标>

- [ ] 标准 1
- [ ] 标准 2
EOF

echo -e "${GREEN}✓${NC} 创建 proposal.md（模板）"

# 如果是 Standard 或 Strict 模式，创建 design.md
if [ "$MODE" == "standard" ] || [ "$MODE" == "strict" ]; then
    cat > "$BASE_DIR/design.md" <<EOF
# $CHANGE_NAME 技术设计

## 现状

<当前系统相关部分如何工作>

## 目标

- <目标 1>
- <目标 2>

## 非目标

- <明确不追求的目标>

## 方案对比

### 方案 A: <名称> (推荐)

<核心思路描述>

**优势**:
- ...

**劣势**:
- ...

**实现复杂度**: 低/中/高

### 方案 B: <名称>

<核心思路描述>

**优势**:
- ...

**劣势**:
- ...

## 决策

选择方案 A。

<决策理由，具体到为什么 A 的优势比 B 更重要>

## 关键设计

### 数据模型

<新增或修改的数据结构>

### 接口设计

<API、函数签名、事件>

### 错误处理

<错误类型和处理策略>

## 风险与缓解

| 风险 | 概率 | 影响 | 缓解措施 |
|------|------|------|---------|
| ... | 低/中/高 | 低/中/高 | ... |

## 迁移计划 (如需)

<分步部署、数据迁移、回滚方案>
EOF
    echo -e "${GREEN}✓${NC} 创建 design.md（模板）"
fi

# 如果是 Standard 或 Strict 模式，创建 tasks.md
if [ "$MODE" == "standard" ] || [ "$MODE" == "strict" ]; then
    cat > "$BASE_DIR/tasks.md" <<EOF
# $CHANGE_NAME 实现计划

> **执行方式**: 使用 spec-power 执行阶段

**目标**: <一句话>
**架构**: <2-3句话概括>
**技术栈**: <关键技术>

---

## Task 1: <组件名>

**文件**:
- Create: \`<精确路径>\`
- Modify: \`<精确路径>\`
- Test: \`<精确路径>\`

**依赖**: 无 (可并行)

**步骤**:
- [ ] 编写失败测试: \`<具体描述测试什么>\`
  验证: \`<运行命令>\` → 期望失败
- [ ] 最小实现使测试通过
  验证: \`<运行命令>\` → 期望全部通过
- [ ] 重构 (如需)
  验证: \`<运行命令>\` → 保持全部通过
- [ ] 提交: \`git commit -m "<commit message>"\`

## Task 2: <组件名>

**文件**: ...
**依赖**: Task 1 (需要其导出的接口)

**步骤**:
- [ ] ...

---

## 依赖图

\`\`\`
Task 1 ──► Task 3
Task 2 ──► Task 3
Task 3 ──► Task 4
\`\`\`

可并行: Task 1, Task 2
EOF
    echo -e "${GREEN}✓${NC} 创建 tasks.md（模板）"
fi

# 如果是 Strict 模式，创建 specs 示例文件
if [ "$MODE" == "strict" ]; then
    cat > "$BASE_DIR/specs/example-spec.md" <<EOF
# <领域名称> 规范 (Delta)

## ADDED Requirements

### Requirement: <行为名称>

系统 SHALL <行为描述>

#### Scenario: <场景名>

- **GIVEN** <前置条件>
- **WHEN** <触发动作>
- **THEN** <预期结果>

## MODIFIED Requirements

### Requirement: <现有行为名称>

系统 MUST <修改后的行为>
(之前: <原始行为>)

## REMOVED Requirements

无
EOF
    echo -e "${GREEN}✓${NC} 创建 specs/example-spec.md（模板）"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}变更目录创建成功！${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "下一步:"
echo "1. 编辑 proposal.md，填写变更动机和范围"

if [ "$MODE" == "standard" ] || [ "$MODE" == "strict" ]; then
    echo "2. 编辑 design.md，记录技术决策"
    echo "3. 编辑 tasks.md，分解实现任务"
fi

if [ "$MODE" == "strict" ]; then
    echo "4. 在 specs/ 目录创建详细规范"
    echo ""
    echo -e "${YELLOW}注意: Strict 模式必须使用 Git Worktree 隔离${NC}"
    echo "创建 worktree: git worktree add .worktrees/$FULL_NAME -b spec-power/$FULL_NAME"
fi

echo ""
echo "查看完整指南: 打开 SKILL.md"
echo "参考示例: examples/add-user-avatars/"
