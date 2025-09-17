#!/bin/bash

# IronDex 개발 환경 자동 설정 스크립트
#
# 사용법: chmod +x setup.sh && ./setup.sh

set -e  # 에러 발생 시 스크립트 중단

echo "🏋️‍♂️ IronDex 개발 환경 설정 시작..."

# 1. Python 가상환경 생성
echo "📦 Python 가상환경 생성 중..."
if [ ! -d ".venv" ]; then
    # Python 3.11 사용 (Union 연산자 | 지원)
    python3.11 -m venv .venv
    echo "✅ 가상환경 생성 완료 (Python 3.11)"
else
    echo "⚠️  가상환경이 이미 존재합니다"
fi

# 2. 가상환경 활성화
echo "🔧 가상환경 활성화 중..."
source .venv/bin/activate

# 3. pip 업그레이드
echo "⬆️  pip 업그레이드 중..."
pip install --upgrade pip

# 4. data_setup 의존성 설치
if [ -f "scripts/data_setup/requirements.txt" ]; then
    echo "📥 Python 의존성 설치 중..."
    pip install -r scripts/data_setup/requirements.txt
    echo "✅ Python 의존성 설치 완료"
else
    echo "⚠️  requirements.txt 파일을 찾을 수 없습니다"
fi

# 5. Flutter 의존성 설치
echo "🐦 Flutter 의존성 설치 중..."
flutter pub get

# 6. direnv 설정 (설치되어 있는 경우)
if command -v direnv &> /dev/null; then
    echo "🔄 direnv 설정 중..."
    direnv allow
    echo "✅ direnv 설정 완료"
else
    echo "ℹ️  direnv가 설치되어 있지 않습니다. 수동으로 .venv를 활성화하세요:"
    echo "   source .venv/bin/activate"
fi

# 7. 환경 변수 파일 확인
if [ ! -f ".env" ]; then
    echo "⚠️  .env 파일이 없습니다. 다음 내용으로 생성하세요:"
    echo "   SUPABASE_URL=your_supabase_url"
    echo "   SUPABASE_API_KEY=your_supabase_anon_key"
fi

echo ""
echo "🎉 설정 완료!"
echo ""
echo "다음 단계:"
echo "1. .env 파일에 Supabase 키 설정"
echo "2. 'flutter run'으로 앱 실행"
echo "3. Python 스크립트 실행 시: 'source .venv/bin/activate'"
echo ""
