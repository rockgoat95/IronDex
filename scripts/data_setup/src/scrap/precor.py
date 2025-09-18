import logging
import time

from bs4 import Tag

from utils.base_scraper import BaseScraper
from utils.model import ScraperConfig

logger = logging.getLogger(__name__)

PrecorScraperConfig = ScraperConfig(
    brand_name="Precor",
    item_selector="div.slideHorizontal___1NzNV",
    name_selector="h2",
    image_selector="img",
)


class PrecorScraper(BaseScraper):
    def __init__(self, machine_series: str):
        super().__init__(PrecorScraperConfig, use_selenium=False)
        self.machine_series = machine_series

    def extract_additional_info(self, item: Tag):
        code_elem = item.select("div.comparisonToolCard-content-description")[0]
        code = code_elem.get_text(strip=True).replace('"', "").strip()
        return {"code": code}

    def extract_image_url(self, item: Tag) -> str:

        image_elem = item.select_one(self.image_selector)
        if image_elem is None:
            raise ValueError(
                f"Image element not found with selector: {self.image_selector}"
            )
        img_url = image_elem.attrs.get("src", "")
        return str(img_url)

    def handle_browser_action(self) -> None:
        time.sleep(3)  # 페이지 로딩 대기


if __name__ == "__main__":
    scraper = PrecorScraper("Selectorized")
    urls = ["https://www.precor.com/strength/selectorized/resolute"]
    items = scraper.scrap(urls)
    for item in items:
        print(f"- {item.name}")
