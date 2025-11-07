#!/bin/bash

dirMain="ue_251105_FXL"   ### !!! MUST check !!!
serverPath="admin@10.4.130.121:/volume1/homes"       ### SdNAS[6]

trap 'echo -e "\n\033[1;31m[ABORTED] User stopped the script.\033[0m"; exit 0' INT

# ==================== 모드 선택 ====================
echo -e "\n\033[1;36m==========================================================================\033[0m"
echo -e "\033[1;36m                   🚀  Select rsync mode (PAL-XFEL)  🚀                 \033[0m"
echo -e "\033[1;36m==========================================================================\033[0m"
echo
echo -e "  \033[1;33m1.\033[0m all          →  \033[37m전체 /xfel/ffs/dat/$dirMain\033[0m"
echo -e "  \033[1;33m2.\033[0m scan         →  \033[37m/xfel/ffs/dat/scan/25110*\033[0m"
echo -e "  \033[1;33m3.\033[0m scratch      →  \033[37m/xfel/ffs/dat/$dirMain/scratch\033[0m"
echo -e "  \033[1;33m4.\033[0m resultTRXL   →  \033[37m/xfel/ffs/dat/$dirMain/scratch/resultTRXL\033[0m"
echo -e "  \033[1;33m5.\033[0m NAStoPALXFEL →  \033[37mNAS codes → /xfel/ffs/dat/$dirMain/scratch\033[0m"
echo
read -p "➡  Enter number (1-5): " choice


case $choice in
  1) mode="all" ;;
  2) mode="scan" ;;
  3) mode="scratch" ;;
  4) mode="resultTRXL" ;;
  5) mode="NAStoPALXFEL" ;;
  *) echo "❌ Invalid choice. Exiting."; exit 1 ;;
esac

echo
echo "✅ Selected mode: $mode"
echo

# ==================== HEADER 출력 함수 ====================
print_header() {
    echo -e "\033[1;36m"
    echo "=========================================================================="
    echo "-------------------- AutoRSYNC PAL-XFEL beamline -------------------------"
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

# ==================== 메인 루프 ====================
print_header

while :
do
    if [ "$mode" = "all" ]; then
        fcnROI="rsync -rltuvhP /xfel/ffs/dat/$dirMain $serverPath"

    elif [ "$mode" = "scan" ]; then
        fcnROI="rsync -rltuvhP /xfel/ffs/dat/scan/25110* $serverPath/$dirMain/scan"

    elif [ "$mode" = "scratch" ]; then
        fcnROI="rsync -rltuvhP /xfel/ffs/dat/$dirMain/scratch $serverPath/$dirMain"

    elif [ "$mode" = "resultTRXL" ]; then
        fcnROI="rsync -rltuvhP /xfel/ffs/dat/$dirMain/scratch/resultTRXL $serverPath/$dirMain/scratch"

    elif [ "$mode" = "NAStoPALXFEL" ]; then
        fcnROI="rsync -rltuvhP $serverPath/$dirMain/scratch/codes /xfel/ffs/dat/$dirMain/scratch"
    fi

    echo
    echo -e "\033[1;33mmode : $mode\033[0m"
    echo -e "\033[1;32m$fcnROI\033[0m"
    echo

    $fcnROI

    print_footer
    sleep 3s
done
