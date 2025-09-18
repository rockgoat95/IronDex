import logging
import re

from bs4 import Tag

from utils.base_scraper import BaseScraper
from utils.model import ScraperConfig

logger = logging.getLogger(__name__)

PrimeScraperConfig = ScraperConfig(
    brand_name="Prime Fitness",
    item_selector=("div[data-product-thumbnail]"),
    name_selector="a.product-thumbnail__title",
    image_selector="div.product-thumbnail__image",
)


class PrimeScraper(BaseScraper):
    def __init__(self, machine_series: str):
        super().__init__(PrimeScraperConfig)
        self.machine_series = machine_series

    def extract_name(self, item: Tag) -> str:
        name_elem = item.select_one(self.name_selector)
        if name_elem is None:
            raise ValueError(
                f"Name element not found with selector: {self.name_selector}"
            )

        name = name_elem.get_text(strip=True)

        name = name.split("|")[-1].strip()  # ' - ' 이후의 부분 제거
        return name

    def extract_image_url(self, item: Tag) -> str:
        """noscript 태그 내의 img에서 440x440 이미지 URL 추출"""
        # noscript 태그 찾기
        noscript = item.find("noscript")
        if not noscript:
            return ""

        # noscript 내의 img 태그 파싱
        img_html = str(noscript)
        img_match = re.search(r'<img[^>]*srcset="([^"]*)"[^>]*>', img_html)
        if img_match:
            srcset = img_match.group(1)
            # 440x440 이미지 URL 찾기
            pattern = r"(//[^\s]+440x440[^\s]*)\s+2x"
            match = re.search(pattern, srcset)
            if match:
                return "https:" + match.group(1)
        return ""


if __name__ == "__main__":
    scraper = PrimeScraper("Evolution")
    urls = ["https://www.primefitnessusa.com/collections/evolution"]
    items = scraper.scrap(urls)
    for item in items:
        print(f"- {item.name}")
