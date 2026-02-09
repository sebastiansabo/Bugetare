"""
Analytics Service

Provides aggregated financial data for AI-powered analytics queries.
Wraps existing SummaryRepository and transaction summary functions
with a unified interface for the AI agent.
"""

import time
from typing import Optional, Dict, Any, List
from decimal import Decimal

from core.database import get_db, get_cursor, release_db, dict_from_row
from core.utils.logging_config import get_logger

logger = get_logger('jarvis.ai_agent.services.analytics')

# Cache for entity names (companies, departments, brands, suppliers)
_entity_cache: Dict[str, Any] = {}
_entity_cache_ttl = 300  # 5 minutes


class AnalyticsService:
    """Aggregation queries for AI-powered analytics."""

    def get_invoice_summary(
        self,
        group_by: str = 'company',
        company: Optional[str] = None,
        department: Optional[str] = None,
        subdepartment: Optional[str] = None,
        brand: Optional[str] = None,
        supplier: Optional[str] = None,
        start_date: Optional[str] = None,
        end_date: Optional[str] = None,
    ) -> Dict[str, Any]:
        """Get invoice allocation summaries grouped by the specified dimension.

        Delegates to the same SQL as SummaryRepository but called directly
        to avoid circular imports with the accounting module.
        """
        conn = get_db()
        try:
            cursor = get_cursor(conn)

            # Build GROUP BY and SELECT based on dimension
            group_configs = {
                'company': {
                    'select': 'a.company',
                    'group': 'a.company',
                    'label': 'company',
                },
                'department': {
                    'select': 'a.company, a.department, a.subdepartment',
                    'group': 'a.company, a.department, a.subdepartment',
                    'label': 'department',
                },
                'brand': {
                    'select': 'a.brand',
                    'group': 'a.brand',
                    'label': 'brand',
                },
                'supplier': {
                    'select': 'i.supplier',
                    'group': 'i.supplier',
                    'label': 'supplier',
                },
            }

            config = group_configs.get(group_by, group_configs['company'])

            query = f'''
                SELECT
                    {config['select']},
                    SUM(CASE WHEN i.invoice_value > 0 AND i.value_ron IS NOT NULL
                        THEN a.allocation_value * i.value_ron / i.invoice_value
                        ELSE a.allocation_value END) as total_value_ron,
                    SUM(CASE WHEN i.invoice_value > 0 AND i.value_eur IS NOT NULL
                        THEN a.allocation_value * i.value_eur / i.invoice_value
                        ELSE a.allocation_value / COALESCE(i.exchange_rate, 5.0) END) as total_value_eur,
                    COUNT(DISTINCT a.invoice_id) as invoice_count,
                    AVG(COALESCE(i.exchange_rate, 5.0)) as avg_exchange_rate
                FROM allocations a
                JOIN invoices i ON a.invoice_id = i.id
                WHERE i.deleted_at IS NULL
            '''
            params: list = []

            if company:
                query += ' AND a.company = %s'
                params.append(company)
            if department:
                query += ' AND a.department = %s'
                params.append(department)
            if subdepartment:
                query += ' AND a.subdepartment = %s'
                params.append(subdepartment)
            if brand:
                query += ' AND a.brand = %s'
                params.append(brand)
            if supplier:
                query += ' AND i.supplier = %s'
                params.append(supplier)
            if start_date:
                query += ' AND i.invoice_date >= %s'
                params.append(start_date)
            if end_date:
                query += ' AND i.invoice_date <= %s'
                params.append(end_date)

            query += f' GROUP BY {config["group"]} ORDER BY total_value_ron DESC'

            cursor.execute(query, params)
            rows = [dict_from_row(row) for row in cursor.fetchall()]

            return {
                'type': 'invoice_summary',
                'group_by': group_by,
                'rows': rows,
                'filters': {
                    k: v for k, v in {
                        'company': company, 'department': department,
                        'brand': brand, 'supplier': supplier,
                        'start_date': start_date, 'end_date': end_date,
                    }.items() if v
                },
            }
        except Exception as e:
            logger.error(f"Invoice summary query failed: {e}")
            return {'type': 'invoice_summary', 'group_by': group_by, 'rows': [], 'error': str(e)}
        finally:
            release_db(conn)

    def get_monthly_trend(
        self,
        company: Optional[str] = None,
        department: Optional[str] = None,
        brand: Optional[str] = None,
        supplier: Optional[str] = None,
        start_date: Optional[str] = None,
        end_date: Optional[str] = None,
    ) -> Dict[str, Any]:
        """Get monthly spending trend (total RON/EUR/invoice count per month)."""
        conn = get_db()
        try:
            cursor = get_cursor(conn)

            query = '''
                SELECT
                    TO_CHAR(DATE_TRUNC('month', i.invoice_date), 'YYYY-MM') as month,
                    SUM(CASE WHEN i.invoice_value > 0 AND i.value_ron IS NOT NULL
                        THEN a.allocation_value * i.value_ron / i.invoice_value
                        ELSE a.allocation_value END) as total_value_ron,
                    SUM(CASE WHEN i.invoice_value > 0 AND i.value_eur IS NOT NULL
                        THEN a.allocation_value * i.value_eur / i.invoice_value
                        ELSE a.allocation_value / COALESCE(i.exchange_rate, 5.0) END) as total_value_eur,
                    COUNT(DISTINCT a.invoice_id) as invoice_count
                FROM allocations a
                JOIN invoices i ON a.invoice_id = i.id
                WHERE i.deleted_at IS NULL
                    AND i.invoice_date IS NOT NULL
            '''
            params: list = []

            if company:
                query += ' AND a.company = %s'
                params.append(company)
            if department:
                query += ' AND a.department = %s'
                params.append(department)
            if brand:
                query += ' AND a.brand = %s'
                params.append(brand)
            if supplier:
                query += ' AND i.supplier = %s'
                params.append(supplier)
            if start_date:
                query += ' AND i.invoice_date >= %s'
                params.append(start_date)
            if end_date:
                query += ' AND i.invoice_date <= %s'
                params.append(end_date)

            query += ' GROUP BY DATE_TRUNC(\'month\', i.invoice_date) ORDER BY month ASC'

            cursor.execute(query, params)
            rows = [dict_from_row(row) for row in cursor.fetchall()]

            return {
                'type': 'monthly_trend',
                'rows': rows,
                'filters': {
                    k: v for k, v in {
                        'company': company, 'department': department,
                        'brand': brand, 'supplier': supplier,
                        'start_date': start_date, 'end_date': end_date,
                    }.items() if v
                },
            }
        except Exception as e:
            logger.error(f"Monthly trend query failed: {e}")
            return {'type': 'monthly_trend', 'rows': [], 'error': str(e)}
        finally:
            release_db(conn)

    def get_top_suppliers(
        self,
        limit: int = 10,
        company: Optional[str] = None,
        department: Optional[str] = None,
        brand: Optional[str] = None,
        start_date: Optional[str] = None,
        end_date: Optional[str] = None,
    ) -> Dict[str, Any]:
        """Get top N suppliers by total spend (RON)."""
        result = self.get_invoice_summary(
            group_by='supplier',
            company=company,
            department=department,
            brand=brand,
            start_date=start_date,
            end_date=end_date,
        )
        result['type'] = 'top_suppliers'
        result['rows'] = result['rows'][:limit]
        return result

    def get_transaction_summary(
        self,
        company_cui: Optional[str] = None,
        supplier: Optional[str] = None,
        date_from: Optional[str] = None,
        date_to: Optional[str] = None,
    ) -> Dict[str, Any]:
        """Get bank transaction summary by status and supplier."""
        conn = get_db()
        try:
            cursor = get_cursor(conn)

            # Build base conditions
            conditions: list = []
            params: list = []

            if company_cui:
                conditions.append('company_cui = %s')
                params.append(company_cui)
            if supplier:
                conditions.append('matched_supplier = %s')
                params.append(supplier)
            if date_from:
                conditions.append('transaction_date >= %s')
                params.append(date_from)
            if date_to:
                conditions.append('transaction_date <= %s')
                params.append(date_to)

            where = ' AND '.join(conditions) if conditions else '1=1'

            # By status
            cursor.execute(f'''
                SELECT status, COUNT(*) as count, COALESCE(SUM(amount), 0) as total
                FROM bank_statement_transactions
                WHERE {where}
                GROUP BY status
            ''', params)
            by_status = {
                row['status']: {'count': row['count'], 'total': float(row['total'])}
                for row in cursor.fetchall()
            }

            # By supplier (top 10)
            supplier_where = where + " AND matched_supplier IS NOT NULL"
            cursor.execute(f'''
                SELECT matched_supplier, COUNT(*) as count, COALESCE(SUM(amount), 0) as total
                FROM bank_statement_transactions
                WHERE {supplier_where}
                GROUP BY matched_supplier
                ORDER BY total DESC
                LIMIT 10
            ''', params)
            by_supplier = [dict_from_row(row) for row in cursor.fetchall()]

            return {
                'type': 'transaction_summary',
                'by_status': by_status,
                'by_supplier': by_supplier,
                'filters': {
                    k: v for k, v in {
                        'company_cui': company_cui, 'supplier': supplier,
                        'date_from': date_from, 'date_to': date_to,
                    }.items() if v
                },
            }
        except Exception as e:
            logger.error(f"Transaction summary query failed: {e}")
            return {'type': 'transaction_summary', 'by_status': {}, 'by_supplier': [], 'error': str(e)}
        finally:
            release_db(conn)

    def get_efactura_summary(self) -> Dict[str, Any]:
        """Get e-Factura invoice summary: unallocated, hidden, allocated counts and totals."""
        conn = get_db()
        try:
            cursor = get_cursor(conn)

            # Overall counts by allocation status
            cursor.execute('''
                SELECT
                    COUNT(*) FILTER (WHERE jarvis_invoice_id IS NULL AND ignored = FALSE) as unallocated_count,
                    COALESCE(SUM(total_amount) FILTER (WHERE jarvis_invoice_id IS NULL AND ignored = FALSE), 0) as unallocated_total,
                    COUNT(*) FILTER (WHERE ignored = TRUE) as hidden_count,
                    COALESCE(SUM(total_amount) FILTER (WHERE ignored = TRUE), 0) as hidden_total,
                    COUNT(*) FILTER (WHERE jarvis_invoice_id IS NOT NULL) as allocated_count,
                    COALESCE(SUM(total_amount) FILTER (WHERE jarvis_invoice_id IS NOT NULL), 0) as allocated_total,
                    COUNT(*) as total_count,
                    COALESCE(SUM(total_amount), 0) as total_amount
                FROM efactura_invoices
                WHERE deleted_at IS NULL
            ''')
            overview = dict(cursor.fetchone())

            # Unallocated by company (cif_owner)
            cursor.execute('''
                SELECT cif_owner, COUNT(*) as count, COALESCE(SUM(total_amount), 0) as total
                FROM efactura_invoices
                WHERE deleted_at IS NULL AND jarvis_invoice_id IS NULL AND ignored = FALSE
                GROUP BY cif_owner
                ORDER BY count DESC
            ''')
            by_company = [dict(row) for row in cursor.fetchall()]

            # Unallocated by direction
            cursor.execute('''
                SELECT direction, COUNT(*) as count, COALESCE(SUM(total_amount), 0) as total
                FROM efactura_invoices
                WHERE deleted_at IS NULL AND jarvis_invoice_id IS NULL AND ignored = FALSE
                GROUP BY direction
                ORDER BY direction
            ''')
            by_direction = [dict(row) for row in cursor.fetchall()]

            return {
                'type': 'efactura_summary',
                'overview': overview,
                'unallocated_by_company': by_company,
                'unallocated_by_direction': by_direction,
            }
        except Exception as e:
            logger.error(f"e-Factura summary query failed: {e}")
            return {'type': 'efactura_summary', 'overview': {}, 'error': str(e)}
        finally:
            release_db(conn)

    def get_entity_names(self) -> Dict[str, List[str]]:
        """Get known entity names for query matching. Cached for 5 minutes."""
        global _entity_cache

        if _entity_cache and (time.time() - _entity_cache.get('_ts', 0)) < _entity_cache_ttl:
            return _entity_cache

        conn = get_db()
        try:
            cursor = get_cursor(conn)

            # Companies from department_structure
            cursor.execute('''
                SELECT DISTINCT company FROM department_structure
                WHERE company IS NOT NULL AND company != ''
                ORDER BY company
            ''')
            companies = [row['company'] for row in cursor.fetchall()]

            # Departments
            cursor.execute('''
                SELECT DISTINCT department FROM department_structure
                WHERE department IS NOT NULL AND department != ''
                ORDER BY department
            ''')
            departments = [row['department'] for row in cursor.fetchall()]

            # Brands
            cursor.execute('''
                SELECT DISTINCT brand FROM department_structure
                WHERE brand IS NOT NULL AND brand != ''
                ORDER BY brand
            ''')
            brands = [row['brand'] for row in cursor.fetchall()]

            # Suppliers (from invoices)
            cursor.execute('''
                SELECT DISTINCT supplier FROM invoices
                WHERE supplier IS NOT NULL AND supplier != '' AND deleted_at IS NULL
                ORDER BY supplier
            ''')
            suppliers = [row['supplier'] for row in cursor.fetchall()]

            result = {
                'companies': companies,
                'departments': departments,
                'brands': brands,
                'suppliers': suppliers,
                '_ts': time.time(),
            }
            _entity_cache.update(result)
            return result
        except Exception as e:
            logger.error(f"Entity names query failed: {e}")
            return {'companies': [], 'departments': [], 'brands': [], 'suppliers': []}
        finally:
            release_db(conn)

    def format_as_context(self, results: List[Dict[str, Any]]) -> str:
        """Format analytics results as markdown for LLM context injection."""
        if not results:
            return ''

        sections = []
        for result in results:
            section = self._format_single_result(result)
            if section:
                sections.append(section)

        if not sections:
            return ''

        return '\n\n'.join(sections)

    def _format_single_result(self, result: Dict[str, Any]) -> str:
        """Format a single analytics result as a markdown table."""
        result_type = result.get('type', '')
        rows = result.get('rows', [])

        if result.get('error'):
            return f"*Analytics query error: {result['error']}*"

        # Filter description
        filters = result.get('filters', {})
        filter_desc = ''
        if filters:
            parts = [f"{k}: {v}" for k, v in filters.items()]
            filter_desc = f" (filtered by {', '.join(parts)})"

        if result_type == 'invoice_summary':
            return self._format_invoice_summary(result, filter_desc)
        elif result_type == 'monthly_trend':
            return self._format_monthly_trend(rows, filter_desc)
        elif result_type == 'top_suppliers':
            return self._format_top_suppliers(rows, filter_desc)
        elif result_type == 'transaction_summary':
            return self._format_transaction_summary(result, filter_desc)
        elif result_type == 'efactura_summary':
            return self._format_efactura_summary(result)

        return ''

    def _format_invoice_summary(self, result: Dict, filter_desc: str) -> str:
        group_by = result.get('group_by', 'company')
        rows = result.get('rows', [])
        if not rows:
            return f"**Invoice Summary by {group_by}{filter_desc}**: No data found."

        # Build header based on group_by
        if group_by == 'department':
            header = '| Company | Department | Subdepartment | Total RON | Total EUR | Invoices |'
            sep = '|---|---|---|---:|---:|---:|'
            lines = [header, sep]
            for r in rows:
                lines.append(
                    f"| {r.get('company', '')} | {r.get('department', '')} | "
                    f"{r.get('subdepartment', '')} | "
                    f"{self._fmt_num(r.get('total_value_ron', 0))} | "
                    f"{self._fmt_num(r.get('total_value_eur', 0))} | "
                    f"{r.get('invoice_count', 0)} |"
                )
        else:
            label = group_by.capitalize()
            key = 'supplier' if group_by == 'supplier' else group_by
            header = f'| {label} | Total RON | Total EUR | Invoices |'
            sep = '|---|---:|---:|---:|'
            lines = [header, sep]
            for r in rows:
                lines.append(
                    f"| {r.get(key, '')} | "
                    f"{self._fmt_num(r.get('total_value_ron', 0))} | "
                    f"{self._fmt_num(r.get('total_value_eur', 0))} | "
                    f"{r.get('invoice_count', 0)} |"
                )

        # Totals row
        total_ron = sum(float(r.get('total_value_ron', 0) or 0) for r in rows)
        total_eur = sum(float(r.get('total_value_eur', 0) or 0) for r in rows)
        total_inv = sum(int(r.get('invoice_count', 0) or 0) for r in rows)
        if group_by == 'department':
            lines.append(f"| **TOTAL** | | | **{self._fmt_num(total_ron)}** | **{self._fmt_num(total_eur)}** | **{total_inv}** |")
        else:
            lines.append(f"| **TOTAL** | **{self._fmt_num(total_ron)}** | **{self._fmt_num(total_eur)}** | **{total_inv}** |")

        return f"**Invoice Summary by {group_by.capitalize()}{filter_desc}**\n" + '\n'.join(lines)

    def _format_monthly_trend(self, rows: list, filter_desc: str) -> str:
        if not rows:
            return f"**Monthly Trend{filter_desc}**: No data found."

        lines = [
            '| Month | Total RON | Total EUR | Invoices |',
            '|---|---:|---:|---:|',
        ]
        for r in rows:
            lines.append(
                f"| {r.get('month', '')} | "
                f"{self._fmt_num(r.get('total_value_ron', 0))} | "
                f"{self._fmt_num(r.get('total_value_eur', 0))} | "
                f"{r.get('invoice_count', 0)} |"
            )

        total_ron = sum(float(r.get('total_value_ron', 0) or 0) for r in rows)
        total_eur = sum(float(r.get('total_value_eur', 0) or 0) for r in rows)
        total_inv = sum(int(r.get('invoice_count', 0) or 0) for r in rows)
        lines.append(f"| **TOTAL** | **{self._fmt_num(total_ron)}** | **{self._fmt_num(total_eur)}** | **{total_inv}** |")

        return f"**Monthly Spending Trend{filter_desc}**\n" + '\n'.join(lines)

    def _format_top_suppliers(self, rows: list, filter_desc: str) -> str:
        if not rows:
            return f"**Top Suppliers{filter_desc}**: No data found."

        lines = [
            '| # | Supplier | Total RON | Total EUR | Invoices |',
            '|---:|---|---:|---:|---:|',
        ]
        for i, r in enumerate(rows, 1):
            lines.append(
                f"| {i} | {r.get('supplier', '')} | "
                f"{self._fmt_num(r.get('total_value_ron', 0))} | "
                f"{self._fmt_num(r.get('total_value_eur', 0))} | "
                f"{r.get('invoice_count', 0)} |"
            )

        return f"**Top {len(rows)} Suppliers by Spend{filter_desc}**\n" + '\n'.join(lines)

    def _format_transaction_summary(self, result: Dict, filter_desc: str) -> str:
        by_status = result.get('by_status', {})
        by_supplier = result.get('by_supplier', [])

        sections = []

        if by_status:
            lines = [
                '| Status | Count | Total Amount |',
                '|---|---:|---:|',
            ]
            total_count = 0
            total_amount = 0.0
            for status, data in sorted(by_status.items()):
                count = data.get('count', 0)
                total = data.get('total', 0)
                total_count += count
                total_amount += float(total)
                lines.append(f"| {status} | {count} | {self._fmt_num(total)} |")
            lines.append(f"| **TOTAL** | **{total_count}** | **{self._fmt_num(total_amount)}** |")
            sections.append(f"**Bank Transactions by Status{filter_desc}**\n" + '\n'.join(lines))

        if by_supplier:
            lines = [
                '| Supplier | Count | Total Amount |',
                '|---|---:|---:|',
            ]
            for r in by_supplier:
                lines.append(
                    f"| {r.get('matched_supplier', '')} | "
                    f"{r.get('count', 0)} | "
                    f"{self._fmt_num(r.get('total', 0))} |"
                )
            sections.append("**Top Transaction Suppliers**\n" + '\n'.join(lines))

        return '\n\n'.join(sections) if sections else f"**Bank Transaction Summary{filter_desc}**: No data found."

    def _format_efactura_summary(self, result: Dict) -> str:
        overview = result.get('overview', {})
        by_company = result.get('unallocated_by_company', [])
        by_direction = result.get('unallocated_by_direction', [])

        if result.get('error'):
            return f"*e-Factura query error: {result['error']}*"

        sections = []

        # Overview
        lines = [
            '| Status | Count | Total Amount |',
            '|---|---:|---:|',
            f"| Unallocated | {overview.get('unallocated_count', 0)} | {self._fmt_num(overview.get('unallocated_total', 0))} |",
            f"| Hidden | {overview.get('hidden_count', 0)} | {self._fmt_num(overview.get('hidden_total', 0))} |",
            f"| Allocated | {overview.get('allocated_count', 0)} | {self._fmt_num(overview.get('allocated_total', 0))} |",
            f"| **TOTAL** | **{overview.get('total_count', 0)}** | **{self._fmt_num(overview.get('total_amount', 0))}** |",
        ]
        sections.append("**e-Factura Overview**\n" + '\n'.join(lines))

        # By company
        if by_company:
            lines = [
                '| Company (CIF) | Unallocated Count | Total Amount |',
                '|---|---:|---:|',
            ]
            for r in by_company:
                lines.append(f"| {r.get('cif_owner', '')} | {r.get('count', 0)} | {self._fmt_num(r.get('total', 0))} |")
            sections.append("**Unallocated by Company**\n" + '\n'.join(lines))

        # By direction
        if by_direction:
            lines = [
                '| Direction | Count | Total Amount |',
                '|---|---:|---:|',
            ]
            for r in by_direction:
                lines.append(f"| {r.get('direction', '')} | {r.get('count', 0)} | {self._fmt_num(r.get('total', 0))} |")
            sections.append("**Unallocated by Direction**\n" + '\n'.join(lines))

        return '\n\n'.join(sections) if sections else "**e-Factura Summary**: No data found."

    @staticmethod
    def _fmt_num(value) -> str:
        """Format number with thousands separator (Romanian convention)."""
        if value is None:
            return '0'
        try:
            num = float(value)
            if num == int(num) and abs(num) >= 1:
                return f"{int(num):,}".replace(',', '.')
            return f"{num:,.2f}".replace(',', 'X').replace('.', ',').replace('X', '.')
        except (ValueError, TypeError):
            return str(value)
