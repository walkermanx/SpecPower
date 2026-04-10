#!/usr/bin/env bash
# link-skill-bash.sh — 将脚本所在目录软链接到 .claude/skills 或 .micode/skills 或 .cursor/skills 或 .opencode/skills 中 (Bash 版本)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 交互式菜单函数
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# 读取按键 (处理方向键转义序列)
# 结果写入 KEY_RESULT: up / down / enter / space / a / q / 其他字符
_read_key() {
  local key
  # 读取单个字符
  IFS= read -rsn1 key 2>/dev/null || {
    # 如果 read 失败，可能是遇到了回车键
    KEY_RESULT=enter
    return
  }

  # 处理读取到的字符
  case "$key" in
    '')  KEY_RESULT=enter ;;  # 空字符串通常表示回车
    $'\e')
      local seq
      IFS= read -rsn2 seq 2>/dev/null || true
      case "$seq" in
        '[A') KEY_RESULT=up ;;
        '[B') KEY_RESULT=down ;;
        *)    KEY_RESULT=other ;;
      esac
      ;;
    ' ')   KEY_RESULT=space ;;
    a|A)   KEY_RESULT=a ;;
    q|Q)   KEY_RESULT=q ;;
    y|Y)   KEY_RESULT=y ;;
    n|N)   KEY_RESULT=n ;;
    *)     KEY_RESULT=other ;;
  esac
}

# 单选菜单: 上/下键移动, 回车确认
# 用法: menu_single "提示语" item1 item2 ...
# 结果: MENU_RESULT = 选中索引 (1-based), 0 表示放弃
menu_single() {
  local prompt="$1"; shift
  local -a items=("$@")
  local count=${#items[@]}
  local cur=1
  local total_lines=$(( count + 1 ))

  printf '\e[?25l'
  trap 'printf "\e[?25h"' INT TERM

  printf '%b\n' "$prompt  \e[2m(↑↓:移动  回车:确认)\e[0m"
  while true; do
    for i in $(seq 1 $count); do
      if (( i == cur )); then
        printf '\e[36m  ❯ %s\e[0m\n' "${items[$((i-1))]}"
      else
        printf '    %s\n' "${items[$((i-1))]}"
      fi
    done
    if (( cur == 0 )); then
      printf '\e[36m  ❯ 放弃\e[0m\n'
    else
      printf '    放弃\n'
    fi

    _read_key
    case "$KEY_RESULT" in
      up)
        if (( cur == 0 )); then
          cur=$count
        elif (( cur > 1 )); then
          (( cur-- )) || true
        fi
        ;;
      down)
        if (( cur > 0 && cur < count )); then
          (( cur++ )) || true
        elif (( cur == count )); then
          cur=0
        fi
        ;;
      enter)
        MENU_RESULT=$cur
        break
        ;;
      q)
        MENU_RESULT=0
        break
        ;;
    esac
    printf "\e[${total_lines}A"
  done

  printf '\e[?25h'
}

