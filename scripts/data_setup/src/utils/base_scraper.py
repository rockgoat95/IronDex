import json
import logging
import time
from typing import Any
from urllib.parse import urljoin, urlparse

import requests
from bs4 import BeautifulSoup
from bs4.element import Tag
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service as ChromeService
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.wait import WebDriverWait
from selenium.webdriver.chrome.service import Service as ChromeService
from webdriver_manager.chrome import ChromeDriverManager
from webdriver_manager.chrome import ChromeDriverManager
from utils.model import Machine, ScraperConfig

# 로깅 설정
logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)


class BaseScraper:
    """머신 스크래퍼 베이스"""

    def __init__(
        self,
        scraper_config: ScraperConfig,
        contain_series: bool = True,
        use_selenium: bool = False,
    ) -> None:
        self.session = requests.Session()
        # User-Agent 설정으로 차단 방지
        self.session.headers.update(
            {
                "User-Agent": (
                    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
                    "AppleWebKit/537.36 (KHTML, like Gecko) "
                    "Chrome/120.0.0.0 Safari/537.36"
                )
            }
        )

        # 설정 파일에서 브랜드별 설정 로드
        self.brand_name = scraper_config.brand_name
        self.item_selector = scraper_config.item_selector
        self.name_selector = scraper_config.name_selector
        self.image_selector = scraper_config.image_selector
        self.machine_series = scraper_config.machine_series
        self.contain_series = contain_series
        self.current_base_url = None  # 현재 처리 중인 페이지의 베이스 URL 저장

        # Selenium 설정
        self.use_selenium = use_selenium
        self.driver = None
        if use_selenium:
            self._setup_selenium()

    def _setup_selenium(self) -> None:
        """Selenium WebDriver 설정"""
        chrome_options = Options()

        # Bot 감지 우회를 위한 설정들
        # chrome_options.add_argument("--headless=new")
        chrome_options.add_argument("--no-sandbox")
        chrome_options.add_argument("--disable-dev-shm-usage")
        chrome_options.add_argument("--disable-gpu")
        chrome_options.add_argument("--disable-extensions")
        chrome_options.add_argument("--disable-plugins")
        chrome_options.add_argument("--window-size=1920,1080")

        # Bot 감지 우회 핵심 설정들
        chrome_options.add_argument("--disable-blink-features=AutomationControlled")
        chrome_options.add_experimental_option("excludeSwitches", ["enable-automation"])
        chrome_options.add_experimental_option("useAutomationExtension", False)

        # 더 현실적인 User-Agent
        chrome_options.add_argument(
            "--user-agent=Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
            "AppleWebKit/537.36 (KHTML, like Gecko) "
            "Chrome/120.0.0.0 Safari/537.36"
        )

        # webdriver-manager를 사용하여 자동으로 chromedriver를 설치하고 로드합니다.
        self.driver = webdriver.Chrome(
            service=ChromeService(ChromeDriverManager().install()), options=chrome_options
        )

        if not self.driver:
            raise RuntimeError("Selenium WebDriver 초기화 실패")

    def __del__(self):
        """소멸자에서 WebDriver 종료"""
        if hasattr(self, "driver") and self.driver:
            self.driver.quit()

    def fetch_page(self, url: str, use_selenium: bool = False) -> BeautifulSoup:
        """웹페이지를 가져오고 BeautifulSoup 객체로 반환"""
        if use_selenium:
            return self.fetch_page_with_selenium(url)
        else:
            return self.fetch_page_with_requests(url)

    def fetch_page_with_requests(self, url: str) -> BeautifulSoup:
        """requests를 사용한 기존 방식"""
        try:
            logger.info(f"페이지 요청: {url}")
            response = self.session.get(url, timeout=10)
            response.raise_for_status()

            # 인코딩 설정
            response.encoding = response.apparent_encoding

            soup = BeautifulSoup(response.text, "lxml")
            logger.info(f"페이지 성공적으로 로드됨: {url}")
            return soup

        except requests.exceptions.RequestException as e:
            logger.error(f"페이지 요청 실패: {url}, 오류: {e}")
            raise

    def fetch_page_with_selenium(self, url: str) -> BeautifulSoup:
        """Selenium을 사용한 동적 페이지 처리"""
        try:
            logger.info(f"Selenium으로 페이지 요청: {url}")
            self.driver.get(url)  # type: ignore

            # 페이지 로드 대기
            WebDriverWait(self.driver, 10).until(  # type: ignore
                EC.presence_of_element_located((By.TAG_NAME, "body"))
            )
            # 브라우저 액션 (오버라이드 가능)
            self.handle_browser_action()

            # 최종 HTML 가져오기
            page_source = self.driver.page_source  # type: ignore
            soup = BeautifulSoup(page_source, "lxml")
            logger.info(f"Selenium으로 페이지 성공적으로 로드됨: {url}")
            return soup

        except Exception as e:
            logger.error(f"Selenium 페이지 요청 실패: {url}, 오류: {e}")
            raise

    def handle_browser_action(self):
        pass

    def scrap(self, target_urls: list[str]) -> list[Machine]:

        items = []
        for url in target_urls:
            print(f"Brand: {self.brand_name}, Machine Series: {self.machine_series}, Processing URL: {url}")
            self.current_base_url = self._get_base_url(url)  # 베이스 URL 저장
            soup = self.fetch_page(url, use_selenium=self.use_selenium)
            new_items = self.extract_items(soup)
            # 상품 아이템 추출
            if not new_items:
                logger.warning(f"URL에서 아이템을 찾지 못했습니다.")
            items.extend(new_items)

        # 결과 저장
        if items:
            self.save_to_json(items)

        return items

    def _get_base_url(self, url: str) -> str:
        """URL에서 베이스 URL을 추출"""
        parsed = urlparse(url)
        return f"{parsed.scheme}://{parsed.netloc}"

    def _normalize_image_url(self, image_url: str) -> str:
        """이미지 URL을 절대 경로로 변환"""
        if not image_url:
            return ""

        # 이미 완전한 URL인 경우
        if image_url.startswith(("http://", "https://")):
            return image_url

        # 상대 경로인 경우 베이스 URL과 결합
        if self.current_base_url:
            return urljoin(self.current_base_url, image_url)

        return image_url

    def extract_items(self, soup: BeautifulSoup) -> list[Machine]:
        """shop-item _shop_item 클래스를 가진 요소들을 추출"""
        items = []

        # 다양한 클래스 선택자로 시도

        found_items = soup.select(self.item_selector)
        logger.info(f"'{self.item_selector}' 선택자로 {len(found_items)}개 아이템 발견")
        shop_items = found_items

        for idx, item in enumerate(shop_items):
            try:
                item_data = self.extract_item_info(item)
                if item_data:
                    items.append(item_data)
            except Exception as e:
                logger.error(f"아이템 {idx} 정보 추출 중 오류: {e}")
                continue

        logger.info(f"총 {len(items)}개 아이템 정보 추출 완료")
        return items

    def extract_item_info(self, item: Tag) -> Machine:

        name = self.extract_name(item)

        image_url = self.extract_image_url(item)
        image_url = self._normalize_image_url(str(image_url))

        detail = self.extract_additional_info(item)

        # TODO: body_parts, movements, type 등 추가 필드 추출 구현 필요

        if self.contain_series:
            full_name = f"{self.machine_series} {name}"
        else:
            full_name = name
        return Machine(
            brand=self.brand_name,
            name=full_name,
            image_url=str(image_url),
            detail=detail,
        )

    def extract_name(self, item: Tag) -> str:
        name_elem = item.select_one(self.name_selector)
        if name_elem is None:
            raise ValueError(
                f"Name element not found with selector: {self.name_selector}"
            )
        return name_elem.get_text(strip=True)

    def extract_image_url(self, item: Tag) -> str:
        image_elem = item.select_one(self.image_selector)
        if image_elem is None:
            raise ValueError(
                f"Image element not found with selector: {self.image_selector}"
            )

        image_url = image_elem.attrs.get("src")
        if image_url is None:
            raise ValueError("Image src attribute not found")

        # AttributeValuelist인 경우 첫 번째 값 사용
        if isinstance(image_url, list):
            image_url = image_url[0] if image_url else ""

        return image_url

    def extract_additional_info(self, item: Tag) -> Any:
        """추가 정보 추출 (필요시 구현)"""
        # 예: 가격, 설명 등 추가 필드 추출 가능
        return None

    def save_to_json(self, data: list[Machine]) -> None:
        """데이터를 JSON 파일로 저장"""
        timestamp = int(time.time())
        filename = (
            f"scripts/data_setup/scraped_data/{self.brand_name}_{self.machine_series}_"
            f"machines_{timestamp}.json"
        )

        # Pydantic 모델들을 dict로 변환
        json_data = [machine.model_dump() for machine in data]

        with open(filename, "w", encoding="utf-8") as f:
            json.dump(json_data, f, ensure_ascii=False, indent=2, default=str)
        logger.info(f"데이터가 {filename}에 저장되었습니다.")
