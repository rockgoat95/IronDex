import logging

from bs4 import Tag

from utils.base_scraper import BaseScraper
from utils.model import ScraperConfig

logger = logging.getLogger(__name__)

FreemotionScraperConfig = ScraperConfig(
    brand_name="Freemotion Fitness",
    item_selector="div.prod-frame",
    name_selector="h5",
    image_selector="img",
)


class FreemotionScraper(BaseScraper):
    def __init__(self, machine_series: str):
        super().__init__(FreemotionScraperConfig)
        self.machine_series = machine_series

    def extract_name(self, item: Tag) -> str:
        name_elem = item.select_one(self.name_selector)
        if name_elem is None:
            raise ValueError(
                f"Name element not found with selector: {self.name_selector}"
            )

        name = name_elem.get_text(strip=True)

        code_elem = item.select_one("strong")
        if code_elem is None:
            raise ValueError("Code element not found with selector: h5")
        code = code_elem.get_text(strip=True)

        return name + " " + code


if __name__ == "__main__":
    scraper = FreemotionScraper("Genesis")
    urls = ["https://freemotionfitness.com/strength-machines/genesis/"]
    items = scraper.scrap(urls)
    for item in items:
        print(f"- {item.name}")
