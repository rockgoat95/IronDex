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
    image_selector="img",
)


class PrimeScraper(BaseScraper):
    def __init__(self, machine_series: str, type_: str = "Selectorized"):
        super().__init__(PrimeScraperConfig, contain_series=False, use_selenium=True)
        self.machine_series = machine_series
        self.type_ = type_

    def extract_name(self, item: Tag) -> str:
        name_elem = item.select_one(self.name_selector)
        if name_elem is None:
            raise ValueError(
                f"Name element not found with selector: {self.name_selector}"
            )

        name = name_elem.get_text(strip=True)

        name = name.split("|")[-1].strip()  # ' - ' 이후의 부분 제거
        return name

    def extract_additional_info(self, item: Tag) -> dict:
        price_elem = item.select_one("span.money")
        if price_elem is not None:
            price = price_elem.get_text(strip=True)
            return {"price": price, "type": self.type_}
        return {"price": "Contact for Price", "type": self.type_}
    def handle_browser_action(self):
        if not self.driver:
            raise RuntimeError("Selenium WebDriver가 초기화되지 않았습니다")
        import time

        time.sleep(10)


if __name__ == "__main__":
    scraper = PrimeScraper("Evolution", "Selectorized")
    urls = ["https://www.primefitnessusa.com/collections/evolution"]
    items = scraper.scrap(urls)
    for item in items:
        print(f"- {item.name}")
