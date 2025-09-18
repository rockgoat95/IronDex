import logging

from bs4 import Tag

from utils.base_scraper import BaseScraper
from utils.model import ScraperConfig

logger = logging.getLogger(__name__)

HoistScraperConfig = ScraperConfig(
    brand_name="Hoist",
    item_selector="div.product_line_card_div",
    name_selector="h6",
    image_selector="img",
)


class HoistScraper(BaseScraper):
    def __init__(self, machine_series: str):
        super().__init__(HoistScraperConfig)
        self.machine_series = machine_series

    def extract_name(self, item):
        name_elem = item.select_one(self.name_selector)
        if name_elem is None:
            raise ValueError(
                f"Name element not found with selector: {self.name_selector}"
            )

        name = name_elem.get_text(strip=True)

        # ' - ' 이후의 부분 제거
        name = name.split(" - ")[0].strip()
        return name

    def extract_image_url(self, item):
        img_elem = item.select_one(self.image_selector)
        if img_elem is None:
            raise ValueError(
                f"Image element not found with selector: {self.image_selector}"
            )

        img_url = img_elem.attrs.get("src", "")
        return "https:" + img_url

    def extract_additional_info(self, item: Tag):
        code_elem = item.select("h6")[1]
        code = code_elem.get_text(strip=True).replace('"', "").strip()
        return {"code": code}


if __name__ == "__main__":
    scraper = HoistScraper("Plate Loaded")
    urls = ["https://www.hoistfitness.com/collections/ccat-plate-loaded"]
    items = scraper.scrap(urls)
    for item in items:
        print(f"- {item.name}")
