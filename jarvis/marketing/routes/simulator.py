"""Campaign simulator endpoints."""

import logging
from flask import jsonify
from flask_login import login_required

from database import get_db, get_cursor, release_db
from marketing import marketing_bp

logger = logging.getLogger('jarvis.marketing.routes.simulator')


@marketing_bp.route('/api/simulator/benchmarks', methods=['GET'])
@login_required
def api_sim_benchmarks():
    """Return all simulator benchmarks grouped by funnel stage."""
    conn = get_db()
    try:
        cursor = get_cursor(conn)
        cursor.execute('''
            SELECT id, channel_key, channel_label, funnel_stage, month_index,
                   cpc::float, cvr_lead::float, cvr_car::float, is_active
            FROM mkt_sim_benchmarks
            WHERE is_active = TRUE
            ORDER BY
                CASE funnel_stage
                    WHEN 'awareness' THEN 1
                    WHEN 'consideration' THEN 2
                    WHEN 'conversion' THEN 3
                END,
                channel_key, month_index
        ''')
        benchmarks = [dict(r) for r in cursor.fetchall()]
        return jsonify({'benchmarks': benchmarks})
    finally:
        release_db(conn)
