import json
import os

from process import prompts
from utils.data_repository import DataRepository
from utils.gemini_manager import GeminiManager


class MachineProcessor:
    def __init__(self, gemini_manager: GeminiManager):
        self.gemini = gemini_manager

    def _create_prompt(self, prompt_template: str, **kwargs) -> str:
        return prompt_template.format(**kwargs)

    def _call_gemini(self, prompt: str) -> str:
        return self.gemini.generate_content(prompt)

    def format_name(self, machine_name: str, brand: str, brand_context: str) -> str:
        prompt = self._create_prompt(
            prompts.FORMATTING_PROMPT, machine_name=machine_name, brand=brand
        )
        prompt += f"\n\n{brand_context}"
        return self._call_gemini(prompt)

    def translate_name(self, machine_name: str, brand: str, brand_context: str) -> str:
        prompt = self._create_prompt(
            prompts.TRANSLATION_PROMPT, machine_name=machine_name, brand=brand
        )
        prompt += f"\n\n{brand_context}"
        return self._call_gemini(prompt)

    def classify_body_parts(self, machine_name: str, brand: str) -> list[str]:
        prompt = self._create_prompt(
            prompts.CLASSIFICATION_PROMPT, machine_name=machine_name, brand=brand
        )
        result = self._call_gemini(prompt)
        try:
            return json.loads(result)
        except json.JSONDecodeError:
            print(
                f"Warning: Failed to decode JSON for classification of '{machine_name}'"
                ". Response: {result}"
            )
            return []


class PreprocessingOrchestrator:
    def __init__(self, output_path: str):
        self.output_path = output_path
        self.repository = DataRepository()
        self.gemini_manager = GeminiManager()
        self.processor = MachineProcessor(self.gemini_manager)
        self.results = []
        self.processed_items = set()
        self.brand_context_cache = {}

    def _load_existing_data(self):
        if os.path.exists(self.output_path):
            try:
                with open(self.output_path, "r", encoding="utf-8") as f:
                    self.results = json.load(f)
                    self.processed_items = {
                        (item["brand"], item["name"]) for item in self.results
                    }
                print(
                    f"Load complete: {len(self.results)} existing items "
                    "loaded from {self.output_path}."
                )
            except (json.JSONDecodeError, IOError) as e:
                print(
                    f"Failed to load existing file, starting from scratch. Error: {e}"
                )
                self.results = []
                self.processed_items = set()

    def _save_results(self):
        if self.results:
            print("\nSaving results...")
            os.makedirs(os.path.dirname(self.output_path), exist_ok=True)
            with open(self.output_path, "w", encoding="utf-8") as f:
                json.dump(self.results, f, indent=2, ensure_ascii=False)
            print(
                f"Save complete: {len(self.results)} items saved to {self.output_path}."
            )
        else:
            print("No results to save.")

    def _get_brand_context(
        self, brand: str, purpose: str = "format"
    ) -> tuple[list, str] | tuple[None, None]:
        cache_key = (brand, purpose)
        if cache_key in self.brand_context_cache:
            return self.brand_context_cache[cache_key]

        machines = []
        if purpose == "translate":
            preprocessed_file_path = "/home/user/IronDex/scripts/data_setup/init_data/preprocessed_machine_names.json"
            if not os.path.exists(preprocessed_file_path):
                print(f"Warning: {preprocessed_file_path} not found for translation.")
                return None, None
            with open(preprocessed_file_path, "r", encoding="utf-8") as f:
                all_machines_from_json = json.load(f)

            machines_for_brand = [
                item for item in all_machines_from_json if item["brand"] == brand
            ]
            machines = [
                {"name": item["preprocessed_name"], "original_name": item["name"]}
                for item in machines_for_brand
            ]
        else:  # format purpose
            machines = self.repository.get_brand_machines(brand)

        if not machines:
            return None, None

        machine_list_str = "\n".join([f"- {m['name']}" for m in machines])
        brand_context = prompts.BRAND_CONTEXT_PROMPT.format(
            brand=brand, machine_list=machine_list_str
        )

        self.brand_context_cache[cache_key] = (machines, brand_context)
        return machines, brand_context

    def _process_machine(
        self, machine: dict, brand: str, brand_context: str, purpose: str = "format"
    ):
        machine_name_to_process = machine["name"]
        original_machine_name = machine.get("original_name", machine_name_to_process)
        print(f"Processing: {brand} - {original_machine_name}")

        result_name = ""
        if purpose == "format":
            formatted_name = self.processor.format_name(
                machine_name_to_process, brand, brand_context
            )
            if not formatted_name or not formatted_name.strip():
                print(
                    f"Warning: Formatting response for '{machine_name_to_process}' is empty."
                )
                return
            result_name = formatted_name
            print(f"Formatted: {brand} - {machine_name_to_process} -> {result_name}")

        elif purpose == "translate":
            translated_name = self.processor.translate_name(
                machine_name_to_process, brand, brand_context
            )
            if not translated_name or not translated_name.strip():
                print(
                    f"Warning: Translation response for '{machine_name_to_process}' is empty."
                )
                return
            result_name = translated_name
            print(f"Translated: {brand} - {machine_name_to_process} -> {result_name}")

        self.results.append(
            {
                "brand": brand,
                "name": original_machine_name,
                "name_kor": result_name.strip(),
            }
        )
        self.processed_items.add((brand, original_machine_name))

    def run(self, purpose: str = "format"):
        self._load_existing_data()
        try:
            brands = self.repository.get_brand_names()
            print(f"Brands found: {brands}")
            for brand in brands:
                machines, brand_context = self._get_brand_context(
                    brand, purpose=purpose
                )
                if not machines or not brand_context:
                    continue

                is_cached = self.gemini_manager.update_model_with_context(
                    "이후 요청에서 해당 브랜드의 머신 목록을 참고해주세요.",
                    brand_context,
                )

                for machine in machines:
                    original_name = machine.get("original_name", machine["name"])
                    if (brand, original_name) in self.processed_items:
                        continue

                    self._process_machine(
                        machine,
                        brand,
                        brand_context if not is_cached else "",
                        purpose=purpose,
                    )

        except (KeyboardInterrupt, Exception) as e:
            print(f"\nError or interruption occurred: {e}")
        finally:
            self._save_results()


def main():
    output_path = (
        "/home/user/IronDex/scripts/data_setup/init_data/translated_machine_names.json"
    )
    orchestrator = PreprocessingOrchestrator(output_path=output_path)
    orchestrator.run(purpose="translate")


if __name__ == "__main__":
    main()
