import logging

from bs4 import Tag

from utils.base_scraper import BaseScraper
from utils.model import ScraperConfig

logger = logging.getLogger(__name__)

GymlecoScraperConfig = ScraperConfig(
    brand_name="Gymleco",
    item_selector="div.block-inner-inner",
    name_selector="div.product-block__title.product-block-title",
    image_selector="img.theme-img",
)


class GymlecoScraper(BaseScraper):
    def __init__(self, type_: str = "Selectorized"):
        super().__init__(GymlecoScraperConfig, contain_series=False)
        self.machine_series = ""
        self.type_ = type_

    def extract_additional_info(self, item: Tag) -> dict[str, str]:
        return {"type": self.type_}


if __name__ == "__main__":
    scraper = GymlecoScraper(type_="Plate-loaded")
    urls = ["https://gymleco.com/collections/plate-loaded-machines"]
    items = scraper.scrap(urls)
    for item in items:
        print(f"- {item.name}")
