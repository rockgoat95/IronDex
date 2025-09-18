import logging

from utils.base_scraper import BaseScraper
from utils.model import ScraperConfig

logger = logging.getLogger(__name__)

DraxScraperConfig = ScraperConfig(
    brand_name="Drax",
    item_selector=(
        "a.space-y-10"
    ),
    name_selector="h3.text-2xl.md\\:text-3xl",
    image_selector=(
        "img.object-contain.h-full.w-max"
    ),
)


class DraxScraper(BaseScraper):
    def __init__(self, machine_series, contain_series: bool = False):
        super().__init__(DraxScraperConfig, contain_series=contain_series)
        self.machine_series = machine_series


if __name__ == "__main__":
    scraper = DraxScraper("Welliv Pro", False)
    urls = [
        "https://www.draxfit.com/ko/strength/welliv-pro/products"
    ]
    items = scraper.scrap(urls)
    for item in items:
        print(f"- {item.name}")
