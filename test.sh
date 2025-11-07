#!/bin/bash
# ==========================================================================
# 🚀 AutoRsync Local Test Version (Continuous Loop)
# Author : daehyeon0311
# Purpose: Continuous rsync loop for local testing
# ==========================================================================

# ==================== 사용자 설정 ====================
dirMain="ue_251105_FXL"   # !!! 테스트용 폴더 이름 !!!
serverPath="./backup"     # 현재 폴더 내 backup 디렉토리

trap 'echo -e "\n\033[1;31m🚫 [ABORTED] User stopped the script.\033[0m"; exit 0' INT

# ==================== 색상 정의 ====================
C_RESET="\033[0m"
C_CYAN="\033[1;36m"
C_YELLOW="\033[1;33m"
C_GREEN="\033[1;32m"
C_RED="\033[1;31m"
C_WHITE="\033[37m"

# ==================== 출력 함수 ====================
print_header() {
    echo -e "${C_CYAN}"
    echo "╔═══════════════════════════════════════════════════════════════════════╗"
    echo "║                 🚀 AutoRSYNC | Local Test Version                      ║"
    echo "╚═══════════════════════════════════════════════════════════════════════╝"
    echo -e "${C_RESET}"
    echo -e "  ${C_YELLOW}dirMain     :${C_WHITE} $dirMain${C_RESET}"
    echo -e "  ${C_YELLOW}serverPath  :${C_WHITE} $serverPath${C_RESET}"
    echo
}

print_footer() {
    echo -e "${C_CYAN}"
    echo "╔═══════════════════════════════════════════════════════════════════════╗"
    echo "║ ✅  Rsync job finished. Sleeping 3s...                               ║"
    echo "╚═══════════════════════════════════════════════════════════════════════╝"
    echo -e "${C_RESET}"
}

# ==================== 모드 선택 ====================
print_header
echo -e "${C_CYAN}---------------------- Select rsync mode (Local Test) ----------------------${C_RESET}"
echo
echo -e "  ${C_YELLOW}1.${C_RESET} all          → ${C_WHITE}전체 ./data/${dirMain}${C_RESET}"
echo -e "  ${C_YELLOW}2.${C_RESET} scan         → ${C_WHITE}./data/scan/25110*${C_RESET}"
echo -e "  ${C_YELLOW}3.${C_RESET} scratch      → ${C_WHITE}./data/${dirMain}/scratch${C_RESET}"
echo -e "  ${C_YELLOW}4.${C_RESET} resultTRXL   → ${C_WHITE}./data/${dirMain}/scratch/resultTRXL${C_RESET}"
echo -e "  ${C_YELLOW}5.${C_RESET} reverseTest  → ${C_WHITE}backup → data (codes)${C_RESET}"
echo
read -p "➡  Enter number (1-5): " choice

case $choice in
  1) mode="all" ;;
  2) mode="scan" ;;
  3) mode="scratch" ;;
  4) mode="resultTRXL" ;;
  5) mode="reverseTest" ;;
  *) echo -e "${C_RED}❌ Invalid choice. Exiting.${C_RESET}"; exit 1 ;;
esac

echo -e "\n${C_GREEN}✅ Selected mode:${C_RESET} ${C_YELLOW}$mode${C_RESET}\n"

# ==================== 테스트용 폴더 생성 ====================
mkdir -p ./data/$dirMain/scratch/resultTRXL
mkdir -p $serverPath/$dirMain/scratch/codes

# ==================== 메인 루프 ====================
while true; do
    print_header

    case $mode in
        all)
            fcnROI="rsync -rltuvhP ./data/$dirMain $serverPath"
            ;;
        scan)
            mkdir -p ./data/scan
            fcnROI="rsync -rltuvhP ./data/scan/25110* $serverPath/$dirMain/scan"
            ;;
        scratch)
            fcnROI="rsync -rltuvhP ./data/$dirMain/scratch $serverPath/$dirMain"
            ;;
        resultTRXL)
            fcnROI="rsync -rltuvhP ./data/$dirMain/scratch/resultTRXL $serverPath/$dirMain/scratch"
            ;;
        reverseTest)
            mkdir -p ./data/$dirMain/scratch
            fcnROI="rsync -rltuvhP $serverPath/$dirMain/scratch/codes ./data/$dirMain/scratch"
            ;;
    esac

    echo -e "${C_YELLOW}▶  Executing:${C_RESET} ${C_WHITE}$fcnROI${C_RESET}\n"
    sleep 0.5

    $fcnROI
    STATUS=$?

    if [ $STATUS -eq 0 ]; then
        echo -e "\n${C_GREEN}✅ Rsync completed successfully.${C_RESET}"
    else
        echo -e "\n${C_RED}⚠️  Rsync encountered an error (exit code $STATUS).${C_RESET}"
        echo "$(date): Rsync failed (mode=$mode, exit=$STATUS)" >> ./rsync_error.log
    fi

    print_footer
    sleep 3
done