# 多选菜单: 上/下键移动, 空格切换选中, 回车确认, a 全选/取消全选
# 用法: menu_multi "提示语" item1 item2 ...
# 结果: MENU_RESULTS = 选中索引数组 (1-based), MENU_RESULT = 0 表示放弃
menu_multi() {
  local prompt="$1"; shift
  local -a items=("$@")
  local count=${#items[@]}
  local cur=1
  local total_lines=$(( count + 1 ))
  local -a selected=()

  printf '\e[?25l'
  trap 'printf "\e[?25h"' INT TERM

  printf '%b\n' "$prompt  \e[2m(↑↓:移动  空格:切换选中  a:全选  回车:确认)\e[0m"
  while true; do
    for i in $(seq 1 $count); do
      local mark=" "
      # 检查是否选中
      if [[ ${#selected[@]} -gt 0 ]]; then
        for j in "${selected[@]}"; do
          if [[ "$j" == "$i" ]]; then
            mark="✓"
            break
          fi
        done
      fi
      if (( i == cur )); then
        printf '\e[36m  ❯ [%s] %s\e[0m\n' "$mark" "${items[$((i-1))]}"
      else
        printf '    [%s] %s\n' "$mark" "${items[$((i-1))]}"
      fi
    done
    if (( cur == 0 )); then
      printf '\e[36m  ❯ 放弃\e[0m\n'
    else
      printf '    放弃\n'
    fi

    _read_key
    case "$KEY_RESULT" in
      up)
        if (( cur == 0 )); then
          cur=$count
        elif (( cur > 1 )); then
          (( cur-- )) || true
        fi
        ;;
      down)
        if (( cur > 0 && cur < count )); then
          (( cur++ )) || true
        elif (( cur == count )); then
          cur=0
        fi
        ;;
      space)
        if (( cur >= 1 )); then
          # 检查是否已选中
          local found=0
          local index=0
          if [[ ${#selected[@]} -gt 0 ]]; then
            for j in "${selected[@]}"; do
              if [[ "$j" == "$cur" ]]; then
                found=1
                break
              fi
              ((index++))
            done
          fi
          if (( found )); then
            # 取消选中
            selected=("${selected[@]:0:$index}" "${selected[@]:$((index+1))}")
          else
            # 选中
            selected+=("$cur")
          fi
        fi
        ;;
      a)
        if (( ${#selected[@]} == count )); then
          selected=()
        else
          selected=()
          for i in $(seq 1 $count); do selected+=("$i"); done
        fi
        ;;
      enter)
        if (( cur == 0 )); then
          MENU_RESULTS=()
          MENU_RESULT=0
          break
        fi
        if [[ ${#selected[@]} -eq 0 ]]; then
          selected+=("$cur")
        fi
        MENU_RESULTS=("${selected[@]}")
        MENU_RESULT=1
        break
        ;;
      q)
        MENU_RESULTS=()
        MENU_RESULT=0
        break
        ;;
    esac
    printf "\e[${total_lines}A"
  done

  printf '\e[?25h'
}

# 确认菜单: 上/下键选择 确认/放弃
# 用法: menu_confirm "提示语"
# 结果: MENU_RESULT = 1(确认) 或 0(放弃)
menu_confirm() {
  local prompt="$1"
  local cur=1

  printf '\e[?25l'
  trap 'printf "\e[?25h"' INT TERM

  [[ -n "$prompt" ]] && echo "$prompt"
  while true; do
    if (( cur == 1 )); then
      printf '\e[32m  ❯ 确认执行\e[0m\n'
      printf '    放弃\n'
    else
      printf '    确认执行\n'
      printf '\e[31m  ❯ 放弃\e[0m\n'
    fi

    _read_key
    case "$KEY_RESULT" in
      up|down) (( cur = cur == 1 ? 0 : 1 )) || true ;;
      enter) break ;;
      y) cur=1; break ;;
      q|n) cur=0; break ;;
    esac
    printf "\e[2A"
  done

  printf '\e[?25h'
  MENU_RESULT=$cur
}

# ─── Step 0: 选择源 Skill 目录 ───
SOURCE_DIRS=()
SOURCE_LABELS=()

# 1. 当前脚本所在目录
SOURCE_DIRS+=("$SCRIPT_DIR")
SOURCE_LABELS+=("[当前目录] $(basename "$SCRIPT_DIR")")

# 2. agents 目录下的 skill
if [[ -d "$SCRIPT_DIR/agents" ]]; then
  # 使用 find 查找 agents 下第一层包含 SKILL.md 的目录
  while IFS= read -r -d '' agent_dir; do
    if [[ -f "$agent_dir/SKILL.md" ]]; then
      SOURCE_DIRS+=("$agent_dir")
      SOURCE_LABELS+=("[Agent] $(basename "$agent_dir")")
    fi
  done < <(find "$SCRIPT_DIR/agents" -mindepth 1 -maxdepth 1 -type d -print0)
fi

if [[ ${#SOURCE_DIRS[@]} -eq 1 ]]; then
  SELECTED_SOURCE_DIR="${SOURCE_DIRS[0]}"
else
  menu_single "📦 请选择要链接的源 Skill 目录:" "${SOURCE_LABELS[@]}"
  if [[ $MENU_RESULT -eq 0 ]]; then
    echo "已放弃"
    exit 0
  fi
  SELECTED_SOURCE_DIR="${SOURCE_DIRS[$((MENU_RESULT-1))]}"
fi

SKILL_NAME="$(basename "$SELECTED_SOURCE_DIR")"

# ─── Step 1: 查找目标目录（项目级 & 用户级）───
echo "📂 选中的 Skill 目录: $SELECTED_SOURCE_DIR ($SKILL_NAME)"
echo ""

PROJECT_TARGETS=()
search_dir="$SELECTED_SOURCE_DIR"

for level in 0 1 2 3; do
  for config_dir in ".claude" ".micode" ".cursor" ".opencode"; do
    candidate="$search_dir/$config_dir"
    if [[ -d "$candidate" ]]; then
      PROJECT_TARGETS+=("$candidate/skills")
    fi
  done
  parent="$(dirname "$search_dir")"
  [[ "$parent" == "$search_dir" ]] && break
  search_dir="$parent"
done
# 去重
PROJECT_TARGETS=($(printf "%s\n" "${PROJECT_TARGETS[@]}" | sort -u))

USER_TARGETS=()
for config_dir in ".claude" ".micode" ".cursor"; do
  if [[ -d "$HOME/$config_dir" ]]; then
    USER_TARGETS+=("$HOME/$config_dir/skills")
  fi
done
# OpenCode 用户级目录特殊处理: ~/.config/opencode
if [[ -d "$HOME/.config/opencode" ]]; then
  USER_TARGETS+=("$HOME/.config/opencode/skills")
fi
# 去重
USER_TARGETS=($(printf "%s\n" "${USER_TARGETS[@]}" | sort -u))

if [[ ${#PROJECT_TARGETS[@]} -eq 0 && ${#USER_TARGETS[@]} -eq 0 ]]; then
  echo "⚠️  未在项目级（上级 3 层）和用户级（~/）找到任何 .claude、.micode、.cursor 或 .opencode 目录，退出"
  exit 1
fi

# 构建带状态的目标标签
ALL_TARGETS=()
TARGET_LABELS=()

for target in "${PROJECT_TARGETS[@]}"; do
  ALL_TARGETS+=("$target")
  if [[ -d "$target" ]]; then
    TARGET_LABELS+=("[项目级] $target  (已有 skills/)")
  else
    TARGET_LABELS+=("[项目级] $target  (将自动创建 skills/)")
  fi
done

for target in "${USER_TARGETS[@]}"; do
  ALL_TARGETS+=("$target")
  if [[ -d "$target" ]]; then
    TARGET_LABELS+=("[用户级] $target  (已有 skills/)")
  else
    TARGET_LABELS+=("[用户级] $target  (将自动创建 skills/)")
  fi
done

# 添加自定义选项
ALL_TARGETS+=("CUSTOM")
TARGET_LABELS+=("✏️  自定义目录...")

menu_multi "🔍 请选择要链接到的目标目录:" "${TARGET_LABELS[@]}"

if [[ $MENU_RESULT -eq 0 || ${#MENU_RESULTS[@]} -eq 0 ]]; then
  echo "已放弃"
  exit 0
fi

SELECTED_DIRS=()
HAS_CUSTOM=0
for idx in "${MENU_RESULTS[@]}"; do
  if [[ "${ALL_TARGETS[$((idx-1))]}" == "CUSTOM" ]]; then
    HAS_CUSTOM=1
  else
    SELECTED_DIRS+=("${ALL_TARGETS[$((idx-1))]}")
  fi
done

if [[ $HAS_CUSTOM -eq 1 ]]; then
  echo ""
  printf "✏️  请输入自定义目录路径 (例如 ~/.my-ai/skills): "
  read -r custom_path
  if [[ -n "$custom_path" ]]; then
    # 处理 ~ 展开
    custom_path="${custom_path/#\~/$HOME}"
    # 处理相对路径转绝对路径
    if [[ "$custom_path" != /* ]]; then
      custom_path="$PWD/$custom_path"
    fi
    SELECTED_DIRS+=("$custom_path")
  else
    echo "⚠️  未输入路径，跳过自定义目录。"
  fi
fi

if [[ ${#SELECTED_DIRS[@]} -eq 0 ]]; then
  echo "未选择任何有效目录，已放弃"
  exit 0
fi

# ─── Step 2: 确认操作 ───
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "即将执行以下软链接操作:"
echo ""
for dir in "${SELECTED_DIRS[@]}"; do
  dst="$dir/$SKILL_NAME"
  if [[ -L "$dst" ]]; then
    echo "  [跳过-已存在] $dst -> $(readlink "$dst")"
  elif [[ -e "$dst" ]]; then
    echo "  [跳过-同名]   $dst (非软链接，已存在同名目录/文件)"
  else
    echo "  [新建] $dst -> $SELECTED_SOURCE_DIR"
  fi
done
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

menu_confirm ""

if [[ $MENU_RESULT -eq 0 ]]; then
  echo "已放弃"
  exit 0
fi

# ─── Step 3: 执行链接 ───
created=0
skipped=0
for dir in "${SELECTED_DIRS[@]}"; do
  dst="$dir/$SKILL_NAME"
  if [[ -L "$dst" ]]; then
    echo "  跳过 (已存在软链接): $dst"
    ((skipped++))
  elif [[ -e "$dst" ]]; then
    echo "  跳过 (同名目录/文件): $dst"
    ((skipped++))
  else
    [[ ! -d "$dir" ]] && mkdir -p "$dir"
    ln -s "$SELECTED_SOURCE_DIR" "$dst"
    echo "  已链接: $dst -> $SELECTED_SOURCE_DIR"
    ((created++))
  fi
done

echo ""
echo "完成! 新建 $created 个软链接，跳过 $skipped 个"