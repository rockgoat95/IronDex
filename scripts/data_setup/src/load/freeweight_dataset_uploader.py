from __future__ import annotations

import json
import sys
import time
import uuid
from dataclasses import dataclass
from pathlib import Path
from typing import Optional

try:  # Package execution
    from ..utils.supabase_manager import SupabaseManager
except ImportError:  # Standalone execution fallback
    SRC_ROOT = Path(__file__).resolve().parents[1]
    if str(SRC_ROOT) not in sys.path:
        sys.path.append(str(SRC_ROOT))
    from utils.supabase_manager import SupabaseManager  # type: ignore

try:  # Package execution
    from ..load.exercise_translation import DATA_DIR as TRANSLATION_DATA_DIR
except ImportError:  # Standalone fallback
    from load.exercise_translation import (
        DATA_DIR as TRANSLATION_DATA_DIR,
    )  # type: ignore


DATA_DIR = TRANSLATION_DATA_DIR
IMAGES_DIR = DATA_DIR / "images"
SOURCE_JSON = DATA_DIR / "exercise_DB_freeweights_kor.json"
OUTPUT_JSON = DATA_DIR / "exercise_DB_freeweights_ready.json"
IMAGE_BUCKET = "freeweight_images"
SUPABASE_TABLE = "catalog.freeweights"
MAX_UPLOAD_RETRIES = 5
RETRY_DELAY_SECONDS = 2


@dataclass
class ImageInfo:
    uuid: str
    storage_path: str
    public_url: str


def _load_source_records() -> list[dict]:
    if not SOURCE_JSON.exists():
        raise FileNotFoundError(f"Source JSON not found: {SOURCE_JSON}")

    with SOURCE_JSON.open("r", encoding="utf-8") as fp:
        try:
            payload = json.load(fp)
        except json.JSONDecodeError as error:  # pragma: no cover - defensive
            raise RuntimeError(f"Invalid JSON in {SOURCE_JSON}") from error

    if not isinstance(payload, list):  # pragma: no cover - sanity check
        raise RuntimeError(
            f"Expected a list payload from {SOURCE_JSON}, got {type(payload).__name__}"
        )

    return payload


def _load_existing_output() -> dict[str, dict]:
    if not OUTPUT_JSON.exists():
        return {}

    with OUTPUT_JSON.open("r", encoding="utf-8") as fp:
        try:
            records = json.load(fp)
        except json.JSONDecodeError:
            return {}

    if not isinstance(records, list):
        return {}

    return {
        record.get("source_id"): record for record in records if record.get("source_id")
    }


def _find_local_image(exercise_id: str) -> Optional[Path]:
    matches = list(IMAGES_DIR.glob(f"{exercise_id}.*"))
    return matches[0] if matches else None


def _upload_image(
    manager: SupabaseManager,
    *,
    exercise_id: str,
    local_path: Path,
) -> ImageInfo | None:
    ext = local_path.suffix.lower()
    image_uuid = str(uuid.uuid4())
    storage_path = f"{image_uuid}{ext}"

    for attempt in range(1, MAX_UPLOAD_RETRIES + 1):
        try:
            public_url = manager.upload_from_local_path(
                bucket_name=IMAGE_BUCKET,
                file_path=str(local_path),
                destination_path=storage_path,
            )
            return ImageInfo(
                uuid=image_uuid,
                storage_path=storage_path,
                public_url=public_url,
            )
        except Exception as error:  # pragma: no cover - network interaction
            print(
                "[freeweight_uploader] Upload attempt "
                f"{attempt}/{MAX_UPLOAD_RETRIES} failed for {exercise_id}: {error}",
                file=sys.stderr,
            )
            if attempt == MAX_UPLOAD_RETRIES:
                break
            delay = RETRY_DELAY_SECONDS * attempt
            print(
                f"[freeweight_uploader] Retrying in {delay} seconds...",
                file=sys.stderr,
            )
            time.sleep(delay)

    print(
        f"[freeweight_uploader] Exhausted upload retries for {exercise_id}.",
        file=sys.stderr,
    )
    return None


