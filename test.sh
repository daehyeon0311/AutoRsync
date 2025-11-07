#!/bin/bash

dirMain="ue_251105_FXL"   ### !!! 테스트용 폴더 이름 !!!
serverPath="./backup"     ### 현재 폴더 안의 backup 디렉토리로 복사

trap 'echo -e "\n\033[1;31m[ABORTED] User stopped the script.\033[0m"; exit 0' INT



# ==================== 모드 선택 ====================
echo -e "\n\033[1;36m==========================================================================\033[0m"
echo -e "\033[1;36m                   🚀  Select rsync mode (Local Test)  🚀                 \033[0m"
echo -e "\033[1;36m==========================================================================\033[0m"
echo
echo -e "  \033[1;33m1.\033[0m all          →  \033[37m전체 ./data/$dirMain\033[0m"
echo -e "  \033[1;33m2.\033[0m scan         →  \033[37m./data/scan/25110*\033[0m"
echo -e "  \033[1;33m3.\033[0m scratch      →  \033[37m./data/$dirMain/scratch\033[0m"
echo -e "  \033[1;33m4.\033[0m resultTRXL   →  \033[37m./data/$dirMain/scratch/resultTRXL\033[0m"
echo -e "  \033[1;33m5.\033[0m reverseTest  →  \033[37mbackup → data (codes)\033[0m"
echo
read -p "➡  Enter number (1-5): " choice




case $choice in
  1) mode="all" ;;
  2) mode="scan" ;;
  3) mode="scratch" ;;
  4) mode="resultTRXL" ;;
  5) mode="reverseTest" ;;
  *) echo "❌ Invalid choice. Exiting."; exit 1 ;;
esac

echo
echo "✅ Selected mode: $mode"
echo

# ==================== HEADER 출력 함수 ====================
print_header() {
    echo -e "\033[1;36m"
    echo "=========================================================================="
    echo "-------------------- AutoRSYNC Local Test Version ------------------------"
    echo "=========================================================================="
    echo -e "\033[0m"
}

print_footer() {
    echo -e "\033[1;36m"
    echo "=========================================================================="
    echo "------------------------- Rsync Done. Sleep 3 s --------------------------"
    echo "=========================================================================="
    echo -e "\033[0m"
}

# ==================== 테스트용 폴더 생성 ====================
mkdir -p ./data/$dirMain/scratch/resultTRXL
mkdir -p $serverPath/$dirMain/scratch/codes

# ==================== 메인 루프 ====================
print_header

while :
do
    if [ "$mode" = "all" ]; then
        fcnROI="rsync -rltuvhP ./data/$dirMain $serverPath"

    elif [ "$mode" = "scan" ]; then
        mkdir -p ./data/scan
        fcnROI="rsync -rltuvhP ./data/scan/25110* $serverPath/$dirMain/scan"

    elif [ "$mode" = "scratch" ]; then
        fcnROI="rsync -rltuvhP ./data/$dirMain/scratch $serverPath/$dirMain"

    elif [ "$mode" = "resultTRXL" ]; then
        fcnROI="rsync -rltuvhP ./data/$dirMain/scratch/resultTRXL $serverPath/$dirMain/scratch"

    elif [ "$mode" = "reverseTest" ]; then
        mkdir -p ./data/$dirMain/scratch
        fcnROI="rsync -rltuvhP $serverPath/$dirMain/scratch/codes ./data/$dirMain/scratch"
    fi

    echo
    echo -e "\033[1;33mmode : $mode\033[0m"
    echo -e "\033[1;32m$fcnROI\033[0m"
    echo

    $fcnROI

    print_footer
    sleep 3s
done

