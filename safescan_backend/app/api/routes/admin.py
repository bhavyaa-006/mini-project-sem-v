import uuid
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.api.deps import get_db, require_admin
from app.models.hazard_ingredient import HazardIngredient
from app.models.user import User

router = APIRouter(prefix="/admin", tags=["admin"])


@router.get("/hazards")
def list_hazards(
    db: Session = Depends(get_db),
    _: User = Depends(require_admin),
):
    return db.query(HazardIngredient).all()


@router.delete("/hazards/{hazard_id}")
def delete_hazard(
    hazard_id: str,
    db: Session = Depends(get_db),
    _: User = Depends(require_admin),
):
    try:
        h_uuid = uuid.UUID(hazard_id) if isinstance(hazard_id, str) else hazard_id
    except (ValueError, TypeError):
        h_uuid = hazard_id

    record = db.query(HazardIngredient).filter(HazardIngredient.id == h_uuid).first()
    if not record:
        raise HTTPException(status_code=404, detail="Hazard ingredient not found")
    db.delete(record)
    db.commit()
    return {"detail": "Deleted"}
