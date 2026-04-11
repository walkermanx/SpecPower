#!/bin/bash
# SpecPower 技能打包脚本
# 用法: ./scripts/package-skill.sh
# 输出: spec-power-v{version}.zip

set -e

# 颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# 获取脚本所在目录（spec-power 根目录）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$ROOT_DIR"

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}SpecPower 技能打包${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

# 从 SKILL.md frontmatter 中提取版本号
if [ ! -f "SKILL.md" ]; then
    echo -e "${RED}错误: 找不到 SKILL.md${NC}"
    exit 1
fi

VERSION=$(grep '^version:' SKILL.md | head -1 | sed 's/version: *"\(.*\)"/\1/' | tr -d ' ')

if [ -z "$VERSION" ]; then
    echo -e "${RED}错误: 无法从 SKILL.md 中提取版本号${NC}"
    exit 1
fi

OUTPUT_FILE="spec-power-v${VERSION}.zip"

echo "版本号: $VERSION"
echo "输出文件: $OUTPUT_FILE"
echo ""

# 检查是否已存在同名文件
if [ -f "$OUTPUT_FILE" ]; then
    echo -e "${YELLOW}警告: $OUTPUT_FILE 已存在${NC}"
    read -p "是否覆盖？[y/N]: " overwrite
    if [ "$overwrite" != "y" ] && [ "$overwrite" != "Y" ]; then
        echo "已取消。"
        exit 0
    fi
    rm "$OUTPUT_FILE"
fi

echo -e "${GREEN}正在打包必需文件...${NC}"
echo ""

# 创建临时目录
TEMP_DIR=$(mktemp -d)
PACKAGE_DIR="$TEMP_DIR/spec-power"
mkdir -p "$PACKAGE_DIR"

# 复制核心文件
echo "📄 核心文档"
cp SKILL.md "$PACKAGE_DIR/"
cp README.md "$PACKAGE_DIR/"
cp CHANGELOG.md "$PACKAGE_DIR/"
echo "  ✓ SKILL.md, README.md, CHANGELOG.md"

# 复制 references 目录
echo ""
echo "📚 参考文档"
cp -r references "$PACKAGE_DIR/"
echo "  ✓ references/ ($(ls references | wc -l | tr -d ' ') 个文件)"

# 复制 agents 目录
echo ""
echo "🤖 Agent 提示"
cp -r agents "$PACKAGE_DIR/"
echo "  ✓ agents/ ($(ls agents | wc -l | tr -d ' ') 个文件)"

# 复制 scripts 目录（排除开发工具脚本）
echo ""
echo "🔧 自动化脚本"
mkdir -p "$PACKAGE_DIR/scripts"
for script in scripts/*.sh; do
    # 排除打包脚本自身和版本管理脚本
    if [ "$script" != "scripts/package-skill.sh" ] && [ "$script" != "scripts/bump-version.sh" ]; then
        cp "$script" "$PACKAGE_DIR/scripts/"
    fi
done
echo "  ✓ scripts/ ($(ls "$PACKAGE_DIR/scripts" | wc -l | tr -d ' ') 个文件)"

# 复制 examples 目录
echo ""
echo "📂 示例项目"
cp -r examples "$PACKAGE_DIR/"
echo "  ✓ examples/ ($(find examples -type f | wc -l | tr -d ' ') 个文件)"

# 复制示例配置文件（如果存在）
if [ -f ".specpower.yaml.example" ]; then
    cp .specpower.yaml.example "$PACKAGE_DIR/"
    echo "  ✓ .specpower.yaml.example"
fi

# 创建 zip 包
echo ""
echo -e "${GREEN}正在压缩...${NC}"
cd "$TEMP_DIR"
zip -r -q "$ROOT_DIR/$OUTPUT_FILE" spec-power/

# 清理临时目录
rm -rf "$TEMP_DIR"

# 显示结果
cd "$ROOT_DIR"
FILE_SIZE=$(ls -lh "$OUTPUT_FILE" | awk '{print $5}')

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}打包完成！${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "输出文件: $OUTPUT_FILE"
echo "文件大小: $FILE_SIZE"
echo ""

# 显示包含的内容
echo "包含内容:"
unzip -l "$OUTPUT_FILE" | head -20
echo "..."
echo ""
echo "总计: $(unzip -l "$OUTPUT_FILE" | tail -1 | awk '{print $2}') 个文件"

echo ""
echo -e "${CYAN}安装说明:${NC}"
echo "1. 解压: unzip $OUTPUT_FILE"
echo "2. 复制到项目: cp -r spec-power/ /path/to/your-project/docs/"
echo "3. 或链接技能: 参见 scripts/link-skill.sh"
