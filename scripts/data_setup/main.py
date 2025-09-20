# scripts/data_setup/main.py
import argparse

from scrap.arsenal_strength import ArsenalStrengthScraper
from scrap.atlantis import AtlantisScraper
from scrap.booty_builder import BootyBuilderScraper
from scrap.cybex import CybexScraper
from scrap.drax import DraxScraper
from scrap.dynaforce import DynaforceScraper
from scrap.freemotion import FreemotionScraper
from scrap.gym80 import Gym80Scraper
from scrap.gymleco import GymlecoScraper
from scrap.hammer_strength import HammerStrengthScraper
from scrap.hoist import HoistScraper
from scrap.legend_fitness import LegendFitnessScraper
from scrap.Lexco import LexcoScraper
from scrap.life_fitness import LifeFitnessScraper
from scrap.matrix import MatrixScraper
from scrap.nautilus import NautilusScraper
from scrap.new_tech import NewTechScraper
from scrap.panatta import PanattaScraper
from scrap.precor import PrecorScraper
from scrap.prime_fitness import PrimeScraper
from scrap.techno_gym import TechnoGymScraper
from scrap.usp import USPScraper
from scrap.viliti import VilitiScraper


def run_scraping():
    """Runs all scraping tasks for Arsenal Strength."""
    print("Running Arsenal Strength scraping tasks...")

    # A list of configurations for each machine type to scrape.
    scrap_configs = {
        "Arsenal Strength": [
            {
                "machine_series": "Plate-loaded",
                "type_": "Plate-loaded",
                "urls": [
                    "https://www.ironcompany.com/strength-training-equipment/"
                    "plate-loaded-leverage-gym-equipment/brand-arsenal_strength"
                ],
            },
            {
                "machine_series": "Selectorized",
                "type_": "Selectorized",
                "urls": [
                    "https://www.ironcompany.com/strength-training-equipment/"
                    "selectorized-gym-equipment/brand-arsenal_strength"
                ],
            },
        ],
        "Atlantis": [
            {
                "urls": [
                    "https://rawfitnessequipment.com.au/collections/atlantis?page=3"
                    "&srsltid=AfmBOopi1LGGTpbWS3VpyoP52QgVwBorbevELH45tviUtGs7c0ozNg-C"
                ],
            }
        ],
        "Booty Builder": [
            {
                "type_": "Plate-loaded",
                "urls": [
                    "https://bootybuilder.com/product-category/machines/"
                    "plate-loaded-machines/"
                ],
            },
            {
                "type_": "Selectorized",
                "urls": [
                    "https://bootybuilder.com/product-category/machines/"
                    "weight-stack-machines/"
                ],
            },
        ],
        "Cybex": [
            {
                "urls": [
                    f"https://bestgymequipment.co.uk/collections/cybex?page={i}&grid_list=grid-view"
                    for i in range(1, 6)
                ],
            },
        ],
        "Drax": [
            {
                "machine_series": "Welliv Pro",
                "urls": ["https://www.draxfit.com/ko/strength/welliv-pro/products"],
            },
            {
                "machine_series": "Welliv",
                "urls": ["https://www.draxfit.com/ko/strength/welliv/products"],
            },
            {
                "machine_series": "Welliv Pro Dual",
                "urls": [
                    "https://www.draxfit.com/ko/strength/welliv-pro-dual/products"
                ],
            },
            {
                "machine_series": "Plate-loaded",
                "urls": ["https://www.draxfit.com/ko/strength/plate-loaded/products"],
            },
        ],
        "Dynaforce": [
            {
                "urls": [
                    "http://www.dynaforce.co.kr/bbs/board.php?bo_table=weight&page={i}"
                    for i in range(1, 3)
                ],
            },
            {
                "urls": ["http://www.dynaforce.co.kr/bbs/board.php?bo_table=hammer"],
            },
        ],
        "Freemotion": [
            {
                "machine_series": "Genesis",
                "urls": ["https://freemotionfitness.com/strength-machines/genesis/"],
            },
            {
                "machine_series": "Genesis",
                "urls": ["https://freemotionfitness.com/strength-machines/genesis/"],
            },
        ],
    }

    all_scraped_items = []
    for brand, configs in scrap_configs.items():
        print(brand)
        for config in configs:
            if brand == "Arsenal Strength":
                scraper = ArsenalStrengthScraper(
                    machine_series=config["machine_series"],
                    type_=config["type_"],
                )
            if brand == "Atlantis":
                scraper = AtlantisScraper()
            if brand == "Booty Builder":
                scraper = BootyBuilderScraper(
                    type_=config["type_"],
                )
            if brand == "Cybex":
                scraper = CybexScraper()
            if brand == "Drax":
                scraper = DraxScraper(
                    machine_series=config["machine_series"],
                )
            if brand == "Dynaforce":
                scraper = DynaforceScraper()

        scraped_items = scraper.scrap(config["urls"])

        print(f"Found {len(scraped_items)} items.")
        all_scraped_items.extend(scraped_items)
        print("-" * 20)

    print(f"\nTotal items scraped: {len(all_scraped_items)}")
    print("Scraping finished.")


