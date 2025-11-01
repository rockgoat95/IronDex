from __future__ import annotations

import json
import sys
from pathlib import Path
from typing import Iterable, Optional

try:  # Support running within the package context
    from ..config.gemini import GENAI_API_KEY
    from ..process.prompts import FREEWEIGHT_EXERCISE_TRANSLATION_PROMPT
    from ..utils.gemini_manager import GeminiManager
except ImportError:  # Fallback when executed as a standalone script
    SRC_ROOT = Path(__file__).resolve().parents[1]
    if str(SRC_ROOT) not in sys.path:
        sys.path.append(str(SRC_ROOT))

    from config.gemini import GENAI_API_KEY
    from process.prompts import FREEWEIGHT_EXERCISE_TRANSLATION_PROMPT
    from utils.gemini_manager import GeminiManager


PROJECT_ROOT = Path(__file__).resolve().parents[4]
DATA_DIR = PROJECT_ROOT / "scripts" / "data_setup" / "data"
DEFAULT_SOURCE_FILE = DATA_DIR / "exercise_DB_freeweights.json"
DEFAULT_OUTPUT_FILE = DATA_DIR / "exercise_DB_freeweights_kor.json"


def translate_exercise_names(records: Iterable[dict]) -> list[dict]:
    """Translate exercise names to Korean using the Gemini API.

    If the Gemini API key is not set, the original records are returned unchanged.
    """
    exercises = list(records)
    if not exercises:
        return exercises

    if not GENAI_API_KEY:
        print(
            "GENAI_API_KEY is not set. Skipping Korean translation for exercises.",
            file=sys.stderr,
        )
        return exercises

    manager = GeminiManager()
    cache: dict[str, str] = {}
    translated_count = 0

    for exercise in exercises:
        name = exercise.get("name")
        if not name:
            continue

        # Respect existing translations on the record
        existing_translation = exercise.get("name_kor")
        if existing_translation:
            cache.setdefault(name, existing_translation)
            print(f"[translate] reuse existing: '{name}' -> '{existing_translation}'")
            continue

        cached_translation = cache.get(name)
        if cached_translation:
            exercise["name_kor"] = cached_translation
            print(f"[translate] reuse cached: '{name}' -> '{cached_translation}'")
            continue

        prompt = FREEWEIGHT_EXERCISE_TRANSLATION_PROMPT.format(exercise_name=name)

        try:
            response = manager.generate_content(prompt)
        except Exception as error:  # noqa: BLE001
            print(
                f"Failed to translate '{name}': {error}",
                file=sys.stderr,
            )
            continue

        translation = response.strip()
        if not translation:
            print(f"Empty translation result for '{name}'.", file=sys.stderr)
            continue

        exercise["name_kor"] = translation
        cache[name] = translation
        print(f"[translate] generated: '{name}' -> '{translation}'")
        translated_count += 1

    print(f"Translated {translated_count} exercise names to Korean.")
    return exercises


def translate_file(
    input_path: str | Path,
    output_path: Optional[str | Path] = None,
) -> Path:
    """Load exercise data from ``input_path`` and write translated JSON.

    Args:
        input_path: Source JSON file containing a list of exercise records.
        output_path: Optional custom output path. Defaults to ``<stem>_kor.json``.

    Returns:
        The path to the generated JSON file.
    """

    source = Path(input_path)
    if not source.exists():
        raise FileNotFoundError(f"Source dataset not found: {source}")

    with source.open("r", encoding="utf-8") as fp:
        try:
            records = json.load(fp)
        except json.JSONDecodeError as error:
            raise RuntimeError(f"Invalid JSON in dataset {source}") from error

    if not isinstance(records, list):
        raise RuntimeError(
            f"Expected dataset to be a list, received {type(records).__name__}"
        )

    translated_records = translate_exercise_names(records)

    target = (
        Path(output_path)
        if output_path is not None
        else source.with_name(f"{source.stem}_kor{source.suffix}")
    )
    target.parent.mkdir(parents=True, exist_ok=True)

    with target.open("w", encoding="utf-8") as fp:
        json.dump(translated_records, fp, ensure_ascii=False, indent=2)

    print(f"Saved translated dataset to {target}")
    return target


def main() -> None:
    translate_file(DEFAULT_SOURCE_FILE, DEFAULT_OUTPUT_FILE)


if __name__ == "__main__":
    main()
