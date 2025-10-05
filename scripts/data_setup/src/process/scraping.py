import os
import shutil


def run_scraping() -> None:
    """Runs all scraping tasks."""
    print("Running scraping tasks...")

    script_dir = os.path.dirname(os.path.abspath(__file__))
    data_setup_dir = os.path.dirname(os.path.dirname(script_dir))
    data_dir = os.path.join(data_setup_dir, "scraped_data")

    answer = (
        input("기존에 수집된 데이터를 모두 삭제하고 새로 수집하시겠습니까? (y/n): ")
        .strip()
        .lower()
    )
    if answer == "y":
        if os.path.exists(data_dir):
            shutil.rmtree(data_dir)
        os.makedirs(data_dir)
    elif answer == "n":
        pass
    else:
        print("잘못된 입력입니다. 'y' 또는 'n'을 입력해주세요.")
        return

    from config.scrap import SCRAP_CONFIG

    for config in SCRAP_CONFIG:
        scraper = config["scraper"]
        scraper.scrap(config["urls"])
