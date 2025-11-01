import http.client
import json
import os
import sys
import time
from pathlib import Path
from typing import Tuple

from dotenv import load_dotenv

load_dotenv()

RAPID_API_HOST = "exercisedb.p.rapidapi.com"
RAPID_API_KEY = os.getenv("RAPID_API_KEY")

PAGE_LIMIT = 10
REQUEST_DELAY_SECONDS = float(os.getenv("EXERCISE_DB_REQUEST_DELAY", "0"))

PROJECT_ROOT = Path(__file__).resolve().parents[4]
DATA_DIR = PROJECT_ROOT / "scripts" / "data_setup" / "data"
EXERCISE_DATA_FILE = DATA_DIR / "exercise_DB_freeweights.json"
IMAGES_DIR = DATA_DIR / "images"


def _fetch_all_exercises(limit: int = PAGE_LIMIT) -> list[dict]:
    if not RAPID_API_KEY:
        raise ValueError("RAPID_API_KEY is not set")

    if limit <= 0:
        raise ValueError("limit must be greater than zero")

    headers = {
        "x-rapidapi-key": RAPID_API_KEY,
        "x-rapidapi-host": RAPID_API_HOST,
    }

    exercises: list[dict] = []
    offset = 0

    while True:
        conn = http.client.HTTPSConnection(RAPID_API_HOST)
        try:
            path = f"/exercises?limit={limit}&offset={offset}"
            conn.request("GET", path, headers=headers)

            res = conn.getresponse()
            raw = res.read().decode("utf-8", errors="replace")

            try:
                payload = json.loads(raw)
            except json.JSONDecodeError as exc:
                raise RuntimeError(
                    f"Unexpected response at offset {offset}: {raw}"
                ) from exc

            if not isinstance(payload, list):
                raise RuntimeError(f"Expected list payload but received: {payload}")

            if not payload:
                break

            exercises.extend(payload)
            offset += limit
        finally:
            conn.close()

        if REQUEST_DELAY_SECONDS > 0:
            time.sleep(REQUEST_DELAY_SECONDS)

    return exercises


def _fetch_image(exercise_id: str) -> Tuple[bytes, str]:
    if not RAPID_API_KEY:
        raise ValueError("RAPID_API_KEY is not set")

    headers = {
        "x-rapidapi-key": RAPID_API_KEY,
        "x-rapidapi-host": RAPID_API_HOST,
    }

    conn = http.client.HTTPSConnection(RAPID_API_HOST)
    try:
        path = f"/image/?exerciseId={exercise_id}&resolution=720"
        conn.request("GET", path, headers=headers)

        res = conn.getresponse()
        content_type = res.getheader("Content-Type", "")

        if res.status != 200:
            raw = res.read().decode("utf-8", errors="replace")
            raise RuntimeError(
                "Failed to fetch image for "
                f"{exercise_id}: {res.status} {res.reason}. Body: {raw}"
            )

        image_data = res.read()
        return image_data, content_type
    finally:
        conn.close()


def save_to_file(records: list[dict], output_path: Path) -> None:
    output_path.parent.mkdir(parents=True, exist_ok=True)
    with output_path.open("w", encoding="utf-8") as fp:
        json.dump(records, fp, ensure_ascii=False, indent=2)


def get_exercises() -> None:
    exercises = _fetch_all_exercises()
    save_to_file(exercises, EXERCISE_DATA_FILE)

    print(f"Saved {len(exercises)} exercises to {EXERCISE_DATA_FILE}")


def _extension_from_content_type(content_type: str) -> str:
    mapping = {
        "image/gif": ".gif",
        "image/jpeg": ".jpg",
        "image/jpg": ".jpg",
        "image/png": ".png",
        "image/webp": ".webp",
    }

    normalized = content_type.split(";")[0].strip().lower()
    return mapping.get(normalized, ".bin")


def download_images_from_dataset() -> None:
    if not EXERCISE_DATA_FILE.exists():
        raise FileNotFoundError(
            f"Dataset not found at {EXERCISE_DATA_FILE}. Run get_exercises() first."
        )

    with EXERCISE_DATA_FILE.open("r", encoding="utf-8") as fp:
        try:
            records = json.load(fp)
        except json.JSONDecodeError as exc:
            raise RuntimeError(f"Invalid JSON in dataset {EXERCISE_DATA_FILE}") from exc

    if not isinstance(records, list):
        raise RuntimeError(
            f"Expected dataset to be a list, received {type(records).__name__}"
        )

    IMAGES_DIR.mkdir(parents=True, exist_ok=True)

    for record in records:
        exercise_id = str(record.get("id") or record.get("exerciseId"))
        if not exercise_id or exercise_id.lower() == "none":
            print("Skipping record without valid id", file=sys.stderr)
            continue

        existing_image = next(IMAGES_DIR.glob(f"{exercise_id}.*"), None)
        if existing_image is not None:
            message = (
                f"Image already exists for {exercise_id}: "
                f"{existing_image.name}. Skipping download."
            )
            print(message, file=sys.stderr)
            continue

        try:
            image_bytes, content_type = _fetch_image(exercise_id)
        except Exception as err:  # noqa: BLE001
            print(
                f"Failed to download image for {exercise_id}: {err}",
                file=sys.stderr,
            )
            continue

        extension = _extension_from_content_type(content_type)
        output_path = IMAGES_DIR / f"{exercise_id}{extension}"

        with output_path.open("wb") as fp:
            fp.write(image_bytes)

        print(f"Downloaded image for {exercise_id} → {output_path.name}")

        if REQUEST_DELAY_SECONDS > 0:
            time.sleep(REQUEST_DELAY_SECONDS)


if __name__ == "__main__":
    download_images_from_dataset()
