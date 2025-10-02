from PIL import Image, ImageChops
import requests
import io

class ImageProcessor:
    """
    이미지 로드, 자동 크롭, 리사이징 등 다양한 이미지 전처리 기능을 제공하는 클래스.
    """
    def load_image(self, image_source: str) -> Image.Image:
        """URL 또는 로컬 경로에서 이미지를 로드합니다."""
        if image_source.startswith("http://") or image_source.startswith("https://"):
            response = requests.get(image_source)
            response.raise_for_status()
            img = Image.open(io.BytesIO(response.content))
        else:
            img = Image.open(image_source)
        return img

    def autocrop(self, img: Image.Image, background_color=(255, 255, 255), tolerance=10) -> Image.Image:
        """단색 또는 투명 배경의 여백을 자동으로 잘라냅니다."""
        bbox = None

        if 'A' in img.getbands():
            bbox = img.getbbox()
            if bbox:
                print("알파 채널을 기준으로 자동 크롭합니다.")

        if not bbox:
            img_rgb = img.convert('RGB')
            bg = Image.new('RGB', img_rgb.size, background_color)
            diff = ImageChops.difference(img_rgb, bg)
            gray_diff = diff.convert('L')
            lut = [255 if i > tolerance else 0 for i in range(256)]
            mask = gray_diff.point(lut)
            bbox = mask.getbbox()
            if bbox:
                print(f"RGB 배경색({background_color}, 허용오차 {tolerance})을 기준으로 자동 크롭합니다.")

        if bbox:
            print(f"이미지 자동 크롭: {img.size} -> {bbox[2]-bbox[0]}x{bbox[3]-bbox[1]}")
            return img.crop(bbox)
        else:
            print("자동 크롭할 여백을 찾을 수 없습니다. 원본 이미지를 반환합니다.")
            return img

    def resize_and_pad(self, img: Image.Image, target_size: tuple[int, int], background_color=(0, 0, 0)) -> Image.Image:
        """이미지를 레터박스 방식으로 리사이즈합니다."""
        resized_img = img.copy()
        resized_img.thumbnail(target_size, Image.Resampling.LANCZOS)

        if 'A' in img.getbands():
            background = Image.new('RGBA', target_size, background_color + (255,))
        else:
            background = Image.new('RGB', target_size, background_color)

        paste_x = (target_size[0] - resized_img.width) // 2
        paste_y = (target_size[1] - resized_img.height) // 2

        if 'A' in resized_img.getbands():
            background.paste(resized_img, (paste_x, paste_y), resized_img)
        else:
            background.paste(resized_img, (paste_x, paste_y))

        return background

# --- 이 파일을 직접 실행할 경우의 예시 코드 ---
if __name__ == '__main__':
    # 1. ImageProcessor 인스턴스 생성
    processor = ImageProcessor()

    # 2. 테스트할 이미지 URL 정의 (흰색 배경의 이미지)
    # 다른 이미지를 테스트하고 싶다면 이 URL을 변경하세요.
    image_url = "https://xbhmosiuaadpwiezqbfk.supabase.co/storage/v1/object/public/machine_images/092e915a-c988-4cde-a14f-44f58a0b6c57.jpg"

    try:
        # 3. 이미지 로드
        print(f"이미지 로딩: {image_url}")
        original_image = processor.load_image(image_url)
        # 원본 이미지를 보고 싶다면 아래 줄의 주석을 해제하세요.
        # original_image.show(title="Original Image")

        # 4. 자동 크롭 실행 (흰색 배경에 대해 허용오차 20으로 설정)
        print("이미지 자동 크롭 실행...")
        cropped_image = processor.autocrop(original_image, background_color=(255, 255, 255), tolerance=20)
        # 크롭된 이미지를 보고 싶다면 아래 줄의 주석을 해제하세요.
        # cropped_image.show(title="Cropped Image")

        # 5. 리사이즈 및 패딩 실행
        target_size = (384, 384)
        print(f"{target_size} 크기로 리사이즈 실행...")
        final_image = processor.resize_and_pad(cropped_image, target_size=target_size)

        # 6. 최종 처리된 이미지 보여주기
        print("최종 결과 이미지를 화면에 표시합니다.")
        final_image.show(title="Final Processed Image")

    except FileNotFoundError:
        print(f"오류: 이미지 파일을 찾을 수 없습니다. ({image_url})")
    except Exception as e:
        print(f"이미지 처리 중 오류가 발생했습니다: {e}")