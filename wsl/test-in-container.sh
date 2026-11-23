#!/usr/bin/env bash
#
# 깨끗한 Ubuntu 컨테이너에서 wsl/install.sh 검증 (CI, 로컬 공용)
#
#   docker run --rm -v "$PWD:/home/dev/.dotfiles:ro" ubuntu:24.04 \
#       bash /home/dev/.dotfiles/wsl/test-in-container.sh [profile]
#
# root로 실행 → sudo 가능한 일반 사용자 생성 → install.sh 2회(재실행 안전성) → 대화형 셸에서 도구 확인

set -euo pipefail

SELF="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
PROFILE="${1:-ci}"

# 사용자 셸 안에서 실행되는 검증 단계
if [[ "$PROFILE" == "--verify" ]]; then
    fail=0
    for t in git git-lfs gh sdk uv node npm act; do
        if type "$t" >/dev/null 2>&1; then echo "ok       $t"; else echo "MISSING  $t"; fail=1; fi
    done
    [[ "$(git config --global --get core.fsmonitor)" == "false" ]] || { echo "MISSING  wsl/.gitconfig override"; fail=1; }
    [[ "$(grep -c 'dotfiles/wsl/.bashrc' ~/.bashrc)" == "1" ]] || { echo "\$HOME/.bashrc의 source 줄이 1개가 아님"; fail=1; }
    exit "$fail"
fi

apt-get update -qq
DEBIAN_FRONTEND=noninteractive apt-get install -y -qq sudo >/dev/null

id dev >/dev/null 2>&1 || useradd -s /bin/bash dev
chown dev: /home/dev
echo "dev ALL=(ALL) NOPASSWD:ALL" >/etc/sudoers.d/dev
cp /etc/skel/.bashrc /etc/skel/.profile /home/dev/
chown dev: /home/dev/.bashrc /home/dev/.profile

echo "::group::install.sh $PROFILE (1회)"
su - dev -c "\$HOME/.dotfiles/wsl/install.sh $PROFILE"
echo "::endgroup::"

echo "::group::install.sh $PROFILE (2회, 재실행)"
su - dev -c "\$HOME/.dotfiles/wsl/install.sh $PROFILE"
echo "::endgroup::"

echo "== verify"
su - dev -c "bash -ic '. \"$SELF\" --verify'" 2>/dev/null
