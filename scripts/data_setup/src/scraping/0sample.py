import logging

from utils.base_scraper import BaseScraper
from utils.model import ScraperConfig

logger = logging.getLogger(__name__)

SampleScraperConfig = ScraperConfig(
    brand_name="",
    item_selector="",
    name_selector="",
    image_selector=""
)


class Scraper(BaseScraper):
    def __init__(self, machine_series: str):
        super().__init__(SampleScraperConfig)
        self.machine_series = machine_series


if __name__ == "__main__":
    scraper = Scraper("Line")
    urls = [
        ""
    ]
    items = scraper.scrap(urls)
    for item in items:
        print(f"- {item.name}")