def _build_record(exercise: dict, image_info: ImageInfo | None) -> dict:
    target = exercise.get("target")
    body_parts = [target] if target else []

    record = {
        "source_id": exercise.get("id"),
        "name": exercise.get("name"),
        "name_kor": exercise.get("name_kor"),
        "descriptions": exercise.get("description"),
        "body_parts": body_parts,
        "instructions": exercise.get("instructions", []),
        "equipment": exercise.get("equipment"),
        "difficulty": exercise.get("difficulty"),
        "category": exercise.get("category"),
        "secondary_muscles": exercise.get("secondaryMuscles", []),
    }

    if image_info:
        record.update(
            {
                "image_uuid": image_info.uuid,
                "image_storage_path": image_info.storage_path,
                "image_url": image_info.public_url,
            }
        )

    return record


def process_and_upload(save_only: bool = False) -> list[dict]:
    source_records = _load_source_records()
    existing_records = _load_existing_output()

    manager: SupabaseManager | None
    if save_only:
        manager = None
    else:
        manager = SupabaseManager()

    processed: list[dict] = []
    pending_failures: list[tuple[int, dict, Path]] = []

    for exercise in source_records:
        exercise_id = exercise.get("id")
        if not exercise_id:
            continue

        existing = existing_records.get(exercise_id, {})
        image_info: ImageInfo | None = None

        local_image_path: Optional[Path] = None

        if existing.get("image_storage_path") and existing.get("image_url"):
            image_info = ImageInfo(
                uuid=existing.get("image_uuid", ""),
                storage_path=existing["image_storage_path"],
                public_url=existing["image_url"],
            )
        elif manager:
            local_image_path = _find_local_image(exercise_id)
            if local_image_path:
                image_info = _upload_image(
                    manager,
                    exercise_id=exercise_id,
                    local_path=local_image_path,
                )
            else:
                print(
                    f"[freeweight_uploader] No local image found for {exercise_id}",
                    file=sys.stderr,
                )

        record_index = len(processed)
        record = _build_record(exercise, image_info)
        processed.append(record)

        if image_info is None and manager and local_image_path is not None:
            pending_failures.append((record_index, exercise, local_image_path))

    if manager and pending_failures:
        attempt_round = 1
        while pending_failures:
            pending_count = len(pending_failures)
            print(
                "[freeweight_uploader] Retrying "
                f"{pending_count} image uploads (round {attempt_round})."
            )
            progress = False
            remaining: list[tuple[int, dict, Path]] = []

            for record_index, exercise, local_image_path in pending_failures:
                exercise_id = exercise.get("id") or "(unknown)"
                image_info = _upload_image(
                    manager,
                    exercise_id=exercise_id,
                    local_path=local_image_path,
                )
                if image_info:
                    processed[record_index] = _build_record(exercise, image_info)
                    progress = True
                else:
                    remaining.append((record_index, exercise, local_image_path))

            if not progress:
                print(
                    "[freeweight_uploader] No progress during retry round. Remaining"
                    " items will be saved without images.",
                    file=sys.stderr,
                )
                for _, exercise, _ in remaining:
                    exercise_id = exercise.get("id")
                    print(
                        "[freeweight_uploader] Failed to upload image for "
                        f"{exercise_id}.",
                        file=sys.stderr,
                    )
                break

            pending_failures = remaining
            attempt_round += 1

    OUTPUT_JSON.parent.mkdir(parents=True, exist_ok=True)
    with OUTPUT_JSON.open("w", encoding="utf-8") as fp:
        json.dump(processed, fp, ensure_ascii=False, indent=2)

    print(f"[freeweight_uploader] Saved {len(processed)} records to {OUTPUT_JSON}")
    return processed


def upsert_records(records: list[dict]) -> None:
    if not records:
        print("[freeweight_uploader] No records to upsert. Skipping.")
        return

    payload: list[dict] = []
    for record in records:
        name = record.get("name")
        if not name:
            continue

        payload.append(
            {
                "name": name,
                "name_kor": record.get("name_kor"),
                "body_parts": record.get("body_parts") or [],
                "image_url": record.get("image_url"),
                "descriptions": record.get("descriptions"),
            }
        )

    if not payload:
        print("[freeweight_uploader] No valid records to upsert. Skipping.")
        return

    manager = SupabaseManager()
    manager.upsert_to_table(table_name=SUPABASE_TABLE, data=payload)


def main() -> None:
    records = process_and_upload(save_only=False)
    if records:
        upsert_records(records)


if __name__ == "__main__":
    main()
