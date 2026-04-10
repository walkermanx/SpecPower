#!/bin/bash
# SpecPower 版本号更新脚本
# 用法: ./scripts/bump-version.sh <new-version>
# 示例: ./scripts/bump-version.sh 1.4.0

set -e  # 遇到错误立即退出

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 显示使用说明
usage() {
    echo "用法: $0 <new-version>"
    echo ""
    echo "参数:"
    echo "  new-version    新版本号（必需），格式: X.Y.Z"
    echo "                 例如: 1.4.0, 2.0.0-beta, 1.3.1"
    echo ""
    echo "功能:"
    echo "  - 更新 SKILL.md frontmatter 和正文中的版本号"
    echo "  - 更新 README.md 版本徽章"
    echo "  - 验证更新结果"
    echo ""
    echo "示例:"
    echo "  $0 1.4.0"
    echo "  $0 2.0.0-beta"
    echo ""
    exit 1
}

# 检查参数
if [ $# -lt 1 ]; then
    echo -e "${RED}错误: 缺少版本号参数${NC}"
    usage
fi

NEW_VERSION="$1"

# 验证版本号格式（基本验证）
if ! [[ "$NEW_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9]+)?$ ]]; then
    echo -e "${RED}错误: 版本号格式不正确${NC}"
    echo "期望格式: X.Y.Z 或 X.Y.Z-suffix（例如: 1.4.0 或 2.0.0-beta）"
    exit 1
fi

# 定位到项目根目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

echo -e "${BLUE}SpecPower 版本更新工具${NC}"
echo "================================"
echo ""

# 获取当前版本号
CURRENT_VERSION=$(grep '^version:' SKILL.md | head -1 | sed 's/version: "\(.*\)"/\1/')
echo -e "当前版本: ${YELLOW}${CURRENT_VERSION}${NC}"
echo -e "新版本号: ${GREEN}${NEW_VERSION}${NC}"
echo ""

# 询问确认
read -p "确认更新版本号? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}已取消${NC}"
    exit 0
fi

echo ""
echo "开始更新..."
echo ""

# 备份标记
BACKUP_SUFFIX=".backup-$(date +%Y%m%d%H%M%S)"

# 1. 更新 SKILL.md frontmatter
echo -e "${BLUE}[1/3]${NC} 更新 SKILL.md frontmatter..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s/^version: \".*\"/version: \"${NEW_VERSION}\"/" SKILL.md
else
    # Linux
    sed -i "s/^version: \".*\"/version: \"${NEW_VERSION}\"/" SKILL.md
fi
echo -e "  ${GREEN}✓${NC} SKILL.md frontmatter 已更新"

# 2. 更新 SKILL.md 正文版本号显示
echo -e "${BLUE}[2/3]${NC} 更新 SKILL.md 正文..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s/> \*\*版本\*\*: [0-9.a-zA-Z-]*/> **版本**: ${NEW_VERSION}/" SKILL.md
else
    # Linux
    sed -i "s/> \*\*版本\*\*: [0-9.a-zA-Z-]*/> **版本**: ${NEW_VERSION}/" SKILL.md
fi
echo -e "  ${GREEN}✓${NC} SKILL.md 正文已更新"

# 3. 更新 README.md 版本徽章
echo -e "${BLUE}[3/3]${NC} 更新 README.md 版本徽章..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s/version-[0-9.a-zA-Z-]*-blue/version-${NEW_VERSION}-blue/" README.md
else
    # Linux
    sed -i "s/version-[0-9.a-zA-Z-]*-blue/version-${NEW_VERSION}-blue/" README.md
fi
echo -e "  ${GREEN}✓${NC} README.md 已更新"

echo ""
echo "验证更新结果..."
echo ""

# 验证更新
SKILL_FRONTMATTER_VERSION=$(grep '^version:' SKILL.md | head -1 | sed 's/version: "\(.*\)"/\1/')
SKILL_BODY_VERSION=$(grep '> \*\*版本\*\*:' SKILL.md | head -1 | sed 's/.*: \([0-9.a-zA-Z-]*\).*/\1/')
README_VERSION=$(grep 'version-.*-blue' README.md | head -1 | sed 's/.*version-\([0-9.a-zA-Z-]*\)-blue.*/\1/')

echo "更新后版本号："
echo "  SKILL.md frontmatter: $SKILL_FRONTMATTER_VERSION"
echo "  SKILL.md 正文:        $SKILL_BODY_VERSION"
echo "  README.md 徽章:       $README_VERSION"
echo ""

# 检查一致性
if [ "$SKILL_FRONTMATTER_VERSION" = "$NEW_VERSION" ] && \
   [ "$SKILL_BODY_VERSION" = "$NEW_VERSION" ] && \
   [ "$README_VERSION" = "$NEW_VERSION" ]; then
    echo -e "${GREEN}✓ 版本号更新成功！所有位置一致。${NC}"
    echo ""
    echo "下一步："
    echo "  1. 更新 CHANGELOG.md（如需要）"
    echo "  2. 提交更改: git add SKILL.md README.md && git commit -m \"chore: bump version to ${NEW_VERSION}\""
    echo "  3. 推送到远程: git push origin main"
    echo ""
else
    echo -e "${RED}✗ 警告: 版本号不一致！${NC}"
    echo "请检查文件内容。"
    exit 1
fi
