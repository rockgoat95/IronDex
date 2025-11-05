from __future__ import annotations

import json
import sys
import time
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, List, Optional

try:  # Package execution
    from ..utils.gemini_manager import GeminiManager
    from ..utils.supabase_manager import SupabaseManager
    from .ai_preprocessor import MachineProcessor
except ImportError:  # Standalone execution fallback
    SRC_ROOT = Path(__file__).resolve().parents[1]
    if str(SRC_ROOT) not in sys.path:
        sys.path.append(str(SRC_ROOT))
    from process.ai_preprocessor import MachineProcessor  # type: ignore
    from utils.gemini_manager import GeminiManager  # type: ignore
    from utils.supabase_manager import SupabaseManager  # type: ignore

PROJECT_ROOT = Path(__file__).resolve().parents[4]
DATA_DIR = PROJECT_ROOT / "scripts" / "data_setup" / "data"
OUTPUT_LOG = DATA_DIR / "machine_body_parts_classification.json"
CATALOG_SCHEMA = "catalog"
MACHINES_TABLE = "machines"
MAX_ATTEMPTS = 3
RETRY_DELAY_SECONDS = 2.0


ALLOWED_BODY_PARTS: tuple[str, ...] = (
    "abductors",
    "abs",
    "adductors",
    "biceps",
    "calves",
    "cardiovascular system",
    "delts",
    "forearms",
    "glutes",
    "hamstrings",
    "lats",
    "levator scapulae",
    "pectorals",
    "quads",
    "serratus anterior",
    "spine",
    "traps",
    "triceps",
    "upper back",
)

CANONICAL_BODY_PARTS: dict[str, str] = {
    # Direct matches
    **{part: part for part in ALLOWED_BODY_PARTS},
    # Synonyms → allowed labels
    "chest": "pectorals",
    "pecs": "pectorals",
    "pectoral": "pectorals",
    "pectoralis": "pectorals",
    "abdominal": "abs",
    "abdominals": "abs",
    "core": "abs",
    "core muscles": "abs",
    "obliques": "abs",
    "hip": "glutes",
    "hips": "glutes",
    "glute": "glutes",
    "gluteus": "glutes",
    "gluteus maximus": "glutes",
    "butt": "glutes",
    "buttocks": "glutes",
    "quadriceps": "quads",
    "quad": "quads",
    "hamstring": "hamstrings",
    "posterior chain": "hamstrings",
    "lat": "lats",
    "latissimus dorsi": "lats",
    "shoulder": "delts",
    "shoulders": "delts",
    "deltoid": "delts",
    "deltoids": "delts",
    "trapezius": "traps",
    "trap": "traps",
    "forearm": "forearms",
    "calf": "calves",
    "calf muscles": "calves",
    "cardio": "cardiovascular system",
    "cardiovascular": "cardiovascular system",
    "spinal erectors": "spine",
    "erector spinae": "spine",
    "lower back": "spine",
    "mid back": "upper back",
    "upper-back": "upper back",
    "back": "upper back",
    "serratus": "serratus anterior",
    "levator": "levator scapulae",
    "levator scapula": "levator scapulae",
    "adductor": "adductors",
    "adductor muscles": "adductors",
    "abductor": "abductors",
    "abductor muscles": "abductors",
}


@dataclass
class MachineRecord:
    machine_id: str
    name: str
    brand_name: str
    body_parts: Optional[List[str]] = None


