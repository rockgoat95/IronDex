import logging
import re

from bs4 import Tag

from utils.base_scraper import BaseScraper
from utils.model import ScraperConfig

logger = logging.getLogger(__name__)

HammerStrengthScraperConfig = ScraperConfig(
    brand_name="Hammer Strength",
    item_selector="a.product-grid--item",
    name_selector="span.product-grid--item-name",
    image_selector="div.product-grid--item-image"
)


class HammerStrengthScraper(BaseScraper):
    def __init__(self):
        super().__init__(
            HammerStrengthScraperConfig,
            contain_series=False,
            use_selenium=True
        )
        self.machine_series = ""

    def extract_image_url(self, item: Tag) -> str:
        """div 태그의 background-image 스타일에서 이미지 URL 추출"""
        image_elem = item.select_one(self.image_selector)
        if not image_elem:
            return ""

        # style 속성에서 background-image URL 추출
        style = image_elem.get('style', '')
        if style:
            pattern = r'background-image:\s*url\("(.+?)"\)'
            match = re.search(pattern, style)  # type: ignore
            if match:
                return match.group(1)

        return ""

    def handle_browser_action(self):
        if not self.driver:
            raise RuntimeError("Selenium WebDriver가 초기화되지 않았습니다")
        import time

        time.sleep(10)


if __name__ == "__main__":
    scraper = HammerStrengthScraper()
    urls = [
        "https://www.lifefitness.com/en-us/catalog?Brand=1053&Type=1079"
        f"&pageNumber={i}#searchform"
        for i in range(1, 2)
    ]
    items = scraper.scrap(urls)
    for item in items:
        print(f"- {item.name}")
        print(f"- {item.image_url}")
