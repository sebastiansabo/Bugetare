"""Invoice templates domain."""
from flask import Blueprint

templates_bp = Blueprint('templates', __name__)

from . import routes  # noqa: E402, F401
