from sqlalchemy.orm import DeclarativeBase


class Base(DeclarativeBase):
    pass


# Import all models here so Alembic can discover them
from app.models.user import User          # noqa: F401, E402
from app.models.product import Product    # noqa: F401, E402
from app.models.ingredient import Ingredient  # noqa: F401, E402
from app.models.hazard_ingredient import HazardIngredient  # noqa: F401, E402
from app.models.scan import Scan          # noqa: F401, E402
from app.models.result import Result      # noqa: F401, E402
