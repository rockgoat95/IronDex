import logging

from utils.base_scraper import BaseScraper
from utils.model import ScraperConfig

logger = logging.getLogger(__name__)

CybexScraperConfig = ScraperConfig(
    brand_name="Cybex",
    item_selector="div.productitem__container",
    name_selector="span.visually-hidden",
    image_selector="img",
)


class CybexScraper(BaseScraper):
    def __init__(self):
        super().__init__(CybexScraperConfig, contain_series=False)
        self.machine_series = ""


if __name__ == "__main__":
    scraper = CybexScraper()
    urls = [
        f"https://bestgymequipment.co.uk/collections/cybex?page={i}&grid_list=grid-view"
        for i in range(1, 2)
    ]
    items = scraper.scrap(urls)
    for item in items:
        print(f"- {item.name}")
