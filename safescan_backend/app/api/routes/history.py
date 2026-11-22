from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from typing import List

from app.api.deps import get_db, get_current_user
from app.models.user import User
from app.schemas.history import ScanHistoryItem
from app.services.history_service import get_user_history

router = APIRouter(prefix="/history", tags=["history"])


@router.get("/", response_model=List[ScanHistoryItem])
def get_history(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    return get_user_history(db, str(current_user.id))
