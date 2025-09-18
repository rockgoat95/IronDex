import logging

from bs4.element import Tag
from utils.base_scraper import BaseScraper
from utils.model import ScraperConfig

logger = logging.getLogger(__name__)

ArsenalStrengthScraperConfig = ScraperConfig(
    brand_name="Arsenal Strength",
    item_selector="form.item.h-full.product.product-item.product_addtocart_form",
    name_selector="a.product-item-link",
    image_selector="img.object-contain",
)


class ArsenalStrengthScraper(BaseScraper):
    def __init__(self, machine_series: str, type_: str):
        super().__init__(
            ArsenalStrengthScraperConfig,
            contain_series=False,
            use_selenium=True,
        )
        self.type_ = type_
        self.machine_series = machine_series

    def handle_browser_action(self) -> None:
        """Load More 버튼을 반복적으로 클릭"""
        if not self.driver:
            raise RuntimeError("Selenium WebDriver가 초기화되지 않았습니다")
        import time

        time.sleep(5)

    def extract_additional_info(self, item: Tag) -> dict:
        return {"type": self.type_}


if __name__ == "__main__":
    scraper = ArsenalStrengthScraper("Line", "plate-loaded")
    urls = [
        "https://www.ironcompany.com/strength-training-equipment/"
        "plate-loaded-leverage-gym-equipment/brand-arsenal_strength"
    ]
    items = scraper.scrap(urls)
    for item in items:
        print(f"- {item.name}")

    scraper = ArsenalStrengthScraper("selectorized", "selectorized")
    urls = [
        "https://www.ironcompany.com/strength-training-equipment/"
        "selectorized-gym-equipment/brand-arsenal_strength"
    ]
    items = scraper.scrap(urls)
    for item in items:
        print(f"- {item.name}")
