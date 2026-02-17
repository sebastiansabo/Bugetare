"""Marketing Projects Module."""
from flask import Blueprint

marketing_bp = Blueprint('marketing', __name__)

from .routes import projects, budget, events, social, dashboard, admin, simulator  # noqa: E402, F401
