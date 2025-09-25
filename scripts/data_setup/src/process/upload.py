
import os
import json
from config.supabase import SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY
from supabase import create_client, Client

def upload_logos():
    """Uploads logos to Supabase storage."""
    print("Uploading logos to Supabase storage...")

    if not SUPABASE_URL or not SUPABASE_SERVICE_ROLE_KEY:
        print("Supabase URL and Key are not set. Please check your .env file.")
        return

    supabase: Client = create_client(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)
    bucket_name = "brand_images"

    script_dir = os.path.dirname(os.path.abspath(__file__))
    data_setup_dir = os.path.dirname(os.path.dirname(script_dir))
    logos_dir = os.path.join(data_setup_dir, "logos")

    for filename in os.listdir(logos_dir):
        if filename.startswith("."):
            continue

        file_path = os.path.join(logos_dir, filename)
        if os.path.isfile(file_path):
            with open(file_path, "rb") as f:
                try:
                    res = supabase.storage.from_(bucket_name).list(path=os.path.dirname(filename))
                    if filename not in [item['name'] for item in res]:
                        supabase.storage.from_(bucket_name).upload(filename, f)
                        print(f"Successfully uploaded {filename}")
                    else:
                        print(f"'{filename}' already exists, skipping.")
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
    data_setup_dir = os.path.dirname(os.path.dirname(script_dir))
    json_path = os.path.join(data_setup_dir, "init_data", "brand.json")

    with open(json_path, "r") as f:
        brands_data = json.load(f)

    try:
        supabase.table(table_name).upsert(brands_data).execute()
        print(f"Successfully uploaded data to {table_name} table.")
    except Exception as e:
        print(f"Error uploading data: {e}")

    print("Brand data upload finished.")
