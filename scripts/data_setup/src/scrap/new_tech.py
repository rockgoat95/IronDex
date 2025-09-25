import logging
from typing import Any

from bs4 import Tag
from utils.base_scraper import BaseScraper
from utils.model import ScraperConfig

logger = logging.getLogger(__name__)

NewTechScraperConfig = ScraperConfig(
    brand_name="New Tech",
    item_selector=".shop-item._shop_item",
    name_selector="h2.shop-title",
    image_selector="img._org_img.org_img._lazy_img",
)


class NewTechScraper(BaseScraper):
    def __init__(self, machine_series, type_: str = "Selectorized"):
        super().__init__(NewTechScraperConfig)
        self.machine_series = machine_series
        self.type_ = type_

    def extract_additional_info(self, item: Tag) -> dict[str, str]:
        return {"type": self.type_}


if __name__ == "__main__":
    scraper = NewTechScraper("On Him")
    items = scraper.scrap(["https://ntws.co.kr/54"])
    for item in items:
        print(f"- {item.name}")
