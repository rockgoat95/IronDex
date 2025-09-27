import os
import json
from utils.supabase_manager import SupabaseManager
from config.supabase import SUPABASE_URL


def run_logo_uploads(uploader: SupabaseManager):
    """Uploads all logos from the local logos directory to Supabase storage."""
    print("\n--- Starting Logo Uploads ---")

    script_dir = os.path.dirname(os.path.abspath(__file__))
    data_setup_dir = os.path.dirname(os.path.dirname(script_dir))
    logos_dir = os.path.join(data_setup_dir, "data/logos")
    bucket_name = "brand_images"

    if not os.path.isdir(logos_dir):
        print(f"Logos directory not found at {logos_dir}. Skipping logo uploads.")
        return

    for filename in os.listdir(logos_dir):
        if filename.startswith("."):
            continue

        file_path = os.path.join(logos_dir, filename)
        if os.path.isfile(file_path):
            try:
                # Use original filename as the destination path in the bucket
                uploader.upload_from_local_path(
                    bucket_name=bucket_name,
                    file_path=file_path,
                    destination_path=filename
                )
            except Exception as e:
                print(f"Error uploading {filename}: {e}")

    print("--- Logo Uploads Finished ---")


def run_brand_data_upload(sb_manager: SupabaseManager):
    """Uploads brand data from the brand.json file to the Supabase 'brands' table."""
    print("\n--- Starting Brand Data Upload ---")

    script_dir = os.path.dirname(os.path.abspath(__file__))
    data_setup_dir = os.path.dirname(os.path.dirname(script_dir))
    json_path = os.path.join(data_setup_dir, "init_data", "brand.json")
    table_name = "brands"

    try:
        with open(json_path, "r", encoding="utf-8") as f:
            brands_data = json.load(f)
    except FileNotFoundError:
        print(f"Brand data file not found at {json_path}. Skipping brand data upload.")
        return
    except json.JSONDecodeError:
        print(f"Error decoding JSON from {json_path}. Skipping brand data upload.")
        return

    sb_manager.upsert_to_table(table_name=table_name, data=brands_data)
    print("--- Brand Data Upload Finished ---")

def run_machine_image_upload(sb_manager: SupabaseManager):
    """
    Reads machine data, uploads images to Supabase if they haven't been uploaded yet,
    and saves a new JSON with updated URLs. This process is idempotent.
    """
    print("\n--- Starting Machine Image Upload ---")

    script_dir = os.path.dirname(os.path.abspath(__file__))
    data_setup_dir = os.path.dirname(os.path.dirname(script_dir))

    source_file = os.path.join(data_setup_dir, "init_data", "machines.json")
    output_file = os.path.join(data_setup_dir, "init_data", "machines_with_supabase_urls.json")

    # If the output file already exists, use it as the source to make the script resumable.
    # Otherwise, use the original machine data.
    if os.path.exists(output_file):
        print(f"Resuming from existing file: {output_file}")
        input_to_process = output_file
    else:
        print(f"Starting with initial data file: {source_file}")
        input_to_process = source_file

    try:
        with open(input_to_process, "r", encoding="utf-8") as f:
            machines = json.load(f)
    except FileNotFoundError:
        print(f"Input data file not found at {input_to_process}. Skipping image upload.")
        return
    except json.JSONDecodeError:
        print(f"Error decoding JSON from {input_to_process}. Skipping image upload.")
        return

    bucket_name = "machine_images"
    supabase_url_prefix = f"{SUPABASE_URL}/storage/v1/object/public/machine_images/"
    updated_machines = []
    total_machines = len(machines)

    for i, machine in enumerate(machines):
        image_url = machine.get("image_url")
        machine_name = machine.get('name', 'N/A')

        # Only upload if the URL is not empty and is not already a Supabase URL
        if image_url and not image_url.startswith(supabase_url_prefix):
            print(f"Processing image {i+1}/{total_machines} for machine: {machine_name}...")
            if image_url.startswith("http"):
                new_url = sb_manager.upload_from_url(
                    bucket_name=bucket_name,
                    url=image_url
                )
                if new_url:
                    machine["image_url"] = new_url
                    print(f"  -> Success: URL updated to {new_url}")
                else:
                    print(f"  -> Failed: Could not get new URL for {image_url}")
            else:
                print(f"  -> Skipped: URL is not a valid http link: {image_url}")
        else:
            if not image_url:
                print("  -> Skipped: No image URL provided.")

        updated_machines.append(machine)

    with open(output_file, "w", encoding="utf-8") as f:
        json.dump(updated_machines, f, indent=4, ensure_ascii=False)
    print(f"Successfully wrote updated machine data to {output_file}")
    print("--- Machine Image Upload Finished ---")

