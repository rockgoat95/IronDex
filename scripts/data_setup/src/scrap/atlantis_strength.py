import logging

from bs4 import Tag
from utils.base_scraper import BaseScraper
from utils.model import ScraperConfig

logger = logging.getLogger(__name__)

AtlantisScraperConfig = ScraperConfig(
    brand_name="Atlantis Strength",
    item_selector="a.grid-view-item__link",
    name_selector="div.h4.grid-view-item__title.product-card__title",
    image_selector="img.grid-view-item__image",
)


class AtlantisScraper(BaseScraper):
    def __init__(self):
        super().__init__(AtlantisScraperConfig, use_selenium=True, contain_series=False)
        self.machine_series = ""

    def extract_name(self, item: Tag) -> str:
        href = item.attrs.get("href")
        detail_url = f"https://rawfitnessequipment.com.au{href}"
        detail_soup = self.fetch_page(detail_url, use_selenium=False)

        name_elem = detail_soup.select_one("h1.product-single__title")
        if name_elem is None:
            raise ValueError(
                f"Name element not found with selector: {self.name_selector}"
            )

        name = name_elem.get_text(strip=True)

        sku_elem = detail_soup.select_one("span.variant-sku")
        if sku_elem is not None:
            sku = sku_elem.get_text(
                strip=True,
            )
            name = f"{name} {sku[5:]}"
        return name

    def handle_browser_action(self) -> None:
        """Load More 버튼을 반복적으로 클릭"""
        if not self.driver:
            raise RuntimeError("Selenium WebDriver가 초기화되지 않았습니다")
        import time

        time.sleep(5)


if __name__ == "__main__":
    scraper = AtlantisScraper()
    urls = [
        "https://rawfitnessequipment.com.au/collections/atlantis?"
        "page=3&srsltid=AfmBOopi1LGGTpbWS3VpyoP52QgVwBorbevELH45tviUtGs7c0ozNg-C"
    ]
    items = scraper.scrap(urls)
    for item in items:
        print(f"- {item.name}")
