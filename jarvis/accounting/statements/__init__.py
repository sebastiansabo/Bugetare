"""Bank Statement Parsing Module.

Part of JARVIS Accounting Section.

Features:
- Parse UniCredit bank statement PDFs
- Extract card transactions automatically
- Match transactions to known vendors/suppliers
- Generate invoice records for Bugetare module
"""
from flask import Blueprint

statements_bp = Blueprint('statements', __name__,
                          template_folder='../../templates/accounting/statements')

# Import routes to register them
from . import routes  # noqa: E402, F401