def run_machine_data_upload(sb_manager: SupabaseManager):
    """Uploads machine data from the JSON file to the Supabase 'machines' table."""
    print("\n--- Starting Machine Data Upload ---")

    script_dir = os.path.dirname(os.path.abspath(__file__))
    data_setup_dir = os.path.dirname(os.path.dirname(script_dir))
    json_path = os.path.join(data_setup_dir, "init_data", "machines_with_supabase_urls_and_preprocessed.json")
    table_name = "machines"

    try:
        with open(json_path, "r", encoding="utf-8") as f:
            machines_data = json.load(f)
    except FileNotFoundError:
        print(f"Machine data file not found at {json_path}. Skipping machine data upload.")
        return
    except json.JSONDecodeError:
        print(f"Error decoding JSON from {json_path}. Skipping machine data upload.")
        return

    sb_manager.upsert_to_table(table_name=table_name, data=machines_data)
    print("--- Machine Data Upload Finished ---")


def process_machine_json_for_database(sb_manager: SupabaseManager):
    """
    Processes machines_with_supabase_urls.json to prepare for database upload:
    1. Removes 'price' and 'detail' fields
    2. Converts 'brand' to 'brand_id' by looking up brands table
    3. Overwrites the original JSON file with cleaned data
    """
    print("\n--- Starting Machine JSON Processing ---")

    script_dir = os.path.dirname(os.path.abspath(__file__))
    data_setup_dir = os.path.dirname(os.path.dirname(script_dir))
    input_path = os.path.join(data_setup_dir, "init_data", "machines_with_supabase_urls.json")
    output_path = os.path.join(data_setup_dir, "init_data", "machines_with_supabase_urls_and_preprocessed.json")

    # Load current machine data
    with open(input_path, "r", encoding="utf-8") as f:
        machines_data = json.load(f)

    # Fetch all brands from Supabase to create name -> id mapping
    brands_response = sb_manager.client.table("brands").select("id, name").execute()
    brands_data = brands_response.data

        # Create brand name to ID mapping (case-insensitive)
    brand_name_to_id = {}
    for brand in brands_data:
        brand_name_to_id[brand['name'].lower()] = brand['id']

    print(f"Loaded {len(brands_data)} brands from database")

    # Process each machine
    processed_machines = []
    missing_brands = set()

    for i, machine in enumerate(machines_data):
        processed_machine = {}

        # Copy fields we want to keep
        for field in ['image_url', 'name', 'type']:
            if field in machine:
                processed_machine[field] = machine[field]

        # Convert brand to brand_id
        brand_name = machine.get('brand', '').lower()
        if brand_name in brand_name_to_id:
            processed_machine['brand_id'] = brand_name_to_id[brand_name]
        else:
            processed_machine['brand_id'] = None
            missing_brands.add(machine.get('brand', 'Unknown'))
            print(f"  Warning: Brand '{machine.get('brand')}' not found in database for machine: {machine.get('name')}")

        processed_machine["status"] = "approved"
        processed_machines.append(processed_machine)

        # Progress indicator
        if (i + 1) % 100 == 0:
            print(f"  Processed {i + 1}/{len(machines_data)} machines...")

    # Report missing brands
    if missing_brands:
        print(f"\n❌ Missing brands in database: {missing_brands}")
        print("Consider adding these brands to the brands table first.")

    # Save processed data back to JSON file
    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(processed_machines, f, indent=4, ensure_ascii=False)
    print(f"✅ Successfully processed and saved {len(processed_machines)} machines to {output_path}")

def run_brand_uploads():
    """Initializes the manager and runs all brand upload tasks."""
    print("======== Starting All Brand Upload Tasks ========")
    sb_manager = SupabaseManager()
    run_logo_uploads(sb_manager)
    run_brand_data_upload(sb_manager)
    print("======== All Upload Tasks Finished ========")


def run_machine_uploads():
    """Initializes the manager and runs all machine upload tasks."""
    print("======== Starting All Machine Upload Tasks ========")
    sb_manager = SupabaseManager()
    run_machine_image_upload(sb_manager)
    process_machine_json_for_database(sb_manager)
    run_machine_data_upload(sb_manager)
    print("======== All Machine Upload Tasks Finished ========")


def process_machine_json():
    """Initializes the manager and processes machine JSON for database compatibility."""
    print("======== Starting Machine JSON Processing ========")
    try:
        sb_manager = SupabaseManager()
        process_machine_json_for_database(sb_manager)
    except ConnectionError as e:
        print(f"Could not initialize Supabase Manager: {e}")
        print("Aborting JSON processing.")
    print("======== Machine JSON Processing Finished ========")