#!/bin/bash
# ==========================================================================
# 🚀 AutoRsync Script (Enhanced version)
# Author : daehyeon0311
# Purpose: Rsync automation with clearer UI and safety prompts
# ==========================================================================

# ==================== 사용자 설정 ====================
dirMain="ue_251105_FXL"    # !!! MUST CHECK !!!
serverPath="admin@10.4.130.121:/volume1/homes"   # SdNAS[6]

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
    echo "║                  🚀 AutoRSYNC  |  PAL-XFEL Beamline Sync              ║"
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
echo -e "${C_CYAN}---------------------- Select rsync mode (PAL-XFEL) ----------------------${C_RESET}"
echo
echo -e "  ${C_YELLOW}1.${C_RESET} all          → ${C_WHITE}/xfel/ffs/dat/${dirMain}${C_RESET}"
echo -e "  ${C_YELLOW}2.${C_RESET} scan         → ${C_WHITE}/xfel/ffs/dat/scan/25110*${C_RESET}"
echo -e "  ${C_YELLOW}3.${C_RESET} scratch      → ${C_WHITE}/xfel/ffs/dat/${dirMain}/scratch${C_RESET}"
echo -e "  ${C_YELLOW}4.${C_RESET} resultTRXL   → ${C_WHITE}/xfel/ffs/dat/${dirMain}/scratch/resultTRXL${C_RESET}"
echo -e "  ${C_YELLOW}5.${C_RESET} NAStoPALXFEL → ${C_WHITE}NAS → /xfel/ffs/dat/${dirMain}/scratch${C_RESET}"
echo
read -p "➡  Enter number (1-5): " choice

case $choice in
  1) mode="all" ;;
  2) mode="scan" ;;
  3) mode="scratch" ;;
  4) mode="resultTRXL" ;;
  5) mode="NAStoPALXFEL" ;;
  *) echo -e "${C_RED}❌ Invalid choice. Exiting.${C_RESET}"; exit 1 ;;
esac

echo -e "\n${C_GREEN}✅ Selected mode:${C_RESET} ${C_YELLOW}$mode${C_RESET}\n"

# ==================== 메인 루프 ====================
while true; do
    print_header

    case $mode in
        all)
            fcnROI="rsync -rltuvhP /xfel/ffs/dat/$dirMain $serverPath"
            ;;
        scan)
            fcnROI="rsync -rltuvhP /xfel/ffs/dat/scan/25110* $serverPath/$dirMain/scan"
            ;;
        scratch)
            fcnROI="rsync -rltuvhP /xfel/ffs/dat/$dirMain/scratch $serverPath/$dirMain"
            ;;
        resultTRXL)
            fcnROI="rsync -rltuvhP /xfel/ffs/dat/$dirMain/scratch/resultTRXL $serverPath/$dirMain/scratch"
            ;;
        NAStoPALXFEL)
            fcnROI="rsync -rltuvhP $serverPath/$dirMain/scratch/codes /xfel/ffs/dat/$dirMain/scratch"
            ;;
    esac

    echo -e "${C_YELLOW}▶  Executing:${C_RESET} ${C_WHITE}$fcnROI${C_RESET}\n"
    sleep 0.5

    # 실제 rsync 실행
    $fcnROI
    STATUS=$?

    if [ $STATUS -eq 0 ]; then
        echo -e "\n${C_GREEN}✅ Rsync completed successfully.${C_RESET}"
    else
        echo -e "\n${C_RED}⚠️  Rsync encountered an error (exit code $STATUS).${C_RESET}"
        echo "$(date): Rsync failed (mode=$mode, exit=$STATUS)" >> ~/rsync_error.log
    fi

    print_footer
    echo
    read -p "🔁 Run again? (y/n): " again
    [[ "$again" =~ ^[Yy]$ ]] || break
done

echo -e "${C_GREEN}🏁 Script terminated.${C_RESET}\n"

