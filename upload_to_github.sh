#!/bin/bash
# ==========================================================================
#   🚀 Auto GitHub Upload Script (Universal version)
#   Author  : daehyeon0311
#   Purpose : 자동으로 변경 사항을 감지하고 GitHub에 업로드 (경로 자동 인식)
# ==========================================================================

# ===== 자동 저장소/브랜치 인식 =====
REPO_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"     # 스크립트가 위치한 폴더
BRANCH=$(git -C "$REPO_PATH" rev-parse --abbrev-ref HEAD 2>/dev/null)

# ===== 색상 정의 =====
C_RESET="\033[0m"
C_CYAN="\033[1;36m"
C_YELLOW="\033[1;33m"
C_GREEN="\033[1;32m"
C_RED="\033[1;31m"
C_WHITE="\033[1;37m"

# ===== 헤더/푸터 =====
print_header() {
    echo -e "${C_CYAN}"
    echo "╔═══════════════════════════════════════════════════════════════════════╗"
    echo "║                 🚀  Auto GitHub Uploader  (daehyeon0311)              ║"
    echo "╚═══════════════════════════════════════════════════════════════════════╝"
    echo -e "${C_RESET}"
}

print_footer() {
    echo -e "${C_CYAN}"
    echo "╔═══════════════════════════════════════════════════════════════════════╗"
    echo "║                    ✅  Upload completed successfully.                  ║"
    echo "╚═══════════════════════════════════════════════════════════════════════╝"
    echo -e "${C_RESET}"
}

# ===== 실행 시작 =====
print_header

# 저장소 유효성 검사
if [ ! -d "$REPO_PATH/.git" ]; then
    echo -e "${C_RED}❌ Git repository not found in: ${REPO_PATH}${C_RESET}"
    exit 1
fi

cd "$REPO_PATH" || exit 1

# 변경사항 확인
CHANGES=$(git status --porcelain)
if [ -z "$CHANGES" ]; then
    echo -e "${C_GREEN}✅ No changes detected — nothing to upload.${C_RESET}"
    print_footer
    exit 0
fi

# 커밋 메시지 자동 생성
COMMIT_MSG="Auto update on $(date '+%Y-%m-%d %H:%M:%S')"

# 변경사항 표시
echo -e "${C_YELLOW}⚙️  Detected changes:${C_RESET}"
git status -s
echo

# 커밋 및 푸시
git add .
git commit -m "$COMMIT_MSG"

echo -e "${C_CYAN}📤  Pushing to GitHub (${BRANCH:-main} branch)...${C_RESET}"
if git push origin "${BRANCH:-main}"; then
    print_footer
else
    echo -e "${C_RED}❌ Push failed. Check network or credentials.${C_RESET}"
fi

