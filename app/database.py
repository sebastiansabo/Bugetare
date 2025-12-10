import os
from datetime import datetime
from typing import Optional

import psycopg2
from psycopg2.extras import RealDictCursor

# PostgreSQL connection - DATABASE_URL is required
DATABASE_URL = os.environ.get('DATABASE_URL')

if not DATABASE_URL:
    raise ValueError("DATABASE_URL environment variable is required. Set it to your PostgreSQL connection string.")


def get_db():
    """Get PostgreSQL database connection."""
    return psycopg2.connect(DATABASE_URL)


def get_cursor(conn):
    """Get cursor with dict row factory."""
    return conn.cursor(cursor_factory=RealDictCursor)


def get_placeholder():
    """Get PostgreSQL placeholder."""
    return '%s'


def init_db():
    """Initialize database tables."""
    conn = get_db()
    cursor = get_cursor(conn)

    # PostgreSQL table definitions
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS invoices (
            id SERIAL PRIMARY KEY,
            supplier TEXT NOT NULL,
            invoice_template TEXT,
            invoice_number TEXT NOT NULL UNIQUE,
            invoice_date DATE NOT NULL,
            invoice_value REAL NOT NULL,
            currency TEXT DEFAULT 'RON',
            value_ron REAL,
            value_eur REAL,
            exchange_rate REAL,
            drive_link TEXT,
            comment TEXT,
            deleted_at TIMESTAMP,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ''')

    cursor.execute('''
        CREATE TABLE IF NOT EXISTS allocations (
            id SERIAL PRIMARY KEY,
            invoice_id INTEGER NOT NULL REFERENCES invoices(id) ON DELETE CASCADE,
            company TEXT NOT NULL,
            brand TEXT,
            department TEXT NOT NULL,
            subdepartment TEXT,
            allocation_percent REAL NOT NULL,
            allocation_value REAL NOT NULL,
            responsible TEXT,
            reinvoice_to TEXT,
            reinvoice_brand TEXT,
            reinvoice_department TEXT,
            reinvoice_subdepartment TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ''')

    cursor.execute('''
        CREATE TABLE IF NOT EXISTS invoice_templates (
            id SERIAL PRIMARY KEY,
            name TEXT NOT NULL UNIQUE,
            template_type TEXT DEFAULT 'fixed',
            supplier TEXT,
            supplier_vat TEXT,
            customer_vat TEXT,
            currency TEXT DEFAULT 'RON',
            description TEXT,
            invoice_number_regex TEXT,
            invoice_date_regex TEXT,
            invoice_value_regex TEXT,
            date_format TEXT DEFAULT '%Y-%m-%d',
            supplier_regex TEXT,
            supplier_vat_regex TEXT,
            customer_vat_regex TEXT,
            currency_regex TEXT,
            sample_invoice_path TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ''')

    cursor.execute('''
        CREATE TABLE IF NOT EXISTS department_structure (
            id SERIAL PRIMARY KEY,
            company TEXT NOT NULL,
            brand TEXT,
            department TEXT NOT NULL,
            subdepartment TEXT,
            manager TEXT,
            marketing TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ''')

    cursor.execute('''
        CREATE TABLE IF NOT EXISTS companies (
            id SERIAL PRIMARY KEY,
            company TEXT NOT NULL UNIQUE,
            brands TEXT,
            vat TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ''')

    cursor.execute('''
        CREATE TABLE IF NOT EXISTS connectors (
            id SERIAL PRIMARY KEY,
            connector_type TEXT NOT NULL,
            name TEXT NOT NULL,
            status TEXT DEFAULT 'disconnected',
            config JSONB DEFAULT '{}',
            credentials JSONB DEFAULT '{}',
            last_sync TIMESTAMP,
            last_error TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ''')

    cursor.execute('''
        CREATE TABLE IF NOT EXISTS connector_sync_log (
            id SERIAL PRIMARY KEY,
            connector_id INTEGER NOT NULL REFERENCES connectors(id) ON DELETE CASCADE,
            sync_type TEXT NOT NULL,
            status TEXT NOT NULL,
            invoices_found INTEGER DEFAULT 0,
            invoices_imported INTEGER DEFAULT 0,
            error_message TEXT,
            details JSONB DEFAULT '{}',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ''')

    # Create indexes
    cursor.execute('CREATE INDEX IF NOT EXISTS idx_invoices_date ON invoices(invoice_date)')
    cursor.execute('CREATE INDEX IF NOT EXISTS idx_allocations_company ON allocations(company)')
    cursor.execute('CREATE INDEX IF NOT EXISTS idx_allocations_department ON allocations(department)')

    # Commit table creation before attempting migrations
    conn.commit()

    # Add comment column if it doesn't exist (for existing databases)
    try:
        cursor.execute('ALTER TABLE invoices ADD COLUMN comment TEXT')
        conn.commit()
    except psycopg2.errors.DuplicateColumn:
        conn.rollback()
    except Exception:
        conn.rollback()

    # Add reinvoice_brand column if it doesn't exist
    try:
        cursor.execute('ALTER TABLE allocations ADD COLUMN reinvoice_brand TEXT')
        conn.commit()
    except psycopg2.errors.DuplicateColumn:
        conn.rollback()
    except Exception:
        conn.rollback()

    # Add reinvoice_department column if it doesn't exist
    try:
        cursor.execute('ALTER TABLE allocations ADD COLUMN reinvoice_department TEXT')
        conn.commit()
    except psycopg2.errors.DuplicateColumn:
        conn.rollback()
    except Exception:
        conn.rollback()

    # Add reinvoice_subdepartment column if it doesn't exist
    try:
        cursor.execute('ALTER TABLE allocations ADD COLUMN reinvoice_subdepartment TEXT')
        conn.commit()
    except psycopg2.errors.DuplicateColumn:
        conn.rollback()
    except Exception:
        conn.rollback()

    # Add value_ron column if it doesn't exist (for currency conversion)
    try:
        cursor.execute('ALTER TABLE invoices ADD COLUMN value_ron REAL')
        conn.commit()
    except psycopg2.errors.DuplicateColumn:
        conn.rollback()
    except Exception:
        conn.rollback()

    # Add value_eur column if it doesn't exist (for currency conversion)
    try:
        cursor.execute('ALTER TABLE invoices ADD COLUMN value_eur REAL')
        conn.commit()
    except psycopg2.errors.DuplicateColumn:
        conn.rollback()
    except Exception:
        conn.rollback()

    # Add exchange_rate column if it doesn't exist (for currency conversion)
    try:
        cursor.execute('ALTER TABLE invoices ADD COLUMN exchange_rate REAL')
        conn.commit()
    except psycopg2.errors.DuplicateColumn:
        conn.rollback()
    except Exception:
        conn.rollback()

    # Add deleted_at column for soft delete (bin functionality)
    try:
        cursor.execute('ALTER TABLE invoices ADD COLUMN deleted_at TIMESTAMP')
        conn.commit()
    except psycopg2.errors.DuplicateColumn:
        conn.rollback()
    except Exception:
        conn.rollback()

    # Create index for soft delete queries
    cursor.execute('CREATE INDEX IF NOT EXISTS idx_invoices_deleted_at ON invoices(deleted_at)')
    conn.commit()

    # Seed initial data if tables are empty
    cursor.execute('SELECT COUNT(*) FROM department_structure')
    result = cursor.fetchone()
    if result['count'] == 0:
        _seed_department_structure(cursor)

    cursor.execute('SELECT COUNT(*) FROM companies')
    result = cursor.fetchone()
    if result['count'] == 0:
        _seed_companies(cursor)

    conn.commit()
    conn.close()


def _seed_department_structure(cursor):
    """Seed initial department structure data."""
    structure_data = [
        ('Autoworld PLUS S.R.L.', 'Mazda', 'Sales', None, 'Roxana Biris', 'Amanda Gadalean'),
        ('Autoworld PLUS S.R.L.', 'MG Motor', 'Aftersales', 'Piese si Accesorii', 'Mihai Ploscar', 'Amanda Gadalean'),
        ('Autoworld PLUS S.R.L.', 'MG Motor', 'Aftersales', 'Reparatii Generale', 'Mihai Ploscar', 'Amanda Gadalean'),
        ('Autoworld INTERNATIONAL S.R.L.', 'Volkswagen (PKW)', 'Sales', None, 'Ovidiu Ciobanca', 'Raluca Asztalos'),
        ('Autoworld INTERNATIONAL S.R.L.', 'Volkswagen (PKW)', 'Aftersales', 'Piese si Accesorii', 'Ioan Parocescu', 'Raluca Asztalos'),
        ('Autoworld INTERNATIONAL S.R.L.', 'Volkswagen (PKW)', 'Aftersales', 'Reparatii Generale', 'Ioan Parocescu', 'Raluca Asztalos'),
        ('Autoworld INTERNATIONAL S.R.L.', 'Volkswagen Comerciale (LNF)', 'Sales', None, 'Ovidiu Ciobanca', 'Raluca Asztalos'),
        ('Autoworld INTERNATIONAL S.R.L.', 'Volkswagen Comerciale (LNF)', 'Aftersales', 'Piese si Accesorii', 'Ioan Parocescu', 'Raluca Asztalos'),
        ('Autoworld INTERNATIONAL S.R.L.', 'Volkswagen Comerciale (LNF)', 'Aftersales', 'Reparatii Generale', 'Ioan Parocescu', 'Raluca Asztalos'),
        ('Autoworld PREMIUM S.R.L.', 'Audi', 'Sales', None, 'Roger Patrasc', 'George Pop'),
        ('Autoworld PREMIUM S.R.L.', 'AAP', 'Sales', None, 'Roger Patrasc', 'George Pop'),
        ('Autoworld PREMIUM S.R.L.', 'Audi', 'Aftersales', 'Piese si Accesorii', 'Calin Duca', 'George Pop'),
        ('Autoworld PREMIUM S.R.L.', 'Audi', 'Aftersales', 'Reparatii Generale', 'Calin Duca', 'George Pop'),
        ('Autoworld PRESTIGE S.R.L.', 'Volvo', 'Sales', None, 'Madalina Morutan', 'Amanda Gadalean'),
        ('Autoworld PRESTIGE S.R.L.', 'Volvo', 'Aftersales', 'Piese si Accesorii', 'Mihai Ploscar', 'Amanda Gadalean'),
        ('Autoworld PRESTIGE S.R.L.', 'Volvo', 'Aftersales', 'Reparatii Generale', 'Mihai Ploscar', 'Amanda Gadalean'),
        ('Autoworld NEXT S.R.L.', 'DasWeltAuto', 'Sales', None, 'Ovidiu Bucur', 'Raluca Asztalos'),
        ('Autoworld NEXT S.R.L.', 'Autoworld.ro', 'Sales', None, 'Ovidiu Bucur', 'Sebastian Sabo'),
        ('Autoworld ONE S.R.L.', 'Toyota', 'Sales', None, 'Monica Niculae', 'Sebastian Sabo'),
        ('Autoworld ONE S.R.L.', None, 'Aftersales', 'Piese si Accesorii', 'Ovidiu', 'Sebastian Sabo'),
        ('Autoworld ONE S.R.L.', None, 'Aftersales', 'Reparatii Generale', 'Ovidiu', 'Sebastian Sabo'),
        ('AUTOWORLD S.R.L.', None, 'Conducere', None, 'Ioan Mezei', 'Anyone'),
        ('AUTOWORLD S.R.L.', None, 'Administrativ', None, 'Istvan Papp', 'Anyone'),
        ('AUTOWORLD S.R.L.', None, 'HR', None, 'Diana Deac', 'Anyone'),
        ('AUTOWORLD S.R.L.', None, 'Marketing', None, 'Sebastian Sabo', 'Anyone'),
        ('AUTOWORLD S.R.L.', None, 'Contabilitate', None, 'Claudia Bruslea', 'Anyone'),
    ]

    query = '''
        INSERT INTO department_structure (company, brand, department, subdepartment, manager, marketing)
        VALUES (%s, %s, %s, %s, %s, %s)
    '''
    cursor.executemany(query, structure_data)


def _seed_companies(cursor):
    """Seed initial companies with VAT data."""
    companies_data = [
        ('Autoworld PLUS S.R.L.', 'Mazda & MG', 'RO 50022994'),
        ('Autoworld INTERNATIONAL S.R.L.', 'Volkswagen', 'RO 50186890'),
        ('Autoworld PREMIUM S.R.L.', 'Audi & Audi Approved Plus', 'RO 50188939'),
        ('Autoworld PRESTIGE S.R.L.', 'Volvo', 'RO 50186920'),
        ('Autoworld NEXT S.R.L.', 'DasWeltAuto', 'RO 50186814'),
        ('Autoworld INSURANCE S.R.L.', 'Dep Asigurari - partial', 'RO 48988808'),
        ('Autoworld ONE S.R.L.', 'Toyota', 'RO 15128629'),
        ('AUTOWORLD S.R.L.', 'Admin Conta Mkt PLR', 'RO 225615'),
    ]

    query = '''
        INSERT INTO companies (company, brands, vat)
        VALUES (%s, %s, %s)
    '''
    cursor.executemany(query, companies_data)


def dict_from_row(row):
    """Convert a database row to a dictionary with proper date serialization."""
    if row is None:
        return None
    result = dict(row)
    # Convert date/datetime objects to ISO format strings for JSON serialization
    for key, value in result.items():
        if hasattr(value, 'isoformat'):
            # For date objects, just return YYYY-MM-DD
            if hasattr(value, 'hour'):
                # datetime object - keep full ISO format
                result[key] = value.isoformat()
            else:
                # date object - just YYYY-MM-DD
                result[key] = value.isoformat()
    return result


def save_invoice(
    supplier: str,
    invoice_template: str,
    invoice_number: str,
    invoice_date: str,
    invoice_value: float,
    currency: str,
    drive_link: str,
    distributions: list[dict],
    value_ron: float = None,
    value_eur: float = None,
    exchange_rate: float = None
) -> int:
    """
    Save invoice and its allocations to database.
    Returns the invoice ID.
    """
    conn = get_db()
    cursor = get_cursor(conn)

    try:
        cursor.execute('''
            INSERT INTO invoices (supplier, invoice_template, invoice_number, invoice_date, invoice_value, currency, drive_link, value_ron, value_eur, exchange_rate)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            RETURNING id
        ''', (supplier, invoice_template, invoice_number, invoice_date, invoice_value, currency, drive_link, value_ron, value_eur, exchange_rate))
        invoice_id = cursor.fetchone()['id']

        # Insert allocations
        for dist in distributions:
            allocation_value = invoice_value * dist['allocation']
            cursor.execute('''
                INSERT INTO allocations (invoice_id, company, brand, department, subdepartment, allocation_percent, allocation_value, responsible, reinvoice_to, reinvoice_brand, reinvoice_department, reinvoice_subdepartment)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            ''', (
                invoice_id,
                dist['company'],
                dist.get('brand'),
                dist['department'],
                dist.get('subdepartment'),
                dist['allocation'] * 100,
                allocation_value,
                dist.get('responsible', ''),
                dist.get('reinvoice_to'),
                dist.get('reinvoice_brand'),
                dist.get('reinvoice_department'),
                dist.get('reinvoice_subdepartment')
            ))

        conn.commit()
        return invoice_id

    except Exception as e:
        conn.rollback()
        if 'unique' in str(e).lower() or 'duplicate' in str(e).lower():
            raise ValueError(f"Invoice {invoice_number} already exists in database")
        raise
    finally:
        conn.close()


def get_all_invoices(limit: int = 100, offset: int = 0, company: Optional[str] = None,
                     start_date: Optional[str] = None, end_date: Optional[str] = None,
                     department: Optional[str] = None, subdepartment: Optional[str] = None,
                     brand: Optional[str] = None, include_deleted: bool = False) -> list[dict]:
    """Get all invoices with pagination and optional filtering by allocation fields.

    By default, deleted invoices (with deleted_at set) are excluded.
    Set include_deleted=True to get only deleted invoices (for the bin view).
    """
    conn = get_db()
    cursor = get_cursor(conn)

    # Build query with optional joins and filters
    query = '''
        SELECT DISTINCT i.*
        FROM invoices i
    '''
    params = []
    conditions = []

    # If any allocation filter is set, join with allocations table
    if company or department or subdepartment or brand:
        query = '''
            SELECT DISTINCT i.*
            FROM invoices i
            JOIN allocations a ON a.invoice_id = i.id
        '''
        if company:
            conditions.append('a.company = %s')
            params.append(company)
        if department:
            conditions.append('a.department = %s')
            params.append(department)
        if subdepartment:
            conditions.append('a.subdepartment = %s')
            params.append(subdepartment)
        if brand:
            conditions.append('a.brand = %s')
            params.append(brand)

    # Soft delete filter
    if include_deleted:
        conditions.append('i.deleted_at IS NOT NULL')
    else:
        conditions.append('i.deleted_at IS NULL')

    # Date filters on invoice table
    if start_date:
        conditions.append('i.invoice_date >= %s')
        params.append(start_date)
    if end_date:
        conditions.append('i.invoice_date <= %s')
        params.append(end_date)

    if conditions:
        query += ' WHERE ' + ' AND '.join(conditions)

    query += ' ORDER BY i.created_at DESC LIMIT %s OFFSET %s'
    params.extend([limit, offset])

    cursor.execute(query, params)
    invoices = [dict_from_row(row) for row in cursor.fetchall()]
    conn.close()
    return invoices


def get_invoice_with_allocations(invoice_id: int) -> Optional[dict]:
    """Get invoice with all its allocations."""
    conn = get_db()
    cursor = get_cursor(conn)

    cursor.execute('SELECT * FROM invoices WHERE id = %s', (invoice_id,))
    invoice = cursor.fetchone()

    if not invoice:
        conn.close()
        return None

    invoice = dict_from_row(invoice)

    cursor.execute('SELECT * FROM allocations WHERE invoice_id = %s', (invoice_id,))
    invoice['allocations'] = [dict_from_row(row) for row in cursor.fetchall()]

    conn.close()
    return invoice


def get_allocations_by_company(company: str) -> list[dict]:
    """Get all allocations for a specific company."""
    conn = get_db()
    cursor = get_cursor(conn)

    cursor.execute('''
        SELECT a.*, i.supplier, i.invoice_number, i.invoice_date
        FROM allocations a
        JOIN invoices i ON a.invoice_id = i.id
        WHERE a.company = %s
        ORDER BY i.invoice_date DESC
    ''', (company,))

    results = [dict_from_row(row) for row in cursor.fetchall()]
    conn.close()
    return results


def get_allocations_by_department(company: str, department: str) -> list[dict]:
    """Get all allocations for a specific department."""
    conn = get_db()
    cursor = get_cursor(conn)

    cursor.execute('''
        SELECT a.*, i.supplier, i.invoice_number, i.invoice_date
        FROM allocations a
        JOIN invoices i ON a.invoice_id = i.id
        WHERE a.company = %s AND a.department = %s
        ORDER BY i.invoice_date DESC
    ''', (company, department))

    results = [dict_from_row(row) for row in cursor.fetchall()]
    conn.close()
    return results


def get_summary_by_company(start_date: Optional[str] = None, end_date: Optional[str] = None,
                          department: Optional[str] = None, subdepartment: Optional[str] = None,
                          brand: Optional[str] = None) -> list[dict]:
    """Get total allocation values grouped by company."""
    conn = get_db()
    cursor = get_cursor(conn)

    query = '''
        SELECT a.company, SUM(a.allocation_value) as total_value, COUNT(DISTINCT a.invoice_id) as invoice_count
        FROM allocations a
        JOIN invoices i ON a.invoice_id = i.id
    '''
    params = []
    conditions = []

    if start_date:
        conditions.append('i.invoice_date >= %s')
        params.append(start_date)
    if end_date:
        conditions.append('i.invoice_date <= %s')
        params.append(end_date)
    if department:
        conditions.append('a.department = %s')
        params.append(department)
    if subdepartment:
        conditions.append('a.subdepartment = %s')
        params.append(subdepartment)
    if brand:
        conditions.append('a.brand = %s')
        params.append(brand)

    if conditions:
        query += ' WHERE ' + ' AND '.join(conditions)

    query += ' GROUP BY a.company ORDER BY total_value DESC'

    cursor.execute(query, params)
    results = [dict_from_row(row) for row in cursor.fetchall()]
    conn.close()
    return results


def get_summary_by_department(company: Optional[str] = None, start_date: Optional[str] = None, end_date: Optional[str] = None,
                              department: Optional[str] = None, subdepartment: Optional[str] = None,
                              brand: Optional[str] = None) -> list[dict]:
    """Get total allocation values grouped by department."""
    conn = get_db()
    cursor = get_cursor(conn)

    query = '''
        SELECT a.company, a.department, a.subdepartment, SUM(a.allocation_value) as total_value, COUNT(DISTINCT a.invoice_id) as invoice_count
        FROM allocations a
        JOIN invoices i ON a.invoice_id = i.id
    '''
    params = []
    conditions = []

    if company:
        conditions.append('a.company = %s')
        params.append(company)
    if start_date:
        conditions.append('i.invoice_date >= %s')
        params.append(start_date)
    if end_date:
        conditions.append('i.invoice_date <= %s')
        params.append(end_date)
    if department:
        conditions.append('a.department = %s')
        params.append(department)
    if subdepartment:
        conditions.append('a.subdepartment = %s')
        params.append(subdepartment)
    if brand:
        conditions.append('a.brand = %s')
        params.append(brand)

    if conditions:
        query += ' WHERE ' + ' AND '.join(conditions)

    query += ' GROUP BY a.company, a.department, a.subdepartment ORDER BY total_value DESC'

    cursor.execute(query, params)
    results = [dict_from_row(row) for row in cursor.fetchall()]
    conn.close()
    return results


def get_summary_by_brand(company: Optional[str] = None, start_date: Optional[str] = None, end_date: Optional[str] = None,
                         department: Optional[str] = None, subdepartment: Optional[str] = None,
                         brand: Optional[str] = None) -> list[dict]:
    """Get total allocation values grouped by brand (Linie de business) with invoice details."""
    conn = get_db()
    cursor = get_cursor(conn)

    query = '''
        SELECT a.brand,
               SUM(a.allocation_value) as total_value,
               COUNT(DISTINCT a.invoice_id) as invoice_count,
               STRING_AGG(DISTINCT i.invoice_number, ', ') as invoice_numbers,
               JSON_AGG(JSON_BUILD_OBJECT(
                   'department', a.department,
                   'subdepartment', a.subdepartment,
                   'brand', a.brand,
                   'value', a.allocation_value,
                   'percent', ROUND(a.allocation_percent),
                   'reinvoice_to', a.reinvoice_to,
                   'reinvoice_brand', a.reinvoice_brand,
                   'reinvoice_department', a.reinvoice_department,
                   'reinvoice_subdepartment', a.reinvoice_subdepartment
               )) as split_values
        FROM allocations a
        JOIN invoices i ON a.invoice_id = i.id
    '''
    params = []
    conditions = []

    if company:
        conditions.append('a.company = %s')
        params.append(company)
    if start_date:
        conditions.append('i.invoice_date >= %s')
        params.append(start_date)
    if end_date:
        conditions.append('i.invoice_date <= %s')
        params.append(end_date)
    if department:
        conditions.append('a.department = %s')
        params.append(department)
    if subdepartment:
        conditions.append('a.subdepartment = %s')
        params.append(subdepartment)
    if brand:
        conditions.append('a.brand = %s')
        params.append(brand)

    if conditions:
        query += ' WHERE ' + ' AND '.join(conditions)

    query += ' GROUP BY a.brand ORDER BY total_value DESC'

    cursor.execute(query, params)
    results = [dict_from_row(row) for row in cursor.fetchall()]
    conn.close()
    return results


def delete_invoice(invoice_id: int) -> bool:
    """Soft delete an invoice (move to bin)."""
    conn = get_db()
    cursor = get_cursor(conn)

    cursor.execute('UPDATE invoices SET deleted_at = CURRENT_TIMESTAMP WHERE id = %s AND deleted_at IS NULL', (invoice_id,))
    deleted = cursor.rowcount > 0

    conn.commit()
    conn.close()
    return deleted


def restore_invoice(invoice_id: int) -> bool:
    """Restore a soft-deleted invoice from the bin."""
    conn = get_db()
    cursor = get_cursor(conn)

    cursor.execute('UPDATE invoices SET deleted_at = NULL WHERE id = %s AND deleted_at IS NOT NULL', (invoice_id,))
    restored = cursor.rowcount > 0

    conn.commit()
    conn.close()
    return restored


def get_invoice_drive_link(invoice_id: int) -> str | None:
    """Get the drive_link for a single invoice."""
    conn = get_db()
    cursor = get_cursor(conn)
    cursor.execute('SELECT drive_link FROM invoices WHERE id = %s', (invoice_id,))
    result = cursor.fetchone()
    conn.close()
    return result['drive_link'] if result else None


def get_invoice_drive_links(invoice_ids: list[int]) -> list[str]:
    """Get drive_links for multiple invoices. Returns list of non-null links."""
    if not invoice_ids:
        return []

    conn = get_db()
    cursor = get_cursor(conn)
    placeholders = ','.join(['%s'] * len(invoice_ids))
    cursor.execute(f'SELECT drive_link FROM invoices WHERE id IN ({placeholders}) AND drive_link IS NOT NULL', invoice_ids)
    results = cursor.fetchall()
    conn.close()
    return [r['drive_link'] for r in results if r['drive_link']]


def permanently_delete_invoice(invoice_id: int) -> bool:
    """Permanently delete an invoice and its allocations."""
    conn = get_db()
    cursor = get_cursor(conn)

    cursor.execute('DELETE FROM invoices WHERE id = %s', (invoice_id,))
    deleted = cursor.rowcount > 0

    conn.commit()
    conn.close()
    return deleted


def bulk_soft_delete_invoices(invoice_ids: list[int]) -> int:
    """Soft delete multiple invoices. Returns count of deleted invoices."""
    if not invoice_ids:
        return 0

    conn = get_db()
    cursor = get_cursor(conn)

    placeholders = ','.join(['%s'] * len(invoice_ids))
    cursor.execute(f'UPDATE invoices SET deleted_at = CURRENT_TIMESTAMP WHERE id IN ({placeholders}) AND deleted_at IS NULL', invoice_ids)
    deleted_count = cursor.rowcount

    conn.commit()
    conn.close()
    return deleted_count


def bulk_restore_invoices(invoice_ids: list[int]) -> int:
    """Restore multiple soft-deleted invoices. Returns count of restored invoices."""
    if not invoice_ids:
        return 0

    conn = get_db()
    cursor = get_cursor(conn)

    placeholders = ','.join(['%s'] * len(invoice_ids))
    cursor.execute(f'UPDATE invoices SET deleted_at = NULL WHERE id IN ({placeholders}) AND deleted_at IS NOT NULL', invoice_ids)
    restored_count = cursor.rowcount

    conn.commit()
    conn.close()
    return restored_count


def bulk_permanently_delete_invoices(invoice_ids: list[int]) -> int:
    """Permanently delete multiple invoices. Returns count of deleted invoices."""
    if not invoice_ids:
        return 0

    conn = get_db()
    cursor = get_cursor(conn)

    placeholders = ','.join(['%s'] * len(invoice_ids))
    cursor.execute(f'DELETE FROM invoices WHERE id IN ({placeholders})', invoice_ids)
    deleted_count = cursor.rowcount

    conn.commit()
    conn.close()
    return deleted_count


def cleanup_old_deleted_invoices(days: int = 30) -> int:
    """Permanently delete invoices that have been in the bin for more than specified days."""
    conn = get_db()
    cursor = get_cursor(conn)

    cursor.execute('''
        DELETE FROM invoices
        WHERE deleted_at IS NOT NULL
        AND deleted_at < CURRENT_TIMESTAMP - INTERVAL '%s days'
    ''', (days,))
    deleted_count = cursor.rowcount

    conn.commit()
    conn.close()
    return deleted_count


def update_invoice(
    invoice_id: int,
    supplier: str = None,
    invoice_number: str = None,
    invoice_date: str = None,
    invoice_value: float = None,
    currency: str = None,
    drive_link: str = None,
    comment: str = None
) -> bool:
    """Update an existing invoice."""
    conn = get_db()
    cursor = get_cursor(conn)

    # Build dynamic update query
    updates = []
    params = []

    if supplier is not None:
        updates.append('supplier = %s')
        params.append(supplier)
    if invoice_number is not None:
        updates.append('invoice_number = %s')
        params.append(invoice_number)
    if invoice_date is not None:
        updates.append('invoice_date = %s')
        params.append(invoice_date)
    if invoice_value is not None:
        updates.append('invoice_value = %s')
        params.append(invoice_value)
    if currency is not None:
        updates.append('currency = %s')
        params.append(currency)
    if drive_link is not None:
        updates.append('drive_link = %s')
        params.append(drive_link)
    if comment is not None:
        updates.append('comment = %s')
        params.append(comment)

    if not updates:
        conn.close()
        return False

    updates.append('updated_at = CURRENT_TIMESTAMP')
    params.append(invoice_id)

    query = f"UPDATE invoices SET {', '.join(updates)} WHERE id = %s"

    try:
        cursor.execute(query, params)
        updated = cursor.rowcount > 0
        conn.commit()
        return updated
    except Exception as e:
        conn.rollback()
        if 'unique' in str(e).lower() or 'duplicate' in str(e).lower():
            raise ValueError(f"Invoice number already exists in database")
        raise
    finally:
        conn.close()


def check_invoice_number_exists(invoice_number: str, exclude_id: int = None) -> dict:
    """Check if invoice number already exists in database.

    Args:
        invoice_number: The invoice number to check
        exclude_id: Optional invoice ID to exclude (for edit operations)

    Returns:
        dict with 'exists' (bool) and 'invoice' (existing invoice data if found)
    """
    conn = get_db()
    cursor = get_cursor(conn)

    if exclude_id:
        cursor.execute('''
            SELECT id, supplier, invoice_number, invoice_date, invoice_value, currency
            FROM invoices WHERE invoice_number = %s AND id != %s
        ''', (invoice_number, exclude_id))
    else:
        cursor.execute('''
            SELECT id, supplier, invoice_number, invoice_date, invoice_value, currency
            FROM invoices WHERE invoice_number = %s
        ''', (invoice_number,))

    row = cursor.fetchone()
    conn.close()

    if row:
        return {
            'exists': True,
            'invoice': dict_from_row(row)
        }
    return {'exists': False, 'invoice': None}


def search_invoices(query: str) -> list[dict]:
    """Search invoices by supplier or invoice number."""
    conn = get_db()
    cursor = get_cursor(conn)

    search_term = f'%{query}%'
    cursor.execute('''
        SELECT * FROM invoices
        WHERE supplier LIKE %s OR invoice_number LIKE %s
        ORDER BY created_at DESC
        LIMIT 50
    ''', (search_term, search_term))

    results = [dict_from_row(row) for row in cursor.fetchall()]
    conn.close()
    return results


# ============== ALLOCATION FUNCTIONS ==============

def update_allocation(
    allocation_id: int,
    company: str = None,
    brand: str = None,
    department: str = None,
    subdepartment: str = None,
    allocation_percent: float = None,
    allocation_value: float = None,
    responsible: str = None,
    reinvoice_to: str = None,
    reinvoice_brand: str = None,
    reinvoice_department: str = None,
    reinvoice_subdepartment: str = None
) -> bool:
    """Update an existing allocation."""
    conn = get_db()
    cursor = get_cursor(conn)

    updates = []
    params = []

    if company is not None:
        updates.append('company = %s')
        params.append(company)
    if brand is not None:
        updates.append('brand = %s')
        params.append(brand)
    if department is not None:
        updates.append('department = %s')
        params.append(department)
    if subdepartment is not None:
        updates.append('subdepartment = %s')
        params.append(subdepartment)
    if allocation_percent is not None:
        updates.append('allocation_percent = %s')
        params.append(allocation_percent)
    if allocation_value is not None:
        updates.append('allocation_value = %s')
        params.append(allocation_value)
    if responsible is not None:
        updates.append('responsible = %s')
        params.append(responsible)
    if reinvoice_to is not None:
        updates.append('reinvoice_to = %s')
        params.append(reinvoice_to)
    if reinvoice_brand is not None:
        updates.append('reinvoice_brand = %s')
        params.append(reinvoice_brand)
    if reinvoice_department is not None:
        updates.append('reinvoice_department = %s')
        params.append(reinvoice_department)
    if reinvoice_subdepartment is not None:
        updates.append('reinvoice_subdepartment = %s')
        params.append(reinvoice_subdepartment)

    if not updates:
        conn.close()
        return False

    params.append(allocation_id)
    query = f"UPDATE allocations SET {', '.join(updates)} WHERE id = %s"
    cursor.execute(query, params)
    updated = cursor.rowcount > 0

    conn.commit()
    conn.close()
    return updated


def delete_allocation(allocation_id: int) -> bool:
    """Delete an allocation."""
    conn = get_db()
    cursor = get_cursor(conn)

    cursor.execute('DELETE FROM allocations WHERE id = %s', (allocation_id,))
    deleted = cursor.rowcount > 0

    conn.commit()
    conn.close()
    return deleted


def add_allocation(
    invoice_id: int,
    company: str,
    department: str,
    allocation_percent: float,
    allocation_value: float,
    brand: str = None,
    subdepartment: str = None,
    responsible: str = None,
    reinvoice_to: str = None,
    reinvoice_brand: str = None,
    reinvoice_department: str = None,
    reinvoice_subdepartment: str = None
) -> int:
    """Add a new allocation to an invoice. Returns allocation ID."""
    conn = get_db()
    cursor = get_cursor(conn)

    try:
        cursor.execute('''
            INSERT INTO allocations (invoice_id, company, brand, department, subdepartment,
                allocation_percent, allocation_value, responsible, reinvoice_to, reinvoice_brand, reinvoice_department, reinvoice_subdepartment)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            RETURNING id
        ''', (invoice_id, company, brand, department, subdepartment,
              allocation_percent, allocation_value, responsible, reinvoice_to, reinvoice_brand, reinvoice_department, reinvoice_subdepartment))
        allocation_id = cursor.fetchone()['id']

        conn.commit()
        return allocation_id
    except Exception as e:
        conn.rollback()
        raise
    finally:
        conn.close()


def update_invoice_allocations(invoice_id: int, allocations: list[dict]) -> bool:
    """
    Replace all allocations for an invoice with new ones.
    This is a transactional operation - either all succeed or all fail.
    allocation_value is calculated from invoice_value * (allocation_percent / 100)
    """
    conn = get_db()
    cursor = get_cursor(conn)

    try:
        # Get invoice value to calculate allocation values
        cursor.execute('SELECT invoice_value FROM invoices WHERE id = %s', (invoice_id,))
        result = cursor.fetchone()
        if not result:
            raise ValueError(f"Invoice {invoice_id} not found")
        invoice_value = result['invoice_value']

        # Delete existing allocations
        cursor.execute('DELETE FROM allocations WHERE invoice_id = %s', (invoice_id,))

        # Insert new allocations
        for alloc in allocations:
            allocation_percent = alloc['allocation_percent']
            # Calculate value from percent if not provided
            allocation_value = alloc.get('allocation_value') or (invoice_value * allocation_percent / 100)

            cursor.execute('''
                INSERT INTO allocations (invoice_id, company, brand, department, subdepartment,
                    allocation_percent, allocation_value, responsible, reinvoice_to, reinvoice_brand, reinvoice_department, reinvoice_subdepartment)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            ''', (
                invoice_id,
                alloc['company'],
                alloc.get('brand'),
                alloc['department'],
                alloc.get('subdepartment'),
                allocation_percent,
                allocation_value,
                alloc.get('responsible'),
                alloc.get('reinvoice_to'),
                alloc.get('reinvoice_brand'),
                alloc.get('reinvoice_department'),
                alloc.get('reinvoice_subdepartment')
            ))

        conn.commit()
        return True
    except Exception as e:
        conn.rollback()
        raise
    finally:
        conn.close()


# ============== INVOICE TEMPLATE FUNCTIONS ==============

def save_invoice_template(
    name: str,
    supplier: str = None,
    supplier_vat: str = None,
    customer_vat: str = None,
    currency: str = 'RON',
    description: str = None,
    invoice_number_regex: str = None,
    invoice_date_regex: str = None,
    invoice_value_regex: str = None,
    date_format: str = '%Y-%m-%d',
    sample_invoice_path: str = None,
    template_type: str = 'fixed',
    supplier_regex: str = None,
    supplier_vat_regex: str = None,
    customer_vat_regex: str = None,
    currency_regex: str = None
) -> int:
    """Save a new invoice template. Returns the template ID."""
    conn = get_db()
    cursor = get_cursor(conn)

    try:
        cursor.execute('''
            INSERT INTO invoice_templates (
                name, template_type, supplier, supplier_vat, customer_vat, currency, description,
                invoice_number_regex, invoice_date_regex, invoice_value_regex,
                date_format, sample_invoice_path,
                supplier_regex, supplier_vat_regex, customer_vat_regex, currency_regex
            ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            RETURNING id
        ''', (
            name, template_type, supplier, supplier_vat, customer_vat, currency, description,
            invoice_number_regex, invoice_date_regex, invoice_value_regex,
            date_format, sample_invoice_path,
            supplier_regex, supplier_vat_regex, customer_vat_regex, currency_regex
        ))
        template_id = cursor.fetchone()['id']

        conn.commit()
        return template_id

    except Exception as e:
        conn.rollback()
        if 'unique' in str(e).lower() or 'duplicate' in str(e).lower():
            raise ValueError(f"Template '{name}' already exists")
        raise
    finally:
        conn.close()


def update_invoice_template(
    template_id: int,
    name: str = None,
    supplier: str = None,
    supplier_vat: str = None,
    customer_vat: str = None,
    currency: str = None,
    description: str = None,
    invoice_number_regex: str = None,
    invoice_date_regex: str = None,
    invoice_value_regex: str = None,
    date_format: str = None,
    sample_invoice_path: str = None,
    template_type: str = None,
    supplier_regex: str = None,
    supplier_vat_regex: str = None,
    customer_vat_regex: str = None,
    currency_regex: str = None
) -> bool:
    """Update an existing invoice template."""
    conn = get_db()
    cursor = get_cursor(conn)

    # Build dynamic update query
    updates = []
    params = []

    if name is not None:
        updates.append('name = %s')
        params.append(name)
    if template_type is not None:
        updates.append('template_type = %s')
        params.append(template_type)
    if supplier is not None:
        updates.append('supplier = %s')
        params.append(supplier)
    if supplier_vat is not None:
        updates.append('supplier_vat = %s')
        params.append(supplier_vat)
    if customer_vat is not None:
        updates.append('customer_vat = %s')
        params.append(customer_vat)
    if currency is not None:
        updates.append('currency = %s')
        params.append(currency)
    if description is not None:
        updates.append('description = %s')
        params.append(description)
    if invoice_number_regex is not None:
        updates.append('invoice_number_regex = %s')
        params.append(invoice_number_regex)
    if invoice_date_regex is not None:
        updates.append('invoice_date_regex = %s')
        params.append(invoice_date_regex)
    if invoice_value_regex is not None:
        updates.append('invoice_value_regex = %s')
        params.append(invoice_value_regex)
    if date_format is not None:
        updates.append('date_format = %s')
        params.append(date_format)
    if sample_invoice_path is not None:
        updates.append('sample_invoice_path = %s')
        params.append(sample_invoice_path)
    if supplier_regex is not None:
        updates.append('supplier_regex = %s')
        params.append(supplier_regex)
    if supplier_vat_regex is not None:
        updates.append('supplier_vat_regex = %s')
        params.append(supplier_vat_regex)
    if customer_vat_regex is not None:
        updates.append('customer_vat_regex = %s')
        params.append(customer_vat_regex)
    if currency_regex is not None:
        updates.append('currency_regex = %s')
        params.append(currency_regex)

    if not updates:
        conn.close()
        return False

    updates.append('updated_at = CURRENT_TIMESTAMP')
    params.append(template_id)

    query = f"UPDATE invoice_templates SET {', '.join(updates)} WHERE id = %s"
    cursor.execute(query, params)
    updated = cursor.rowcount > 0

    conn.commit()
    conn.close()
    return updated


def delete_invoice_template(template_id: int) -> bool:
    """Delete an invoice template."""
    conn = get_db()
    cursor = get_cursor(conn)

    cursor.execute('DELETE FROM invoice_templates WHERE id = %s', (template_id,))
    deleted = cursor.rowcount > 0

    conn.commit()
    conn.close()
    return deleted


def get_all_invoice_templates() -> list[dict]:
    """Get all invoice templates."""
    conn = get_db()
    cursor = get_cursor(conn)

    cursor.execute('SELECT * FROM invoice_templates ORDER BY name')
    templates = [dict_from_row(row) for row in cursor.fetchall()]

    conn.close()
    return templates


def get_invoice_template(template_id: int) -> Optional[dict]:
    """Get a specific invoice template by ID."""
    conn = get_db()
    cursor = get_cursor(conn)

    cursor.execute('SELECT * FROM invoice_templates WHERE id = %s', (template_id,))
    template = cursor.fetchone()

    conn.close()
    return dict_from_row(template) if template else None


def get_invoice_template_by_name(name: str) -> Optional[dict]:
    """Get a specific invoice template by name."""
    conn = get_db()
    cursor = get_cursor(conn)

    cursor.execute('SELECT * FROM invoice_templates WHERE name = %s', (name,))
    template = cursor.fetchone()

    conn.close()
    return dict_from_row(template) if template else None


# ============ Connector Functions ============

def get_all_connectors() -> list[dict]:
    """Get all connectors."""
    conn = get_db()
    cursor = get_cursor(conn)

    cursor.execute('SELECT * FROM connectors ORDER BY name')
    connectors = [dict_from_row(row) for row in cursor.fetchall()]

    conn.close()
    return connectors


def get_connector(connector_id: int) -> Optional[dict]:
    """Get a specific connector by ID."""
    conn = get_db()
    cursor = get_cursor(conn)

    cursor.execute('SELECT * FROM connectors WHERE id = %s', (connector_id,))
    connector = cursor.fetchone()

    conn.close()
    return dict_from_row(connector) if connector else None


def get_connector_by_type(connector_type: str) -> Optional[dict]:
    """Get a connector by type (e.g., 'google_ads', 'meta')."""
    conn = get_db()
    cursor = get_cursor(conn)

    cursor.execute('SELECT * FROM connectors WHERE connector_type = %s', (connector_type,))
    connector = cursor.fetchone()

    conn.close()
    return dict_from_row(connector) if connector else None


def save_connector(
    connector_type: str,
    name: str,
    status: str = 'disconnected',
    config: dict = None,
    credentials: dict = None
) -> int:
    """Save a new connector. Returns connector ID."""
    import json
    conn = get_db()
    cursor = get_cursor(conn)

    cursor.execute('''
        INSERT INTO connectors (connector_type, name, status, config, credentials)
        VALUES (%s, %s, %s, %s, %s)
        RETURNING id
    ''', (
        connector_type,
        name,
        status,
        json.dumps(config or {}),
        json.dumps(credentials or {})
    ))

    connector_id = cursor.fetchone()['id']
    conn.commit()
    conn.close()
    return connector_id


def update_connector(
    connector_id: int,
    name: str = None,
    status: str = None,
    config: dict = None,
    credentials: dict = None,
    last_sync: datetime = None,
    last_error: str = None
) -> bool:
    """Update a connector. Returns True if updated."""
    import json
    conn = get_db()
    cursor = get_cursor(conn)

    updates = []
    params = []

    if name is not None:
        updates.append('name = %s')
        params.append(name)
    if status is not None:
        updates.append('status = %s')
        params.append(status)
    if config is not None:
        updates.append('config = %s')
        params.append(json.dumps(config))
    if credentials is not None:
        updates.append('credentials = %s')
        params.append(json.dumps(credentials))
    if last_sync is not None:
        updates.append('last_sync = %s')
        params.append(last_sync)
    if last_error is not None:
        updates.append('last_error = %s')
        params.append(last_error)

    if not updates:
        conn.close()
        return False

    updates.append('updated_at = CURRENT_TIMESTAMP')
    params.append(connector_id)

    query = f"UPDATE connectors SET {', '.join(updates)} WHERE id = %s"
    cursor.execute(query, params)
    updated = cursor.rowcount > 0

    conn.commit()
    conn.close()
    return updated


def delete_connector(connector_id: int) -> bool:
    """Delete a connector and its sync logs."""
    conn = get_db()
    cursor = get_cursor(conn)

    cursor.execute('DELETE FROM connectors WHERE id = %s', (connector_id,))
    deleted = cursor.rowcount > 0

    conn.commit()
    conn.close()
    return deleted


def add_connector_sync_log(
    connector_id: int,
    sync_type: str,
    status: str,
    invoices_found: int = 0,
    invoices_imported: int = 0,
    error_message: str = None,
    details: dict = None
) -> int:
    """Add a sync log entry. Returns log ID."""
    import json
    conn = get_db()
    cursor = get_cursor(conn)

    cursor.execute('''
        INSERT INTO connector_sync_log
        (connector_id, sync_type, status, invoices_found, invoices_imported, error_message, details)
        VALUES (%s, %s, %s, %s, %s, %s, %s)
        RETURNING id
    ''', (
        connector_id,
        sync_type,
        status,
        invoices_found,
        invoices_imported,
        error_message,
        json.dumps(details or {})
    ))

    log_id = cursor.fetchone()['id']
    conn.commit()
    conn.close()
    return log_id


def get_connector_sync_logs(connector_id: int, limit: int = 20) -> list[dict]:
    """Get sync logs for a connector, most recent first."""
    conn = get_db()
    cursor = get_cursor(conn)

    cursor.execute('''
        SELECT * FROM connector_sync_log
        WHERE connector_id = %s
        ORDER BY created_at DESC
        LIMIT %s
    ''', (connector_id, limit))

    logs = [dict_from_row(row) for row in cursor.fetchall()]
    conn.close()
    return logs


# Initialize database on import
init_db()
