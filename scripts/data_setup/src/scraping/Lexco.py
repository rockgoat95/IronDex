import logging

from utils.base_scraper import BaseScraper
from utils.model import ScraperConfig

logger = logging.getLogger(__name__)

LexcoScraperConfig = ScraperConfig(
    brand_name="Lexco",
    item_selector="div.item",
    name_selector="div.tit",
    image_selector="img",
)


class LexcoScraper(BaseScraper):
    def __init__(self, machine_series: str):
        super().__init__(LexcoScraperConfig)
        self.machine_series = machine_series


if __name__ == "__main__":
    scraper = LexcoScraper("팔콘")
    urls = [
        "http://www.lexco.kr/shop_list.php?gsp_p=1&gsp_md=shop_goods&gsp_srch_cate=189",
        "http://www.lexco.kr/shop_list.php?gsp_p=2&gsp_md=shop_goods&gsp_srch_cate=189",
    ]
    items = scraper.scrap(urls)
    for item in items:
        print(f"- {item.name}")
