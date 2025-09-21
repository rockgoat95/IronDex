#!/bin/bash

# IronDex Python 데이터 처리 환경 설정 스크립트
#
# 이 스크립트는 프로젝트 루트 디렉토리에서 실행하는 것을 권장합니다.
# 사용법: bash scripts/data_setup/setup_python.sh

set -e  # 에러 발생 시 스크립트 중단

# 스크립트 파일의 실제 위치를 기준으로 프로젝트 루트 경로를 계산합니다.
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
PROJECT_ROOT=$(cd -- "$SCRIPT_DIR/../.." &> /dev/null && pwd)

echo "🏋️‍♂️ IronDex Python 데이터 처리 환경 설정 시작..."
echo "📂 프로젝트 루트: $PROJECT_ROOT"

# 1. Python 가상환경 생성 (루트 디렉토리에)
VENV_DIR="$PROJECT_ROOT/.venv"
echo "📦 Python 가상환경 생성 중..."
if [ ! -d "$VENV_DIR" ]; then
    # Python 3.11 사용 (Union 연산자 | 지원)
    python3.11 -m venv "$VENV_DIR"
    echo "✅ 가상환경 생성 완료 (Python 3.11)"
else
    echo "⚠️  가상환경이 이미 존재합니다"
fi

# 가상환경의 pip 실행 파일을 직접 사용합니다.
PIP_EXEC="$VENV_DIR/bin/pip"

# 2. pip 업그레이드
echo "⬆️  pip 업그레이드 중..."
"$PIP_EXEC" install --upgrade pip

# 3. data_setup 의존성 설치
REQUIREMENTS_PATH="$PROJECT_ROOT/scripts/data_setup/requirements.txt"
if [ -f "$REQUIREMENTS_PATH" ]; then
    echo "📥 Python 의존성 설치 중..."
    "$PIP_EXEC" install -r "$REQUIREMENTS_PATH"
    echo "✅ Python 의존성 설치 완료"
else
    echo "⚠️  $REQUIREMENTS_PATH 파일을 찾을 수 없습니다"
fi

# 4. direnv 설정 (설치되어 있는 경우)
if command -v direnv &> /dev/null; then
    echo "🔄 direnv 설정 중..."    
    cd "$PROJECT_ROOT"

    # .envrc 파일이 없으면 생성합니다.
    ENVRC_PATH="$PROJECT_ROOT/.envrc"
    if [ ! -f "$ENVRC_PATH" ]; then
        echo "source .venv/bin/activate" > "$ENVRC_PATH"
        echo "✅ .envrc 파일 생성 완료"
    fi

    direnv allow
    echo "✅ direnv 설정 완료"
else
    echo "ℹ️  direnv가 설치되어 있지 않습니다. 수동으로 .venv를 활성화하세요:"
    echo "   source .venv/bin/activate"
fi
