import logging

from bs4 import Tag

from utils.base_scraper import BaseScraper
from utils.model import ScraperConfig

logger = logging.getLogger(__name__)

BootyBuilderScraperConfig = ScraperConfig(
    brand_name="Booty Builder",
    item_selector="div.product-small.box",
    name_selector="a.woocommerce-LoopProduct-link.woocommerce-loop-product__link",
    image_selector="img.attachment-woocommerce_thumbnail.size-woocommerce_thumbnail",
)


class BootyBuilderScraper(BaseScraper):
    def __init__(self, machine_series: str, type_: str = "Selectorized"):
        super().__init__(BootyBuilderScraperConfig, contain_series=False)
        self.machine_series = machine_series
        self.type_ = type_

    def extract_additional_info(self, item: Tag) -> dict[str, str]:
        return {"type": self.type_}


if __name__ == "__main__":
    scraper = BootyBuilderScraper("Plate Loaded", type_="Plate-loaded")
    urls = ["https://bootybuilder.com/product-category/machines/plate-loaded-machines/"]
    items = scraper.scrap(urls)
    for item in items:
        print(f"- {item.name}")
