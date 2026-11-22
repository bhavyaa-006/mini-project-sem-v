from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.api.deps import get_db, get_current_user
from app.models.user import User
from app.schemas.user import UserProfileResponse, UpdateProfileRequest

router = APIRouter(prefix="/user", tags=["user"])


@router.get("/profile", response_model=UserProfileResponse)
def get_profile(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    scans_count = current_user.scans.count()
    return UserProfileResponse(
        id=current_user.id,
        name=current_user.name,
        email=current_user.email,
        role=current_user.role,
        skin_type=current_user.skin_type,
        dietary_preferences=current_user.dietary_preferences or [],
        allergies=current_user.allergies or [],
        scans_count=scans_count,
        created_at=current_user.created_at.isoformat(),
    )


@router.put("/profile", response_model=UserProfileResponse)
def update_profile(
    payload: UpdateProfileRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    if payload.name is not None:
        current_user.name = payload.name
    if payload.skin_type is not None:
        current_user.skin_type = payload.skin_type
    if payload.dietary_preferences is not None:
        current_user.dietary_preferences = payload.dietary_preferences
    if payload.allergies is not None:
        current_user.allergies = payload.allergies
    db.commit()
    db.refresh(current_user)

    return UserProfileResponse(
        id=current_user.id,
        name=current_user.name,
        email=current_user.email,
        role=current_user.role,
        skin_type=current_user.skin_type,
        dietary_preferences=current_user.dietary_preferences or [],
        allergies=current_user.allergies or [],
        scans_count=current_user.scans.count(),
        created_at=current_user.created_at.isoformat(),
    )
