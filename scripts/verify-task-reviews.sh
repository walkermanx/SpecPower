#!/usr/bin/env bash
# verify-task-reviews.sh — 校验任务审查产物完整性
#
# 用途:
#   1. 手动: 控制器在 git commit 前调用, 验证审查文件齐全
#   2. 自动: 安装为 git pre-commit hook, 硬强制审查产物
#
# 用法:
#   scripts/verify-task-reviews.sh <change-dir> <task-id>
#   scripts/verify-task-reviews.sh auto                    # 从 .specpower.yaml 自动推断
#
# 退出码:
#   0 - 所有审查产物齐全且 frontmatter 有效
#   1 - 缺失审查文件或 frontmatter 无效
#   2 - 参数错误或变更目录不存在
#
# 详细协议见: references/review-artifact-protocol.md

set -u

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

err() { echo -e "${RED}[错误]${NC} $*" >&2; }
warn() { echo -e "${YELLOW}[警告]${NC} $*" >&2; }
ok() { echo -e "${GREEN}[通过]${NC} $*"; }

# ---------------------------------------------------------------------
# 参数解析
# ---------------------------------------------------------------------

if [ $# -eq 0 ]; then
    err "用法: $0 <change-dir> <task-id>  或  $0 auto"
    exit 2
fi

CHANGE_DIR=""
TASK_ID=""

if [ "$1" = "auto" ]; then
    # 自动模式: 从 docs/spec-power/changes 找唯一 in-progress 变更
    CANDIDATES=$(find docs/spec-power/changes -maxdepth 2 -name ".specpower.yaml" 2>/dev/null | \
                 xargs grep -l "status: in-progress" 2>/dev/null || true)
    CANDIDATE_COUNT=$(echo "$CANDIDATES" | grep -c . || true)

    if [ "$CANDIDATE_COUNT" -eq 0 ]; then
        err "auto 模式: 找不到 in-progress 状态的变更目录"
        exit 2
    fi

    if [ "$CANDIDATE_COUNT" -gt 1 ]; then
        err "auto 模式: 发现多个 in-progress 变更, 请显式指定目录和任务 ID"
        echo "$CANDIDATES" >&2
        exit 2
    fi

    CHANGE_DIR=$(dirname "$CANDIDATES")

    # 从 .specpower.yaml 找第一个 status 为 in_progress 的任务
    TASK_ID=$(awk '
        /^tasks:/ { in_tasks = 1; next }
        in_tasks && /^  - id:/ { cur_id = $3 }
        in_tasks && /status: in_progress/ { print cur_id; exit }
    ' "$CHANGE_DIR/.specpower.yaml")

    if [ -z "$TASK_ID" ]; then
        err "auto 模式: .specpower.yaml 中找不到 in_progress 任务"
        exit 2
    fi

    echo "auto 模式: 使用变更目录 $CHANGE_DIR, 任务 ID $TASK_ID"
else
    if [ $# -ne 2 ]; then
        err "用法: $0 <change-dir> <task-id>"
        exit 2
    fi
    CHANGE_DIR="$1"
    TASK_ID="$2"
fi

if [ ! -d "$CHANGE_DIR" ]; then
    err "变更目录不存在: $CHANGE_DIR"
    exit 2
fi

REVIEWS_DIR="$CHANGE_DIR/reviews"
if [ ! -d "$REVIEWS_DIR" ]; then
    err "审查目录不存在: $REVIEWS_DIR (应由 Phase 6 首个任务自动创建)"
    exit 1
fi

# ---------------------------------------------------------------------
# 校验单个文件的 frontmatter
# ---------------------------------------------------------------------

check_frontmatter() {
    local file="$1"
    shift
    local required_fields=("$@")

    if [ ! -f "$file" ]; then
        return 1
    fi

    # 提取 frontmatter (首个 --- 到下一个 --- 之间)
    local fm
    fm=$(awk '/^---$/{c++; next} c==1' "$file")

    if [ -z "$fm" ]; then
        err "$file: 缺少 YAML frontmatter (首行应为 ---)"
        return 1
    fi

    for field in "${required_fields[@]}"; do
        if ! echo "$fm" | grep -q "^${field}:"; then
            err "$file: frontmatter 缺少必填字段 '$field'"
            return 1
        fi
    done

    return 0
}

# ---------------------------------------------------------------------
# 校验任务审查产物
# ---------------------------------------------------------------------

PREFIX="$REVIEWS_DIR/task-${TASK_ID}"
FAILED=0

# 1. 自审文件 (必须存在, 不可跳过)
SELF_FILE="${PREFIX}-self.md"
if ! check_frontmatter "$SELF_FILE" task type timestamp diff_lines; then
    err "任务 $TASK_ID: 缺少自审文件 $SELF_FILE"
    FAILED=1
else
    ok "任务 $TASK_ID: 自审文件齐全 ($SELF_FILE)"
fi

# 2. 规范审查 (执行或跳过二选一)
SPEC_FILE="${PREFIX}-spec.md"
SPEC_SKIP_FILE="${PREFIX}-spec-skip.md"

if [ -f "$SPEC_FILE" ] && [ -f "$SPEC_SKIP_FILE" ]; then
    err "任务 $TASK_ID: 同时存在 $SPEC_FILE 和 $SPEC_SKIP_FILE, 不允许"
    FAILED=1
elif [ -f "$SPEC_FILE" ]; then
    if ! check_frontmatter "$SPEC_FILE" task type reviewer timestamp verdict; then
        FAILED=1
    else
        ok "任务 $TASK_ID: 规范审查已执行 ($SPEC_FILE)"
    fi
elif [ -f "$SPEC_SKIP_FILE" ]; then
    if ! check_frontmatter "$SPEC_SKIP_FILE" task type timestamp diff_lines threshold forced_exception_check; then
        FAILED=1
    else
        ok "任务 $TASK_ID: 规范审查跳过声明 ($SPEC_SKIP_FILE)"
    fi
else
    err "任务 $TASK_ID: 必须有 $SPEC_FILE 或 $SPEC_SKIP_FILE 之一"
    FAILED=1
fi

# 3. 代码审查 (执行或跳过二选一)
CODE_FILE="${PREFIX}-code.md"
CODE_SKIP_FILE="${PREFIX}-code-skip.md"

if [ -f "$CODE_FILE" ] && [ -f "$CODE_SKIP_FILE" ]; then
    err "任务 $TASK_ID: 同时存在 $CODE_FILE 和 $CODE_SKIP_FILE, 不允许"
    FAILED=1
elif [ -f "$CODE_FILE" ]; then
    if ! check_frontmatter "$CODE_FILE" task type reviewer timestamp verdict; then
        FAILED=1
    else
        ok "任务 $TASK_ID: 代码审查已执行 ($CODE_FILE)"
    fi
elif [ -f "$CODE_SKIP_FILE" ]; then
    if ! check_frontmatter "$CODE_SKIP_FILE" task type timestamp diff_lines threshold forced_exception_check; then
        FAILED=1
    else
        ok "任务 $TASK_ID: 代码审查跳过声明 ($CODE_SKIP_FILE)"
    fi
else
    err "任务 $TASK_ID: 必须有 $CODE_FILE 或 $CODE_SKIP_FILE 之一"
    FAILED=1
fi

# ---------------------------------------------------------------------
# 校验跳过声明中的行数字段 (可选但推荐)
# ---------------------------------------------------------------------

verify_diff_lines_match() {
    local skip_file="$1"
    if [ ! -f "$skip_file" ]; then return 0; fi

    local declared
    declared=$(awk '/^---$/{c++; next} c==1 && /^diff_lines:/ { print $2 }' "$skip_file")

    if [ -z "$declared" ]; then return 0; fi

    # 计算当前 staged diff 行数 (仅代码文件, 不含 reviews/)
    local actual
    actual=$(git diff --cached --numstat 2>/dev/null | \
             awk -v rdir="$REVIEWS_DIR" '$3 !~ rdir { s += $1 + $2 } END { print s+0 }')

    if [ "$actual" -eq 0 ]; then return 0; fi

    # 允许 ±20% 或 ±5 行偏差
    local tolerance=$(( actual / 5 ))
    if [ "$tolerance" -lt 5 ]; then tolerance=5; fi

    local low=$(( actual - tolerance ))
    local high=$(( actual + tolerance ))

    if [ "$declared" -lt "$low" ] || [ "$declared" -gt "$high" ]; then
        warn "$skip_file: 声明 diff_lines=$declared 与实际 staged diff=$actual 偏差过大 (容差: ±$tolerance)"
    fi
}

verify_diff_lines_match "$SPEC_SKIP_FILE"
verify_diff_lines_match "$CODE_SKIP_FILE"

# ---------------------------------------------------------------------
# 结果
# ---------------------------------------------------------------------

if [ $FAILED -eq 0 ]; then
    echo
    ok "任务 $TASK_ID 的所有审查产物齐全且 frontmatter 有效"
    exit 0
else
    echo
    err "任务 $TASK_ID 审查产物不完整, 拒绝 commit"
    err "请补齐缺失的审查文件 (见 references/review-artifact-protocol.md)"
    exit 1
fi
