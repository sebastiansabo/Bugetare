import os

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TEMPLATE_PATH = os.path.join(BASE_DIR, 'Template', 'Template.xlsx')
INVOICES_DIR = os.path.join(BASE_DIR, 'Invoices')
