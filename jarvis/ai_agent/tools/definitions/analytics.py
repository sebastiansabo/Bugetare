"""Analytics and summary tools — wrappers around AnalyticsService."""

from ai_agent.tools.registry import tool_registry
from ai_agent.services.analytics_service import AnalyticsService

_analytics = AnalyticsService()


def get_invoice_summary(params: dict, user_id: int) -> dict:
    """Get invoice allocation summary grouped by a dimension."""
    return _analytics.get_invoice_summary(
        group_by=params.get('group_by', 'company'),
        company=params.get('company'),
        department=params.get('department'),
        brand=params.get('brand'),
        supplier=params.get('supplier'),
        start_date=params.get('start_date'),
        end_date=params.get('end_date'),
    )


def get_monthly_trend(params: dict, user_id: int) -> dict:
    """Get monthly spending trend."""
    return _analytics.get_monthly_trend(
        company=params.get('company'),
        department=params.get('department'),
        brand=params.get('brand'),
        supplier=params.get('supplier'),
        start_date=params.get('start_date'),
        end_date=params.get('end_date'),
    )


def get_top_suppliers(params: dict, user_id: int) -> dict:
    """Get top N suppliers by total spend."""
    return _analytics.get_top_suppliers(
        limit=min(int(params.get('limit', 10)), 50),
        company=params.get('company'),
        department=params.get('department'),
        brand=params.get('brand'),
        start_date=params.get('start_date'),
        end_date=params.get('end_date'),
    )


def get_transaction_summary(params: dict, user_id: int) -> dict:
    """Get bank transaction summary."""
    return _analytics.get_transaction_summary(
        company_cui=params.get('company_cui'),
        supplier=params.get('supplier'),
        date_from=params.get('date_from'),
        date_to=params.get('date_to'),
    )


# Register tools
tool_registry.register(
    name='get_invoice_summary',
    description=(
        'Get aggregated invoice summary grouped by company, department, brand, or supplier. '
        'Returns totals in RON and EUR with invoice counts. Supports date range and entity filters.'
    ),
    input_schema={
        'type': 'object',
        'properties': {
            'group_by': {
                'type': 'string',
                'enum': ['company', 'department', 'brand', 'supplier'],
                'description': 'Dimension to group by (default: company)',
            },
            'company': {'type': 'string', 'description': 'Filter by company name'},
            'department': {'type': 'string', 'description': 'Filter by department'},
            'brand': {'type': 'string', 'description': 'Filter by brand'},
            'supplier': {'type': 'string', 'description': 'Filter by supplier'},
            'start_date': {'type': 'string', 'description': 'Start date (YYYY-MM-DD)'},
            'end_date': {'type': 'string', 'description': 'End date (YYYY-MM-DD)'},
        },
    },
    handler=get_invoice_summary,
    permission='accounting.view',
)

tool_registry.register(
    name='get_monthly_trend',
    description=(
        'Get monthly invoice spending trend over time. '
        'Returns month-by-month totals in RON and EUR with invoice counts.'
    ),
    input_schema={
        'type': 'object',
        'properties': {
            'company': {'type': 'string', 'description': 'Filter by company name'},
            'department': {'type': 'string', 'description': 'Filter by department'},
            'brand': {'type': 'string', 'description': 'Filter by brand'},
            'supplier': {'type': 'string', 'description': 'Filter by supplier'},
            'start_date': {'type': 'string', 'description': 'Start date (YYYY-MM-DD)'},
            'end_date': {'type': 'string', 'description': 'End date (YYYY-MM-DD)'},
        },
    },
    handler=get_monthly_trend,
    permission='accounting.view',
)

tool_registry.register(
    name='get_top_suppliers',
    description='Get the top N suppliers ranked by total spending (in RON).',
    input_schema={
        'type': 'object',
        'properties': {
            'limit': {'type': 'integer', 'description': 'Number of suppliers to return (default 10, max 50)'},
            'company': {'type': 'string', 'description': 'Filter by company name'},
            'department': {'type': 'string', 'description': 'Filter by department'},
            'brand': {'type': 'string', 'description': 'Filter by brand'},
            'start_date': {'type': 'string', 'description': 'Start date (YYYY-MM-DD)'},
            'end_date': {'type': 'string', 'description': 'End date (YYYY-MM-DD)'},
        },
    },
    handler=get_top_suppliers,
    permission='accounting.view',
)

tool_registry.register(
    name='get_transaction_summary',
    description='Get bank transaction summary with status breakdown and per-supplier totals.',
    input_schema={
        'type': 'object',
        'properties': {
            'company_cui': {'type': 'string', 'description': 'Filter by company CUI/VAT'},
            'supplier': {'type': 'string', 'description': 'Filter by supplier/vendor name'},
            'date_from': {'type': 'string', 'description': 'Start date (YYYY-MM-DD)'},
            'date_to': {'type': 'string', 'description': 'End date (YYYY-MM-DD)'},
        },
    },
    handler=get_transaction_summary,
    permission='accounting.view',
)
