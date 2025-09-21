import logging

from utils.base_scraper import BaseScraper
from utils.model import ScraperConfig

logger = logging.getLogger(__name__)

PanattaScraperConfig = ScraperConfig(
    brand_name="Panatta",
    item_selector=(
        "a.woocommerce-LoopProduct-link.woocommerce-loop-product__link"
    ),
    name_selector="h2.woocommerce-loop-product__title",
    image_selector=(
        "img.attachment-woocommerce_thumbnail.size-woocommerce_thumbnail"
    ),
)


class PanattaScraper(BaseScraper):
    def __init__(self, machine_series, type_: str = "Selectorized"):
        super().__init__(PanattaScraperConfig)
        self.machine_series = machine_series
        self.type_ = type_

    def extract_name(self, item) -> str:
        name_elem = item.select_one(self.name_selector)
        if name_elem is None:
            raise ValueError(
                f"Name element not found with selector: {self.name_selector}"
            )

        name = name_elem.get_text(strip=True)

        code_elem = item.select_one("span.woocommerce-loop-product__sku")
        if code_elem is None:
            raise ValueError(f"Code element not found with selector")
        code = code_elem.get_text(strip=True)

        return name + " " + code

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