def run_preprocessing():
    """Placeholder function for running preprocessing."""
    print("Running preprocessing tasks...")
    # TODO: Import and call your preprocessing functions here
    # For example:
    # preprocess.clean_data()
    # preprocess.load_to_supabase()
    print("Preprocessing finished.")


def main():
    """Main function to parse arguments and run tasks."""
    parser = argparse.ArgumentParser(description="IronDex data setup script.")
    subparsers = parser.add_subparsers(dest="command", help="Available commands")
    subparsers.required = True

    # --- Scrap Command ---
    parser_scrap = subparsers.add_parser("scrap", help="Run data scraping tasks.")
    # You can add arguments specific to scraping, e.g., which brand to scrape
    # parser_scrap.add_argument('--brand', type=str, help='Scrape a specific brand')
    parser_preprocess.set_defaults(func=run_scraping)

    # --- Preprocess Command ---
    parser_preprocess = subparsers.add_parser(
        "preprocess", help="Run data preprocessing and loading tasks."
    )
    parser_preprocess.set_defaults(func=run_preprocessing)

    args = parser.parse_args()

    # Execute the function associated with the chosen command
    if hasattr(args, "func"):
        args.func()


if __name__ == "__main__":
    main()


def run_scraping():
    """Runs all scraping tasks for Arsenal Strength."""
    print("Running Arsenal Strength scraping tasks...")

    # A list of configurations for each machine type to scrape.
    scrape_configs = [
        {
            "machine_type": "plate-loaded",
            "machine_series": "Plate-loaded",
            "url": "https://www.ironcompany.com/strength-training-equipment/plate-loaded-leverage-gym-equipment/brand-arsenal_strength",
        },
        {
            "machine_type": "selectorized",
            "machine_series": "Selectorized",
            "url": "https://www.ironcompany.com/strength-training-equipment/selectorized-gym-equipment/brand-arsenal_strength",
        },
    ]

    all_scraped_items = []
    for config in scrape_configs:
        print(f"--- Scraping '{config['machine_series']}' ---")
        scraper = ArsenalStrengthScraper(
            machine_type=config["machine_type"], machine_series=config["machine_series"]
        )

        scraped_items = scraper.scrap([config["url"]])

        print(f"Found {len(scraped_items)} items.")
        all_scraped_items.extend(scraped_items)
        print("-" * 20)

    print(f"\nTotal items scraped: {len(all_scraped_items)}")
    print("Scraping finished.")


def run_preprocessing():
    """Placeholder function for running preprocessing."""
    print("Running preprocessing tasks...")
    # TODO: Import and call your preprocessing functions here
    # For example:
    # preprocess.clean_data()
    # preprocess.load_to_supabase()
    print("Preprocessing finished.")


def main():
    """Main function to parse arguments and run tasks."""
    parser = argparse.ArgumentParser(description="IronDex data setup script.")
    subparsers = parser.add_subparsers(dest="command", help="Available commands")
    subparsers.required = True

    # --- Scrap Command ---
    parser_scrap = subparsers.add_parser("scrap", help="Run data scraping tasks.")
    # You can add arguments specific to scraping, e.g., which brand to scrape
    # parser_scrap.add_argument('--brand', type=str, help='Scrape a specific brand')
    parser_scrap.set_defaults(func=run_scraping)

    # --- Preprocess Command ---
    parser_preprocess = subparsers.add_parser(
        "preprocess", help="Run data preprocessing and loading tasks."
    )
    parser_preprocess.set_defaults(func=run_preprocessing)

    args = parser.parse_args()

    # Execute the function associated with the chosen command
    if hasattr(args, "func"):
        args.func()


if __name__ == "__main__":
    main()
