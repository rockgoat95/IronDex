from typing import Any

from pydantic import BaseModel


class Machine(BaseModel):
    brand: str
    name: str
    image_url: str
    detail: Any | None = None


class ScraperConfig(BaseModel):
    brand_name: str
    item_selector: str
    name_selector: str  # item selector 내부에서 식별만되면 가능
    image_selector: str  # item selector 내부에서 식별만되면 가능
    machine_series: str = ""
