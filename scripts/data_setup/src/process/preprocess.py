import json
import os

class Preprocessor:
    """
    Handles the local preprocessing of machine data, focusing on merging and 
    normalizing scraped data from JSON files.
    """

    def __init__(self):
        """Initializes the Preprocessor, setting up necessary file paths."""
        print("Initializing Preprocessor...")
        self.script_dir = os.path.dirname(os.path.abspath(__file__))
        self.data_setup_dir = os.path.dirname(os.path.dirname(self.script_dir))
        self.scraped_data_dir = os.path.join(self.data_setup_dir, "scraped_data")
        self.output_dir = os.path.join(self.data_setup_dir, "init_data")
        self.output_file = os.path.join(self.output_dir, "machines.json")

    def _read_json(self, file_path):
        """Reads and returns data from a JSON file."""
        try:
            with open(file_path, "r", encoding="utf-8") as f:
                return json.load(f)
        except FileNotFoundError:
            print(f"Error: File not found at {file_path}")
            return None
        except json.JSONDecodeError:
            print(f"Error: Could not decode JSON from {file_path}")
            return None

    def _write_json(self, data, file_path):
        """Writes data to a JSON file."""
        if not os.path.exists(os.path.dirname(file_path)):
            os.makedirs(os.path.dirname(file_path))
        with open(file_path, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=4, ensure_ascii=False)
        print(f"Successfully wrote {len(data)} items to {file_path}")

    def run(self):
        """
        Executes the full preprocessing pipeline: merging and normalizing scraped data.
        """
        print("======== Starting Data Preprocessing ========")
        if not os.path.exists(self.scraped_data_dir):
            print(f"Error: Scraped data directory not found at {self.scraped_data_dir}")
            return

        all_machines, all_keys = [], set()

        print("Reading files and collecting keys...")
        for filename in os.listdir(self.scraped_data_dir):
            if filename.endswith(".json"):
                filepath = os.path.join(self.scraped_data_dir, filename)
                data = self._read_json(filepath)
                if data:
                    for machine in data:
                        if "detail" in machine and isinstance(machine.get("detail"), dict):
                            machine.update(machine.pop("detail"))
                        all_machines.append(machine)
                        all_keys.update(machine.keys())
        
        print(f"Found {len(all_keys)} unique keys across {len(all_machines)} machines.")

        print("Normalizing machine objects...")
        normalized_machines = [{key: machine.get(key) for key in all_keys} for machine in all_machines]

        self._write_json(normalized_machines, self.output_file)
        print("======== Preprocessing Finished ========")

def run_preprocessing():
    """Initializes and runs the main Preprocessor."""
    preprocessor = Preprocessor()
    preprocessor.run()