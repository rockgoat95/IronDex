import logging
import time

from bs4 import BeautifulSoup, Tag
from selenium.common.exceptions import NoSuchElementException, TimeoutException
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.wait import WebDriverWait
from utils.base_scraper import BaseScraper
from utils.model import ScraperConfig

logger = logging.getLogger(__name__)

VilitiScraperConfig = ScraperConfig(
    brand_name="Viliti",
    item_selector="a.list_type_inner",
    name_selector="li.name",
    image_selector="img.item_img",
)


class VilitiScraper(BaseScraper):
    def __init__(self, type_: str = "Selectorized"):
        super().__init__(VilitiScraperConfig, contain_series=False, use_selenium=True)
        self.machine_series = ""
        self.type_ = type_

    def extract_name(self, item: Tag) -> str:
        href = item.attrs.get("href")
        detail_url = f"https://kaesun.com{href}"
        detail_soup = self.fetch_page(detail_url, use_selenium=True)

        name_elem = detail_soup.select_one("h2.product_headline.product_display_name")
        if name_elem is None:
            raise ValueError(
                f"Name element not found with selector: {self.name_selector}"
            )

        name = name_elem.get_text(strip=True)
        return name

    def handle_browser_action(self) -> None:
        """Load More 버튼을 반복적으로 클릭"""
        if not self.driver:
            raise RuntimeError("Selenium WebDriver가 초기화되지 않았습니다")

        try:

            time.sleep(5)
            len_items_before = 0
            while True:
                # Load More 버튼 찾기
                button = "div.product_paging.product_paging_1.animate a"

                load_more_button = WebDriverWait(self.driver, 5).until(
                    EC.presence_of_element_located((By.CSS_SELECTOR, button))
                )
                self.driver.execute_script("arguments[0].click();", load_more_button)
                logger.info("Load More 버튼 클릭됨 (JavaScript)")
                # 새로운 콘텐츠 로드 대기
                time.sleep(3)
                page_source = self.driver.page_source  # type: ignore
                soup = BeautifulSoup(page_source, "lxml")
                items = soup.select(self.item_selector)
                len_items = len(items)
                if len_items == len_items_before:
                    break
                len_items_before = len_items

        except (TimeoutException, NoSuchElementException):
            logger.info("더 이상 Load More 버튼이 없습니다")

    def extract_additional_info(self, item: Tag) -> dict[str, str]:
        import re

        pay_elem = item.select_one("li.saleprice em")
        pay_elem_text = pay_elem.get_text(strip=True) if pay_elem else "N/A"
        price_match = re.search(r"[\d,]+", pay_elem_text)
        if price_match:
            # 쉼표 제거하고 정수로 변환
            return {"price": (price_match.group().replace(",", "")), "type": self.type_}
        return {"price": "N/A", "type": self.type_}


if __name__ == "__main__":
    scraper = VilitiScraper()
    urls = ["https://kaesun.com/pages/upturn#none"]
    items = scraper.scrap(urls)
    for item in items:
        print(f"- {item.name}")
