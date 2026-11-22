import os
import uuid
from fastapi import APIRouter, Depends, HTTPException
from fastapi.responses import FileResponse
from sqlalchemy.orm import Session

from app.api.deps import get_db, get_current_user
from app.models.scan import Scan
from app.models.user import User
from app.services.report_service import generate_pdf_report

router = APIRouter(prefix="/report", tags=["report"])


@router.get("/{scan_id}/pdf")
def download_report(
    scan_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    try:
        scan_uuid = uuid.UUID(scan_id) if isinstance(scan_id, str) else scan_id
    except (ValueError, TypeError):
        scan_uuid = scan_id

    scan = db.query(Scan).filter(
        Scan.id == scan_uuid,
        Scan.user_id == current_user.id
    ).first()
    if not scan:
        raise HTTPException(status_code=404, detail="Scan not found")

    pdf_path = generate_pdf_report(scan)
    if not pdf_path or not os.path.exists(pdf_path):
        raise HTTPException(status_code=500, detail="Could not generate report")

    return FileResponse(
        path=pdf_path,
        media_type="application/pdf",
        filename=f"SafeScan_Report_{scan_id[:8]}.pdf",
    )
