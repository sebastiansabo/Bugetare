"""User filter presets module."""
from flask import Blueprint

presets_bp = Blueprint('presets', __name__)

from . import routes  # noqa: E402, F401
