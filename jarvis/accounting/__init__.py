"""JARVIS Accounting Section.

This section contains all accounting-related applications:
- Bugetare: Invoice budget allocation system
- Statements: Bank statement parsing and transaction extraction

Future apps may include:
- Expense tracking
- Financial reporting
- Budget planning
"""
from flask import Blueprint

# Section-level blueprint
accounting_bp = Blueprint('accounting', __name__)

# Register apps within section
from .bugetare import bugetare_bp  # noqa: E402
from .statements import statements_bp  # noqa: E402

accounting_bp.register_blueprint(bugetare_bp, url_prefix='/bugetare')
accounting_bp.register_blueprint(statements_bp, url_prefix='/statements')
