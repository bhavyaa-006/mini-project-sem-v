"""
Audit report generator engine re-exported for use in background tasks or reports.
"""
from app.services.report_service import generate_pdf_report

__all__ = ["generate_pdf_report"]
