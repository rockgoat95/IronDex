import logging

from bs4 import Tag
from utils.base_scraper import BaseScraper
from utils.model import ScraperConfig

logger = logging.getLogger(__name__)

BootyBuilderScraperConfig = ScraperConfig(
    brand_name="Booty Builder",
    item_selector="div.product-small.col",
    name_selector="a.woocommerce-LoopProduct-link.woocommerce-loop-product__link",
    image_selector="img.attachment-woocommerce_thumbnail",
)


class BootyBuilderScraper(BaseScraper):
    def __init__(self, type_: str = "Selectorized"):
        super().__init__(BootyBuilderScraperConfig, contain_series=False, use_selenium=True)
        self.machine_series = ""
        self.type_ = type_

    def extract_additional_info(self, item: Tag) -> dict[str, str]:
        return {"type": self.type_}

    def handle_browser_action(self):
        if not self.driver:
            raise RuntimeError("Selenium WebDriver가 초기화되지 않았습니다")
        import time

        time.sleep(120)


if __name__ == "__main__":
    scraper = BootyBuilderScraper(type_="Plate-loaded")
    urls = ["https://bootybuilder.com/product-category/machines/plate-loaded-machines/"]
    items = scraper.scrap(urls)
    for item in items:
        print(f"- {item.name}")
