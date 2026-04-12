#!/bin/bash
# SpecPower 变更收尾脚本
# 用法: ./scripts/finish-change.sh <change-name-with-timestamp> [action]
# 示例: ./scripts/finish-change.sh add-user-auth-20260408143025 merge

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

usage() {
    echo "用法: $0 <change-name> [action]"
    echo ""
    echo "参数:"
    echo "  change-name    变更全名（含时间戳），例如: add-user-auth-20260408143025"
    echo "  action         收尾动作（可选），可选值:"
    echo "                   merge   - 合并到基准分支并清理"
    echo "                   pr      - 推送并创建 Pull Request"
    echo "                   keep    - 保留当前状态"
    echo "                   discard - 废弃变更（需确认）"
    echo "                 不指定时交互式选择"
    echo ""
    echo "示例:"
    echo "  $0 add-user-auth-20260408143025"
    echo "  $0 add-user-auth-20260408143025 merge"
    echo ""
    exit 1
}

if [ $# -lt 1 ]; then
    usage
fi

CHANGE_NAME=$1
ACTION=${2:-""}
BRANCH_NAME="spec-power/$CHANGE_NAME"
WORKTREE_PATH=".worktrees/$CHANGE_NAME"
CHANGE_DIR="docs/spec-power/changes/$CHANGE_NAME"
YAML_FILE="$CHANGE_DIR/.specpower.yaml"

# 检测基准分支：优先从 .specpower.yaml 读取 base_branch，回退到 main/master
detect_base_branch() {
    # 优先从 .specpower.yaml 读取创建时记录的基准分支
    if [ -f "$YAML_FILE" ]; then
        local yaml_branch
        yaml_branch=$(grep '^base_branch:' "$YAML_FILE" 2>/dev/null | sed 's/^base_branch:[[:space:]]*//' | sed 's/[[:space:]]*#.*//')
        if [ -n "$yaml_branch" ] && git rev-parse --verify "$yaml_branch" >/dev/null 2>&1; then
            echo "$yaml_branch"
            return
        fi
    fi
    # 回退：检测 main 或 master
    if git rev-parse --verify main >/dev/null 2>&1; then
        echo "main"
    elif git rev-parse --verify master >/dev/null 2>&1; then
        echo "master"
    else
        echo -e "${RED}错误: 找不到基准分支（.specpower.yaml 中无 base_branch，也找不到 main/master）${NC}" >&2
        exit 1
    fi
}

# 更新 .specpower.yaml 状态
update_status() {
    local new_status=$1
    if [ -f "$YAML_FILE" ]; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s/^status:.*$/status: $new_status/" "$YAML_FILE"
        else
            sed -i "s/^status:.*$/status: $new_status/" "$YAML_FILE"
        fi
        echo -e "${GREEN}✓${NC} 更新 status: $new_status"
    else
        echo -e "${YELLOW}⚠${NC} 未找到 $YAML_FILE，跳过状态更新"
    fi
}

# 清理 worktree
cleanup_worktree() {
    local force=${1:-false}
    if [ -d "$WORKTREE_PATH" ]; then
        echo -e "${CYAN}清理 worktree: $WORKTREE_PATH${NC}"
        if [ "$force" = true ]; then
            git worktree remove --force "$WORKTREE_PATH" 2>/dev/null || true
        else
            git worktree remove "$WORKTREE_PATH" 2>/dev/null || {
                echo -e "${YELLOW}⚠${NC} worktree 有未提交修改，使用 --force 强制清理"
                return 1
            }
        fi
        echo -e "${GREEN}✓${NC} Worktree 已清理"
    else
        echo -e "${YELLOW}⚠${NC} Worktree 不存在: $WORKTREE_PATH（可能已清理或未使用）"
    fi
}

# 检查分支是否存在
check_branch() {
    if ! git rev-parse --verify "$BRANCH_NAME" >/dev/null 2>&1; then
        echo -e "${YELLOW}⚠${NC} 分支不存在: $BRANCH_NAME"
        return 1
    fi
    return 0
}

BASE_BRANCH=$(detect_base_branch)

# 检查是否在 worktree 内执行
CURRENT_DIR=$(pwd)
if [[ "$CURRENT_DIR" == *"/.worktrees/"* ]]; then
    echo -e "${RED}错误: 不能在 worktree 目录内运行此脚本${NC}"
    echo "请先切换到主项目目录："
    echo "  cd <主项目根目录>"
    echo "  ./scripts/finish-change.sh $CHANGE_NAME $ACTION"
    exit 1
fi

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}SpecPower 变更收尾${NC}"
echo -e "${CYAN}========================================${NC}"
echo "变更: $CHANGE_NAME"
echo "分支: $BRANCH_NAME"
echo "Worktree: $WORKTREE_PATH"
echo "基准分支: $BASE_BRANCH"
echo ""

# Step 1: 验证测试通过（keep 和 discard 跳过测试门控）
if [ "$ACTION" != "keep" ] && [ "$ACTION" != "discard" ]; then
    echo -e "${CYAN}>>> 验证测试...${NC}"
    echo ""
    echo "请确认项目测试已全部通过。"
    echo "常用命令: npm test / cargo test / pytest / go test ./..."
    echo ""
    read -p "测试是否已全部通过？[y/N]: " test_ok
    if [ "$test_ok" != "y" ] && [ "$test_ok" != "Y" ]; then
        echo -e "${RED}测试未通过，请先修复再收尾。${NC}"
        exit 1
    fi
    echo ""
