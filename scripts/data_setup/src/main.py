# scripts/data_setup/main.py
import argparse
from config import SCRAP_CONFIG


def run_scraping():
    """Runs all scraping tasks."""
    print("Running scraping tasks...")

    # A list of configurations for each machine type to scrape.


    for config in SCRAP_CONFIG:
        scraper = config["scraper"]
        scraper.scrap(config["urls"])

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