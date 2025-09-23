import logging

from utils.base_scraper import BaseScraper
from utils.model import ScraperConfig

logger = logging.getLogger(__name__)

PanattaScraperConfig = ScraperConfig(
    brand_name="Panatta",
    item_selector=(
        "li.ast-article-single.desktop-align-left"
    ),
    name_selector="h2.woocommerce-loop-product__title",
    image_selector=(
        "img"
    ),
)


class PanattaScraper(BaseScraper):
    def __init__(self, machine_series, type_: str = "Selectorized"):
        super().__init__(PanattaScraperConfig)
        self.machine_series = machine_series
        self.type_ = type_

    def extract_additional_info(self, item) -> dict[str, str]:
        return {"type": self.type_}

if __name__ == "__main__":
    scraper = PanattaScraper("Monolith")
    urls = [
        "https://www.panattasport.com/en/monolith/#content",
        "https://www.panattasport.com/en/monolith/page/2/#content",
        "https://www.panattasport.com/en/monolith/page/3/#content",
    ]
    items = scraper.scrap(urls)
    for item in items:
        print(f"- {item.name}")
