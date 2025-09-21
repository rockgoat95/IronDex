import logging

from bs4 import Tag

from utils.base_scraper import BaseScraper
from utils.model import ScraperConfig

logger = logging.getLogger(__name__)

LegendFitnessScraperConfig = ScraperConfig(
    brand_name="Legend Fitness",
    item_selector="div.block",
    name_selector="h3",
    image_selector="img",
)


class LegendFitnessScraper(BaseScraper):
    def __init__(self, type_: str = "Selectorized"):
        super().__init__(LegendFitnessScraperConfig, contain_series=False)
        self.type_ = type_

    def extract_name(self, item: Tag) -> str:
        name_elem = item.select_one(self.name_selector)
        if name_elem is None:
            raise ValueError(
                f"Name element not found with selector: {self.name_selector}"
            )

        name = name_elem.get_text(strip=True)

        code_elem = item.select_one("h5")
        if code_elem is None:
            raise ValueError("Code element not found with selector: h5")
        code = code_elem.get_text(strip=True)

        return name + " " + code

    def extract_additional_info(self, item: Tag):
        return {"type": self.type_}


if __name__ == "__main__":
    scraper = LegendFitnessScraper()
    urls = [
        "https://www.legendfitness.com/products/"
        "selectorized-equipment/upper-body-selectorized-equipment/",
    ]
    items = scraper.scrap(urls)
    for item in items:
        print(f"- {item.name}")
