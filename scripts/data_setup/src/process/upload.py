import os
import json
from utils.supabase_uploader import SupabaseUploader

def run_logo_uploads(uploader: SupabaseUploader):
    """Uploads all logos from the local logos directory to Supabase storage."""
    print("\n--- Starting Logo Uploads ---")

    script_dir = os.path.dirname(os.path.abspath(__file__))
    data_setup_dir = os.path.dirname(os.path.dirname(script_dir))
    logos_dir = os.path.join(data_setup_dir, "logos")
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


def run_brand_data_upload(uploader: SupabaseUploader):
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

    uploader.upsert_to_table(table_name=table_name, data=brands_data)
    print("--- Brand Data Upload Finished ---")

def run_machine_image_upload(uploader: SupabaseUploader):
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
    supabase_url_prefix = "https://xbhmosiuaadpwiezqbfk.supabase.co/storage/v1/object/public/machine_images/"
    updated_machines = []
    total_machines = len(machines)

    for i, machine in enumerate(machines):
        image_url = machine.get("image_url")
        machine_name = machine.get('name', 'N/A')

        # Only upload if the URL is not empty and is not already a Supabase URL
        if image_url and not image_url.startswith(supabase_url_prefix):
            print(f"Processing image {i+1}/{total_machines} for machine: {machine_name}...")
            if image_url.startswith("http"):
                new_url = uploader.upload_from_url(
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

def run_machine_data_upload(uploader: SupabaseUploader):
    """Uploads machine data from the JSON file to the Supabase 'machines' table."""
    print("\n--- Starting Machine Data Upload ---")

    script_dir = os.path.dirname(os.path.abspath(__file__))
    data_setup_dir = os.path.dirname(os.path.dirname(script_dir))
    json_path = os.path.join(data_setup_dir, "init_data", "machines_with_supabase_urls.json")
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

    uploader.upsert_to_table(table_name=table_name, data=machines_data)
    print("--- Machine Data Upload Finished ---")


def run_brand_uploads():
    """Initializes the uploader and runs all brand upload tasks."""
    print("======== Starting All Brand Upload Tasks ========")
    try:
        uploader = SupabaseUploader()
        run_logo_uploads(uploader)
        run_brand_data_upload(uploader)
    except ConnectionError as e:
        print(f"Could not initialize Supabase Uploader: {e}")
        print("Aborting all upload tasks.")
    print("======== All Upload Tasks Finished ========")


def run_machine_uploads():
    """Initializes the uploader and runs all machine upload tasks."""
    print("======== Starting All Machine Upload Tasks ========")
    try:
        uploader = SupabaseUploader()
        run_machine_image_upload(uploader)
        # run_machine_data_upload(uploader)
    except ConnectionError as e:
        print(f"Could not initialize Supabase Uploader: {e}")
        print("Aborting all upload tasks.")
    print("======== All Machine Upload Tasks Finished ========")