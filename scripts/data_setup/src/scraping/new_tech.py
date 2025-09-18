import logging
from typing import Any

from bs4 import Tag
from utils.base_scraper import BaseScraper
from utils.model import ScraperConfig

logger = logging.getLogger(__name__)

NewTechScraperConfig = ScraperConfig(
    brand_name="New Tech",
    item_selector=".shop-item._shop_item",
    name_selector="h2.shop-title",
    image_selector="img._org_img.org_img._lazy_img",
)


class NewTechScraper(BaseScraper):
    def __init__(self, machine_series):
        super().__init__(NewTechScraperConfig)
        self.machine_series = machine_series

    def extract_additional_info(self, item: Tag) -> Any:
        """상세 페이지에서 추가 정보 추출"""
        try:
            # a 태그에서 링크 찾기
            link_elem = item.select_one("a._fade_link.shop-item-thumb")
            if link_elem is None:
                logger.warning("링크 요소를 찾을 수 없습니다")
                return None

            href = link_elem.attrs.get("href")
            if not href:
                logger.warning("href 속성이 없습니다")
                return None

            # href가 리스트인 경우 첫 번째 값 사용
            if isinstance(href, list):
                href = href[0] if href else ""

            # 문자열로 변환
            href = str(href)

            # 상대 URL을 절대 URL로 변환
            if href.startswith("/"):
                detail_url = f"https://ntws.co.kr{href}"
            else:
                detail_url = href

            logger.info(f"상세 페이지 요청: {detail_url}")

            # 상세 페이지 가져오기
            detail_soup = self.fetch_page(detail_url)

            # div.goods_summary.body_font_color_70 > div.fr_view의 첫 번째 p 태그 찾기
            detail_elem = detail_soup.select_one(
                "div.goods_summary.body_font_color_70 > div.fr-view > p"
            )

            if detail_elem:
                detail_text = detail_elem.get_text(strip=True)
                logger.info(f"상세 정보 추출 완료: {detail_text[:50]}...")
                return {"name_kor": f"{self.machine_series} {detail_text}"}
            else:
                logger.warning("상세 정보를 찾을 수 없습니다")
                return None

        except Exception as e:
            logger.error(f"상세 정보 추출 중 오류: {e}")
            return None


if __name__ == "__main__":
    scraper = NewTechScraper("On Him")
    items = scraper.scrap(["https://ntws.co.kr/54"])
    for item in items:
        print(f"- {item.name}")
