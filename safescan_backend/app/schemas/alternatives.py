from typing import List
from pydantic import BaseModel


class AlternativesResponse(BaseModel):
    alternatives: List[dict]
    total: int
