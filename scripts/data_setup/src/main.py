
import argparse

# Import functions from the new modules
from process.scraping import run_scraping
from process.preprocess import run_preprocessing
from process.upload import upload_logos, upload_brands_data

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
