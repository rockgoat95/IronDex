import google.generativeai as genai
from datetime import timedelta
import requests
from typing import Optional

from utils.image_processor import ImageProcessor
from config.gemini import GENAI_API_KEY


class GeminiManager:
    """
    Gemini API와의 상호작용을 관리하고 컨텍스트 캐싱 기능을 제공하는 클래스.
    """
    def __init__(self, model_name: str = "gemini-1.5-flash"):
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
        self.image_processor = ImageProcessor()

    def update_model_with_context(self, instruction: str, context: str, ttl_seconds: int = 3600):
        self.clear_cache()

        self.cache = genai.caching.CachedContent.create(
            model=f"models/{self.model_name}",
            display_name=f"cache-for-{self.model_name}-{self.cached_count}",
            system_instruction=instruction,
            contents=[context],
            ttl=timedelta(seconds=ttl_seconds),
        )
        self.cached_count += 1

        self.model = genai.GenerativeModel.from_cached_content(cached_content=self.cache)

    def generate_content(self, prompt: str) -> str:
        response = self.model.generate_content(prompt)
        return str(response.text)

    def generate_content_with_image(
        self,
        prompt: str,
        image_source: str,
        autocrop: bool = True,
        autocrop_bg_color: tuple = (255, 255, 255),
        autocrop_tolerance: int = 10,
        resize_target: Optional[tuple[int, int]] = (384, 384),
    ) -> str:
        """
        이미지(로컬/URL)와 텍스트를 받아 콘텐츠를 생성합니다.
        ImageProcessor를 사용하여 자동 크롭 및 리사이징을 수행합니다.
        """
        try:
            # 1. ImageProcessor를 사용하여 이미지 불러오기
            img = self.image_processor.load_image(image_source)

            # 2. 자동 크롭 실행
            if autocrop:
                img = self.image_processor.autocrop(
                    img,
                    background_color=autocrop_bg_color,
                    tolerance=autocrop_tolerance,
                )

            # 3. 리사이징 옵션이 주어졌을 경우, 이미지 리사이즈 실행
            if resize_target:
                img = self.image_processor.resize_and_pad(img, target_size=resize_target)

            # 4. 모델 요구사항에 맞춰 RGB로 변환
            if img.mode != "RGB":
                img = img.convert("RGB")

            # 5. 모델에 최종 이미지와 프롬프트 전달
            # 참고: 캐시된 모델이 이미지 입력을 지원하지 않을 수 있으므로,
            # 이미지 처리 시에는 기본 모델을 직접 사용합니다.
            base_model = genai.GenerativeModel(self.model_name)
            response = base_model.generate_content([prompt, img])
            return response.text

        except FileNotFoundError:
            return f"오류: 로컬 이미지 파일({image_source})을 찾을 수 없습니다."
        except requests.exceptions.RequestException as e:
            return f"오류: URL({image_source})에서 이미지를 불러오는 데 실패했습니다. ({e})"
        except Exception as e:
            return f"이미지 처리 또는 콘텐츠 생성 중 오류가 발생했습니다: {e}"

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
if __name__ == "__main__":
    # 1. GeminiManager 인스턴스 생성
    manager = GeminiManager()

    # 2. 이미지와 함께 콘텐츠 생성 테스트
    # 예시: 로컬 이미지 파일 사용
    # response_text = manager.generate_content_with_image(
    #     prompt="이 이미지에 대해 설명해주세요.",
    #     image_source="path/to/your/image.jpg"
    # )
    # print(response_text)

    # 예시: URL 이미지 사용 및 리사이징 비활성화
    response_text_url = manager.generate_content_with_image(
        prompt="What is in this image?",
        image_source="https://storage.googleapis.com/generative-ai-downloads/images/scones.jpg",
        resize_target=None,
    )
    print(response_text_url)
