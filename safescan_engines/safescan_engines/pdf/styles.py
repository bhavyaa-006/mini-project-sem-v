from reportlab.lib.colors import HexColor
from reportlab.lib.enums import TA_CENTER
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet


PRIMARY_GREEN = HexColor("#14683F")
MINT_BG = HexColor("#F3F9F5")
CARD_BG = HexColor("#FFFFFF")
BORDER_MINT = HexColor("#CFE5D8")
TEXT_DARK = HexColor("#111827")
TEXT_MUTED = HexColor("#4B5563")

GRADE_COLORS = {
    "A": HexColor("#15803D"),
    "B": HexColor("#65A30D"),
    "C": HexColor("#CA8A04"),
    "D": HexColor("#EA580C"),
    "E": HexColor("#DC2626"),
}
STATUS_COLORS = {
    "PASS": HexColor("#15803D"),
    "FAIL": HexColor("#DC2626"),
    "UNKNOWN": HexColor("#D97706"),
    "Good": HexColor("#15803D"),
    "Avoid": HexColor("#DC2626"),
    "Caution": HexColor("#D97706"),
}


def get_report_styles() -> dict[str, ParagraphStyle]:
    base = getSampleStyleSheet()
    return {
        "Title": ParagraphStyle(
            "SafeScanTitle", parent=base["Title"], fontName="Helvetica-Bold",
            fontSize=18, leading=22, textColor=CARD_BG, alignment=TA_CENTER,
        ),
        "Subtitle": ParagraphStyle(
            "SafeScanSubtitle", parent=base["Normal"], fontName="Helvetica",
            fontSize=9, leading=12, textColor=CARD_BG, alignment=TA_CENTER,
        ),
        "SectionHeader": ParagraphStyle(
            "SafeScanSectionHeader", parent=base["Heading2"], fontName="Helvetica-Bold",
            fontSize=12, leading=15, textColor=PRIMARY_GREEN, spaceBefore=8, spaceAfter=5,
        ),
        "BodyText": ParagraphStyle(
            "SafeScanBody", parent=base["BodyText"], fontName="Helvetica",
            fontSize=8.5, leading=12, textColor=TEXT_DARK,
        ),
        "SmallMuted": ParagraphStyle(
            "SafeScanSmallMuted", parent=base["Normal"], fontName="Helvetica",
            fontSize=7.5, leading=10, textColor=TEXT_MUTED,
        ),
        "BadgeText": ParagraphStyle(
            "SafeScanBadge", parent=base["Normal"], fontName="Helvetica-Bold",
            fontSize=8, leading=10, textColor=CARD_BG, alignment=TA_CENTER,
        ),
    }