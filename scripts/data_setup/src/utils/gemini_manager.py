import google.generativeai as genai
from datetime import timedelta

from config.gemini import GENAI_API_KEY

class GeminiManager:
    """
    Gemini API와의 상호작용을 관리하고 컨텍스트 캐싱 기능을 제공하는 클래스.
    """
    def __init__(self, model_name: str = "gemini-2.5-flash"):
        """
        GeminiManager를 초기화합니다.

        Args:
            model_name: 사용할 Gemini 모델의 이름.
        """
        self.model_name = model_name
        self.cache = None
        self.cached_count = 0
        genai.configure(api_key=GENAI_API_KEY)
        self.model = genai.GenerativeModel(
            model_name=model_name,
            system_instruction="You are a friendly and helpful assistant.",
        )

    def update_model_with_context(self, instruction: str, context: str, ttl_seconds: int = 3600):

        self.clear_cache()

        self.cache = genai.caching.CachedContent.create(
            model=f"models/{self.model_name}-{self.cached_count}",
            display_name="내_첫번째_캐시", # 캐시를 식별하기 위한 이름
            system_instruction=instruction,
            contents=[context],
            ttl=timedelta(seconds=ttl_seconds)
        )
        self.cached_count += 1

        self.model = genai.GenerativeModel.from_cached_content(cached_content=self.cache)

    def generate_content(self, prompt: str) -> str:
        response = self.model.generate_content(prompt)
        return str(response.text)

    def clear_cache(self):
        """
        현재 인스턴스에 저장된 캐시를 삭제합니다.
        """
        if self.cache:
            try:
                print(f"캐시({self.cache.name})를 삭제합니다.")
                self.cache.delete()
                self.cache = None
                print("캐시가 성공적으로 삭제되었습니다.")
            except Exception as e:
                print(f"캐시 삭제 중 오류 발생: {e}")
        else:
            print("삭제할 캐시가 없습니다.")

    def __del__(self):
        """
        객체 소멸 시 캐시를 정리합니다.
        """
        self.clear_cache()



# --- 이 파일을 직접 실행할 경우의 예시 코드 ---
if __name__ == '__main__':
    # 1. GeminiManager 인스턴스 생성
    manager = GeminiManager()

    # 2. 캐시할 컨텍스트 준비
    brand_context = "안녕하세요 "

    # 3. 컨텍스트로 캐시 생성
    print(manager.generate_content(brand_context))