class BodyPartsClassifier:
    """Classifies machine body parts using Gemini and updates Supabase."""

    def __init__(
        self,
        *,
        supabase_manager: Optional[SupabaseManager] = None,
        gemini_manager: Optional[GeminiManager] = None,
        delay_seconds: float = 1.0,
        retry_delay_seconds: float = RETRY_DELAY_SECONDS,
        persist_log: bool = False,
    ) -> None:
        self.manager = supabase_manager or SupabaseManager()
        self.gemini = gemini_manager or GeminiManager()
        self.processor = MachineProcessor(self.gemini)
        self.delay_seconds = delay_seconds
        self.retry_delay_seconds = retry_delay_seconds
        self.persist_log = persist_log

    def fetch_target_machines(self, limit: Optional[int] = None) -> list[MachineRecord]:
        """Fetch machines missing body parts information."""
        query = (
            self.manager.client.postgrest.schema(CATALOG_SCHEMA)
            .from_(MACHINES_TABLE)
            .select("id,name,brand_name,body_parts")
        )

        response = query.execute()
        rows = response.data or []

        targets: list[MachineRecord] = []
        for row in rows:
            body_parts = row.get("body_parts")
            if body_parts:  # Skip if already populated
                continue

            record = MachineRecord(
                machine_id=str(row.get("id")),
                name=str(row.get("name", "")),
                brand_name=(
                    str(row.get("brand_name", "")) if row.get("brand_name") else ""
                ),
                body_parts=body_parts,
            )
            if not record.name:
                continue
            targets.append(record)

        if limit is not None:
            return targets[:limit]
        return targets

    def _call_classifier(self, record: MachineRecord) -> list[str]:
        """Call Gemini classifier and return raw body part list."""
        response = self.processor.classify_body_parts(
            machine_name=record.name,
            brand=record.brand_name or "",
        )

        if not response:
            return []

        cleaned: list[str] = []
        for part in response:
            if isinstance(part, str):
                text = part.strip()
                if text and text not in cleaned:
                    cleaned.append(text)
        return cleaned

    def _canonicalize_body_parts(self, parts: list[str]) -> list[str]:
        """Normalize body parts using the canonical mapping."""
        canonical: list[str] = []
        for part in parts:
            key = part.casefold()
            mapped = CANONICAL_BODY_PARTS.get(key)
            if not mapped:
                return []
            if mapped not in canonical:
                canonical.append(mapped)
        return canonical

    def classify_machine(self, record: MachineRecord) -> list[str]:
        """Classify a machine with retries until results are valid."""
        for attempt in range(1, MAX_ATTEMPTS + 1):
            raw_parts = self._call_classifier(record)
            canonical = self._canonicalize_body_parts(raw_parts)
            if canonical:
                return canonical

            print(
                "[body_parts] Invalid classification attempt "
                f"{attempt}/{MAX_ATTEMPTS} for {record.name}: {raw_parts}"
            )

            if attempt < MAX_ATTEMPTS:
                time.sleep(self.retry_delay_seconds)

        return []

    def update_machine(self, machine_id: str, body_parts: list[str]) -> None:
        """Update Supabase record with classified body parts."""
        payload = {"body_parts": body_parts}
        print("[body_parts] Executing update", f"id={machine_id}", f"payload={payload}")
        response = (
            self.manager.client.postgrest.schema(CATALOG_SCHEMA)
            .from_(MACHINES_TABLE)
            .update(payload)
            .eq("id", machine_id)
            .execute()
        )
        response_data = getattr(response, "data", None)
        print("[body_parts] Supabase update response", f"data={response_data}")

    def save_results(self, results: Iterable[dict]) -> None:
        """Persist classification results to JSON for auditing."""
        if not self.persist_log:
            return

        results = list(results)
        if not results:
            return

        DATA_DIR.mkdir(parents=True, exist_ok=True)

        existing: dict[str, dict] = {}
        if OUTPUT_LOG.exists():
            try:
                with OUTPUT_LOG.open("r", encoding="utf-8") as file:
                    payload = json.load(file)
                    if isinstance(payload, list):
                        existing = {
                            item.get("machine_id"): item
                            for item in payload
                            if item.get("machine_id")
                        }
            except json.JSONDecodeError:
                existing = {}

        for item in results:
            identifier = item.get("machine_id")
            if identifier:
                existing[identifier] = item

        with OUTPUT_LOG.open("w", encoding="utf-8") as file:
            json.dump(list(existing.values()), file, ensure_ascii=False, indent=2)

    def run(self, *, limit: Optional[int] = None, dry_run: bool = False) -> list[dict]:
        """Classify machines and update Supabase."""
        machines = self.fetch_target_machines(limit=limit)
        print(f"[body_parts] Target machines: {len(machines)}")

        results: list[dict] = []
        for index, record in enumerate(machines, start=1):
            print(f"[body_parts] ({index}/{len(machines)}) {record.name}")
            body_parts = self.classify_machine(record)
            if not body_parts:
                print(f"[body_parts] Skipping '{record.name}' due to empty result")
                continue

            result = {
                "machine_id": record.machine_id,
                "name": record.name,
                "brand_name": record.brand_name,
                "body_parts": body_parts,
            }
            results.append(result)

            if dry_run:
                print(
                    "[body_parts] Dry run - not updating Supabase for "
                    f"{record.machine_id}"
                )
            else:
                self.update_machine(record.machine_id, body_parts)
                print(
                    "[body_parts] Updated machine "
                    f"{record.machine_id} with {body_parts}"
                )
                time.sleep(self.delay_seconds)

        self.save_results(results)
        print(f"[body_parts] Completed with {len(results)} updates.")
        return results


def main(
    *,
    limit: Optional[int] = None,
    dry_run: bool = False,
    persist_log: bool = False,
) -> list[dict] | None:
    classifier = BodyPartsClassifier(persist_log=persist_log)
    return classifier.run(limit=limit, dry_run=dry_run)


if __name__ == "__main__":
    main()
