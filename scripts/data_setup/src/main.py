# scripts/data_setup/main.py
import argparse
import os
import shutil
import json
from config.supabase import SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY
from supabase import create_client, Client


def run_scraping() -> None:
    """Runs all scraping tasks."""
    print("Running scraping tasks...")

    script_dir = os.path.dirname(os.path.abspath(__file__))
    data_setup_dir = os.path.dirname(script_dir)
    data_dir = os.path.join(data_setup_dir, "scraped_data")

    answer = input(
        f"기존에 수집된 데이터를 모두 삭제하고 새로 수집하시겠습니까? (y/n): "
    ).strip().lower()
    if answer == "y":
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

def run_preprocessing():
    """Placeholder function for running preprocessing."""
    print("Running preprocessing tasks...")
    # TODO: Import and call your preprocessing functions here
    # For example:
    # preprocess.clean_data()
    # preprocess.load_to_supabase()
    print("Preprocessing finished.")


def upload_logos():
    """Uploads logos to Supabase storage."""
    print("Uploading logos to Supabase storage...")

    if not SUPABASE_URL or not SUPABASE_SERVICE_ROLE_KEY:
        print("Supabase URL and Key are not set. Please check your .env file.")
        return

    supabase: Client = create_client(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)
    bucket_name = "brand_images"

    script_dir = os.path.dirname(os.path.abspath(__file__))
    logos_dir = os.path.join(os.path.dirname(script_dir), "logos")

    for filename in os.listdir(logos_dir):
        if filename.startswith("."):
            continue

        file_path = os.path.join(logos_dir, filename)
        if os.path.isfile(file_path):
            with open(file_path, "rb") as f:
                try:
                    supabase.storage.from_(bucket_name).upload(filename, f)
                    print(f"Successfully uploaded {filename}")
                except Exception as e:
                    print(f"Error uploading {filename}: {e}")

    print("Logo upload finished.")


def upload_brands_data():
    """Uploads brand data from JSON file to Supabase table."""
    print("Uploading brands data to Supabase table...")

    if not SUPABASE_URL or not SUPABASE_SERVICE_ROLE_KEY:
        print("Supabase URL and Key are not set. Please check your .env file.")
        return

    supabase: Client = create_client(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)
    table_name = "brands"

    script_dir = os.path.dirname(os.path.abspath(__file__))
    json_path = os.path.join(os.path.dirname(script_dir), "init_data", "brand.json")

    with open(json_path, "r") as f:
        brands_data = json.load(f)

    try:
        supabase.table(table_name).upsert(brands_data).execute()
        print(f"Successfully uploaded data to {table_name} table.")
    except Exception as e:
        print(f"Error uploading data: {e}")

    print("Brand data upload finished.")

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

    # --- Upload Logos Command ---
    parser_upload = subparsers.add_parser(
        "upload_logos", help="Upload logos to Supabase storage."
    )
    parser_upload.set_defaults(func=upload_logos)

    # --- Upload Brands Command ---
    parser_upload_brands = subparsers.add_parser(
        "upload_brands", help="Upload brands data to Supabase table."
    )
    parser_upload_brands.set_defaults(func=upload_brands_data)

    args = parser.parse_args()

    # Execute the function associated with the chosen command
    if hasattr(args, "func"):
        args.func()


if __name__ == "__main__":
    main()