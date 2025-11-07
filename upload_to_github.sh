#!/bin/bash

# === Auto GitHub Upload Script ===
# Author: daehyeon0311
# Description: 자동으로 수정된 파일을 커밋하고 GitHub에 업로드

# Git 저장소 경로 (예: /mnt/AutoRsync)
REPO_PATH="/mnt/AutoRsync"

# 커밋 메시지에 현재 날짜/시간 추가
COMMIT_MSG="Auto update on $(date '+%Y-%m-%d %H:%M:%S')"

# 저장소 경로로 이동
cd "$REPO_PATH" || { echo "❌ 경로를 찾을 수 없습니다: $REPO_PATH"; exit 1; }

# 변경된 파일 확인
CHANGES=$(git status --porcelain)

if [ -z "$CHANGES" ]; then
    echo "✅ 변경된 파일 없음 — 업로드 생략"
    exit 0
fi

# 변경된 파일 스테이징
git add .

# 커밋 생성
git commit -m "$COMMIT_MSG"

# 원격 저장소로 push
git push origin main

echo "🚀 GitHub 업로드 완료!"