fi

# 交互式选择
if [ -z "$ACTION" ]; then
    echo "选择收尾方式:"
    echo "  1) merge   - 合并到 $BASE_BRANCH 并清理"
    echo "  2) pr      - 推送并创建 Pull Request"
    echo "  3) keep    - 保留当前状态"
    echo "  4) discard - 废弃变更"
    echo ""
    read -p "请选择 [1-4]: " choice
    case $choice in
        1) ACTION="merge" ;;
        2) ACTION="pr" ;;
        3) ACTION="keep" ;;
        4) ACTION="discard" ;;
        *) echo -e "${RED}无效选择${NC}"; exit 1 ;;
    esac
fi

case $ACTION in
    merge)
        echo ""
        echo -e "${GREEN}>>> 合并到 $BASE_BRANCH 并清理${NC}"

        # 切到基准分支
        git checkout "$BASE_BRANCH"
        git pull

        # 合并
        if check_branch; then
            git merge "$BRANCH_NAME"
            echo -e "${GREEN}✓${NC} 合并完成"

            # 合并后验证测试
            echo ""
            echo -e "${CYAN}>>> 验证合并后测试...${NC}"
            read -p "请运行测试并确认全部通过。测试是否通过？[y/N]: " merge_test_ok
            if [ "$merge_test_ok" != "y" ] && [ "$merge_test_ok" != "Y" ]; then
                echo -e "${RED}测试未通过，回滚合并...${NC}"
                git reset --hard HEAD~1
                echo -e "${YELLOW}合并已回滚。请修复问题后重新运行。${NC}"
                exit 1
            fi

            # 删除分支
            git branch -d "$BRANCH_NAME"
            echo -e "${GREEN}✓${NC} 分支已删除: $BRANCH_NAME"
        fi

        # 清理 worktree
        cleanup_worktree

        # 更新状态
        update_status "done"

        echo ""
        echo -e "${GREEN}收尾完成！变更已合并到 $BASE_BRANCH${NC}"
        ;;

    pr)
        echo ""
        echo -e "${GREEN}>>> 推送并创建 Pull Request${NC}"

        if check_branch; then
            # 推送
            git push -u origin "$BRANCH_NAME"
            echo -e "${GREEN}✓${NC} 分支已推送"

            # 创建 PR
            if command -v gh >/dev/null 2>&1; then
                echo "正在创建 PR..."
                gh pr create --title "$CHANGE_NAME" --body "## 变更概要

由 SpecPower 工作流生成。

详见 \`$CHANGE_DIR/\` 中的工件文档。"
                echo -e "${GREEN}✓${NC} PR 已创建"
            else
                echo -e "${YELLOW}⚠${NC} 未安装 gh CLI，请手动创建 PR"
                echo "  分支: $BRANCH_NAME → $BASE_BRANCH"
            fi
        fi

        # 询问是否清理 worktree
        echo ""
        read -p "代码已推送。是否清理 worktree？[y/N]: " cleanup_choice
        if [ "$cleanup_choice" = "y" ] || [ "$cleanup_choice" = "Y" ]; then
            cleanup_worktree
            echo -e "${YELLOW}注意: worktree 已清理，如需继续修改请重新 checkout 分支${NC}"
        else
            echo -e "${YELLOW}保留 worktree: $WORKTREE_PATH${NC}"
            echo "PR 合并后可运行: git worktree remove $WORKTREE_PATH"
        fi

        # 更新状态
        update_status "review"

        echo ""
        echo -e "${GREEN}收尾完成！PR 已创建，等待审查${NC}"
        ;;

    keep)
        echo ""
        echo -e "${YELLOW}>>> 保留当前状态${NC}"
        echo "分支 $BRANCH_NAME 和 worktree $WORKTREE_PATH 保持不变。"
        echo "稍后可重新运行此脚本选择其他操作。"
        ;;

    discard)
        echo ""
        echo -e "${RED}>>> 废弃变更${NC}"
        echo ""
        echo -e "${RED}即将永久删除:${NC}"
        echo "  - 分支: $BRANCH_NAME"
        echo "  - Worktree: $WORKTREE_PATH"

        if check_branch; then
            echo "  - 包含的提交:"
            git log --oneline "$BASE_BRANCH".."$BRANCH_NAME" 2>/dev/null | sed 's/^/    /'
        fi

        echo ""
        read -p "确认废弃请输入 'discard': " confirm
        if [ "$confirm" != "discard" ]; then
            echo "已取消。"
            exit 0
        fi

        # 切到基准分支
        git checkout "$BASE_BRANCH" 2>/dev/null || true

        # 强制删除分支
        if check_branch; then
            git branch -D "$BRANCH_NAME"
            echo -e "${GREEN}✓${NC} 分支已强制删除"
        fi

        # 强制清理 worktree
        cleanup_worktree true

        # 更新状态
        update_status "archived"

        echo ""
        echo -e "${GREEN}变更已废弃并清理完成${NC}"
        ;;

    *)
        echo -e "${RED}错误: 无效的动作 '$ACTION'${NC}"
        echo "可选值: merge, pr, keep, discard"
        exit 1
        ;;
esac
