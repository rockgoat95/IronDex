import logging
import re

from bs4 import Tag

from utils.base_scraper import BaseScraper
from utils.model import ScraperConfig

logger = logging.getLogger(__name__)

Gym80ScraperConfig = ScraperConfig(
    brand_name="Gym80",
    item_selector="div.collection-item.w-dyn-item",
    name_selector="h2.product_name.text_white",
    image_selector="div.product_image"
)


class Gym80Scraper(BaseScraper):
    def __init__(self, machine_series: str, type_: str = "Selectorized"):
        super().__init__(Gym80ScraperConfig)
        self.machine_series = machine_series
        self.type_ = type_

    def extract_image_url(self, item: Tag) -> str:

        bg_elem = item.select_one(self.image_selector)
        style = bg_elem.attrs.get("style", "") if bg_elem else ""

        # background-image:url("...") 패턴 추출
        bg_match = re.search(
            r'background-image:\s*url\(["\']?([^"\']+)["\']?\)',
            str(style)
        )  # type: ignore
        if bg_match:
            return bg_match.group(1)
        else:
            raise ValueError("이미지 URL을 스타일에서 추출할 수 없습니다")

    def extract_additional_info(self, item: Tag) -> dict:
        return {"type": self.type_}

if __name__ == "__main__":
    scraper = Gym80Scraper("Sygnum")
    urls = [
        "https://www.gym80.co.uk/product-ranges/sygnum"
    ]
    items = scraper.scrap(urls)
    for item in items:
        print(f"- {item.name}")
