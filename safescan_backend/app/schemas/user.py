from typing import Optional, List
from uuid import UUID
from pydantic import BaseModel, EmailStr


class UserProfileResponse(BaseModel):
    id: UUID
    name: str
    email: EmailStr
    role: str
    skin_type: Optional[str] = None
    dietary_preferences: List[str] = []
    allergies: List[str] = []
    scans_count: int = 0
    created_at: str

    class Config:
        from_attributes = True


class UpdateProfileRequest(BaseModel):
    name: Optional[str] = None
    skin_type: Optional[str] = None
    dietary_preferences: Optional[List[str]] = None
    allergies: Optional[List[str]] = None
