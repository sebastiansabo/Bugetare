import openpyxl
from dataclasses import dataclass
from typing import Optional
from config import TEMPLATE_PATH


@dataclass
class DepartmentUnit:
    """Represents a single department unit from the Structure sheet."""
    company: str
    brand: Optional[str]
    department: str
    subdepartment: Optional[str]
    manager: str
    marketing: str

    @property
    def display_name(self) -> str:
        """Human-readable name for display in UI."""
        parts = [self.company]
        if self.brand:
            parts.append(self.brand)
        parts.append(self.department)
        if self.subdepartment:
            parts.append(self.subdepartment)
        return ' > '.join(parts)

    @property
    def unique_key(self) -> str:
        """Unique identifier for this department unit."""
        return f"{self.company}|{self.brand or ''}|{self.department}|{self.subdepartment or ''}"


@dataclass
class InvoiceAllocation:
    """Represents a single allocation line for an invoice."""
    submission_date: str
    company: str
    supplier: str
    invoice_template: str
    invoice_number: str
    invoice_date: str
    invoice_value: float
    allocation: float  # Percentage as decimal (0.5 = 50%)
    department: str
    subdepartment: Optional[str]
    brand: Optional[str]
    responsible: str
    drive_link: str
    reinvoice_to: Optional[str] = None  # Company to reinvoice this cost to


def load_structure() -> list[DepartmentUnit]:
    """Load the organizational structure from the Template file."""
    wb = openpyxl.load_workbook(TEMPLATE_PATH, read_only=True)
    ws = wb['Structure']

    units = []
    for row in ws.iter_rows(min_row=2, values_only=True):  # Skip header
        if row[0] or row[2]:  # Has company or department
            unit = DepartmentUnit(
                company=row[0] or '',
                brand=row[1],
                department=row[2] or '',
                subdepartment=row[3],
                manager=row[4] or '',
                marketing=row[5] or ''
            )
            units.append(unit)

    wb.close()
    return units


def get_companies() -> list[str]:
    """Get unique list of companies."""
    units = load_structure()
    return sorted(set(u.company for u in units if u.company))


def get_brands_for_company(company: str) -> list[str]:
    """Get brands available for a specific company."""
    units = load_structure()
    brands = set()
    for u in units:
        if u.company == company and u.brand:
            brands.add(u.brand)
    return sorted(brands)


def get_departments_for_company(company: str) -> list[str]:
    """Get departments available for a specific company."""
    units = load_structure()
    return sorted(set(u.department for u in units if u.company == company and u.department))


def get_subdepartments(company: str, department: str) -> list[str]:
    """Get subdepartments for a specific company and department."""
    units = load_structure()
    subdepts = set()
    for u in units:
        if u.company == company and u.department == department and u.subdepartment:
            subdepts.add(u.subdepartment)
    return sorted(subdepts)


def get_manager(company: str, department: str, subdepartment: Optional[str] = None) -> str:
    """Get the manager for a specific department."""
    units = load_structure()
    for u in units:
        if u.company == company and u.department == department:
            if subdepartment is None or u.subdepartment == subdepartment:
                return u.manager
    return ''
