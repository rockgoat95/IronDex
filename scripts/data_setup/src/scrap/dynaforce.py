import logging

from bs4.element import Tag
from utils.base_scraper import BaseScraper
from utils.model import ScraperConfig

logger = logging.getLogger(__name__)

DynaforceScraperConfig = ScraperConfig(
    brand_name="Dynaforce",
    item_selector="ul.gall_con",
    name_selector="li.name",
    image_selector="img",
)


class DynaforceScraper(BaseScraper):
    def __init__(self, type_: str = "Selectorized"):
        super().__init__(DynaforceScraperConfig, contain_series=False)
        self.machine_series = ""
        self.type_ = type_

    def extract_name(self, item: Tag) -> str:

        name_elems = item.select("li.gall_text_href.text-center a")

        name = name_elems[1].get_text(strip=True) if name_elems else "N/A"
        return name
    def extract_additional_info(self, item: Tag):
        return {"type": self.type_}


if __name__ == "__main__":
    scraper = DynaforceScraper()
    urls = ["http://www.dynaforce.co.kr/bbs/board.php?bo_table=weight"]
    items = scraper.scrap(urls)
    for item in items:
        print(f"- {item.name}")
