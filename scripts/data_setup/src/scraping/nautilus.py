import logging

from utils.base_scraper import BaseScraper
from utils.model import ScraperConfig

logger = logging.getLogger(__name__)

NautilusScraperConfig = ScraperConfig(
    brand_name="Nautilus",
    item_selector="li.grid__item",
    name_selector="a.full-unstyled-link",
    image_selector="img.motion-reduce",
)


class NautilusScraper(BaseScraper):
    def __init__(self, machine_series: str):
        super().__init__(NautilusScraperConfig, contain_series=False)
        self.machine_series = machine_series


if __name__ == "__main__":
    scraper = NautilusScraper("Line")
    urls = [
        "https://shop.corehandf.com/collections/inspiration-line?page=1",
        "https://shop.corehandf.com/collections/inspiration-line?page=2",
    ]
    items = scraper.scrap(urls)
    for item in items:
        print(f"- {item.name}")
