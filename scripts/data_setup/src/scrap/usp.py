import logging
import re

from bs4 import Tag

from utils.base_scraper import BaseScraper
from utils.model import ScraperConfig

logger = logging.getLogger(__name__)

USPScraperConfig = ScraperConfig(
    brand_name="USP",
    item_selector="div.shop-item._shop_item",
    name_selector="h2.shop-title",
    image_selector="img",
)


class USPScraper(BaseScraper):
    def __init__(self, machine_series: str, type_: str = "Selectorized"):
        super().__init__(USPScraperConfig)
        self.machine_series = machine_series
        self.type_ = type_

    def extract_additional_info(self, item: Tag) -> dict[str, str]:
        pay_elem = item.select_one("p.pay.inline-blocked")
        pay_elem_text = pay_elem.get_text(strip=True) if pay_elem else "N/A"
        price_match = re.search(r"[\d,]+", pay_elem_text)
        if price_match:
            # 쉼표 제거하고 정수로 변환
            return {"price": (price_match.group().replace(",", "")), "type": self.type_}
        return {"price": "N/A", "type": self.type_}

if __name__ == "__main__":
    scraper = USPScraper("LeverageSeries")
    urls = ["https://www.uspfitness.com/LeverageSeries"]
    items = scraper.scrap(urls)
    for item in items:
        print(f"- {item.name}")
