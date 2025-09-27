import argparse

# Import the new high-level functions from the refactored modules
from process.scraping import run_scraping
from process.preprocess import run_preprocessing
from process.upload import run_brand_uploads, run_machine_uploads

def main():
    """Main function to parse arguments and run tasks."""
    parser = argparse.ArgumentParser(description="IronDex data setup script.")
    subparsers = parser.add_subparsers(dest="command", help="Available commands")
    subparsers.required = True

    # --- Scrap Command ---
    parser_scrap = subparsers.add_parser("scrap", help="Run all data scraping tasks.")
    parser_scrap.set_defaults(func=run_scraping)

    # --- Preprocess Command ---
    # This now runs only the local data merging and normalization.
    preprocess_help = "Run local data preprocessing (merge and normalize scraped data)."
    parser_preprocess = subparsers.add_parser("preprocess", help=preprocess_help)
    parser_preprocess.set_defaults(func=run_preprocessing)

    # --- Upload Command ---
    # This uploads all data to Supabase: logos, brand info, and machine images.
    upload_help = "Upload all data (logos, brand info, machine images) to Supabase."
    parser_upload = subparsers.add_parser("upload_brand", help=upload_help)
    parser_upload.set_defaults(func=run_brand_uploads)


    # --- Upload Command ---
    # This uploads all data to Supabase: logos, brand info, and machine images.
    upload_help = "Upload all data (logos, brand info, machine images) to Supabase."
    parser_upload = subparsers.add_parser("upload_machine", help=upload_help)
    parser_upload.set_defaults(func=run_machine_uploads)

    args = parser.parse_args()

    # Execute the function associated with the chosen command
    if hasattr(args, "func"):
        print(f"Running command: {args.command}")
        args.func()
        print(f"\nCommand '{args.command}' finished.")

if __name__ == "__main__":
    main()