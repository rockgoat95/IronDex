import logging
import time

from bs4 import Tag
from selenium.common.exceptions import NoSuchElementException, TimeoutException
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.wait import WebDriverWait
from utils.base_scraper import BaseScraper
from utils.model import ScraperConfig

logger = logging.getLogger(__name__)

MatrixScraperConfig = ScraperConfig(
    brand_name="Matrix",
    item_selector="div.card.list-group-item.h-100",
    name_selector="a.card-text.ng-star-inserted",
    image_selector="img.card-img-top",
)


class MatrixScraper(BaseScraper):
    def __init__(self, type_: str = "Selectorized"):
        super().__init__(MatrixScraperConfig, contain_series=False, use_selenium=True)
        self.machine_series = ""
        self.type_ = type_

    def extract_name(self, item: Tag) -> str:
        name_elem = item.select_one(self.name_selector)
        if name_elem is None:
            raise ValueError(
                f"Name element not found with selector: {self.name_selector}"
            )

        name = name_elem.get_text(strip=True)

        code_elem = item.select_one("small")
        if code_elem is None:
            raise ValueError("Code element not found with selector: small")
        code = code_elem.get_text(strip=True)

        return name + " " + code

    def handle_browser_action(self) -> None:
        """Load More 버튼을 반복적으로 클릭"""
        if not self.driver:
            raise RuntimeError("Selenium WebDriver가 초기화되지 않았습니다")

        try:
            time.sleep(5)
            while True:
                # Load More 버튼 찾기
                button = "button.btn.btn-primary.ng-star-inserted"

                load_more_button = WebDriverWait(self.driver, 5).until(
                    EC.presence_of_element_located((By.CSS_SELECTOR, button))
                )
                self.driver.execute_script("arguments[0].click();", load_more_button)
                logger.info("Load More 버튼 클릭됨 (JavaScript)")
                # 새로운 콘텐츠 로드 대기
                time.sleep(3)

        except (TimeoutException, NoSuchElementException):
            logger.info("더 이상 Load More 버튼이 없습니다")
    def extract_additional_info(self, item: Tag) -> dict[str, str]:
        return {"type": self.type_}


if __name__ == "__main__":
    scraper = MatrixScraper()
    urls = [
        "https://kr.matrixfitness.com/kor/strength/catalog"
        "?modalities=plate-loaded&modalities=single-station"
        "&modalities=multi-station"
    ]
    items = scraper.scrap(urls)
    for item in items:
        print(f"- {item.name}")
