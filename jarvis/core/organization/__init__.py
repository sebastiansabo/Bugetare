"""Organization domain - companies, departments, brands."""
from flask import Blueprint

org_bp = Blueprint('organization', __name__)

from . import routes  # noqa: E402, F401
