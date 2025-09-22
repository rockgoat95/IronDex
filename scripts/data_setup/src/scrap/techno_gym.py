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

TechnoGymScraperConfig = ScraperConfig(
    brand_name="Techno Gym",
    item_selector="a.css-1jke4yk",
    name_selector="h3.chakra-text.css-179z6sb",
    image_selector="img.chakra-image.css-9tsw64",
)


class TechnoGymScraper(BaseScraper):
    def __init__(self, type_: str):
        super().__init__(
            TechnoGymScraperConfig, contain_series=False, use_selenium=True
        )
        self.machine_series = ""
        self.type_ = type_

    def handle_browser_action(self) -> None:
        """Load More 버튼을 반복적으로 클릭"""
        if not self.driver:
            raise RuntimeError("Selenium WebDriver가 초기화되지 않았습니다")

        try:
            time.sleep(5)
            while True:
                # Load More 버튼 찾기
                button = "button.css-1v8s6ns"

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
    # scraper = TechnoGymScraper("Line", "Selectorized")
    # base_url = "https://www.technogym.com/en-INT/category"
    # category = "selectorized-strength-machines"
    # urls = [f"{base_url}/{category}/"]
    # items = scraper.scrap(urls)

    scraper = TechnoGymScraper("Plate-loaded")
    base_url = "https://www.technogym.com/en-INT/category"
    category = "plate-loaded"
    urls = [f"{base_url}/{category}/"]
    items = scraper.scrap(urls)
