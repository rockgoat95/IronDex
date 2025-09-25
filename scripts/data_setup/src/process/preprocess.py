
import json
import os

def run_preprocessing():
    """
    Merges all JSON files from the scraped_data directory into a single file,
    flattens the 'detail' key, and ensures all machine objects have the same set of keys.
    """
    print("Running preprocessing tasks...")

    script_dir = os.path.dirname(os.path.abspath(__file__))
    data_setup_dir = os.path.dirname(os.path.dirname(script_dir))

    scraped_data_dir = os.path.join(data_setup_dir, "scraped_data")
    output_dir = os.path.join(data_setup_dir, "init_data")
    output_file = os.path.join(output_dir, "machines.json")

    if not os.path.exists(scraped_data_dir):
        print(f"Error: Directory not found at {scraped_data_dir}")
        return

    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    all_machines = []
    all_keys = set()

    # First pass: read all files, flatten details, and collect all keys
    print("Pass 1: Reading files and collecting all unique keys...")
    for filename in os.listdir(scraped_data_dir):
        if filename.endswith(".json"):
            filepath = os.path.join(scraped_data_dir, filename)
            with open(filepath, 'r', encoding='utf-8') as f:
                try:
                    data = json.load(f)
                    for machine in data:
                        if 'detail' in machine and isinstance(machine['detail'], dict):
                            for key, value in machine['detail'].items():
                                machine[key] = value
                            del machine['detail']

                        all_machines.append(machine)
                        all_keys.update(machine.keys())
                except json.JSONDecodeError:
                    print(f"Warning: Could not decode JSON from {filename}")
                except Exception as e:
                    print(f"An error occurred while processing {filename}: {e}")

    print(f"Found {len(all_keys)} unique keys across all files.")

    # Second pass: normalize all machine objects to have the same keys
    print("Pass 2: Normalizing all machine objects...")
    normalized_machines = []
    for machine in all_machines:
        normalized_machine = {}
        for key in all_keys:
            normalized_machine[key] = machine.get(key, None)
        normalized_machines.append(normalized_machine)

    print(f"Writing {len(normalized_machines)} normalized machines to {output_file}...")
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(normalized_machines, f, indent=4, ensure_ascii=False)

    print(f"Successfully merged, flattened, and normalized {len(normalized_machines)} machines into {output_file}")
    print("Preprocessing finished.")
