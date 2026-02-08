"""OAuth Repository - Data access layer for e-Factura OAuth token operations.

Handles OAuth token CRUD for e-Factura (ANAF) connections.
"""
import json
from datetime import datetime
from typing import Optional

from database import get_db, get_cursor, release_db


class OAuthRepository:
    """Repository for e-Factura OAuth token operations."""

    def get_tokens(self, company_cif: str) -> Optional[dict]:
        """Get OAuth tokens for a company's e-Factura connection.

        Args:
            company_cif: Company CIF (without RO prefix)

        Returns:
            Dict with tokens or None if not found
        """
        conn = get_db()
        try:
            cursor = get_cursor(conn)
            cursor.execute('''
                SELECT credentials FROM connectors
                WHERE connector_type = 'efactura'
                AND name = %s
                AND status = 'connected'
            ''', (company_cif,))
            row = cursor.fetchone()
            if row and row['credentials']:
                return row['credentials']
            return None
        finally:
            release_db(conn)

    def save_tokens(self, company_cif: str, tokens: dict) -> bool:
        """Save OAuth tokens for a company's e-Factura connection.

        Creates connector if not exists, updates if exists.

        Args:
            company_cif: Company CIF (without RO prefix)
            tokens: Dict with access_token, refresh_token, expires_at, etc.

        Returns:
            True if successful
        """
        conn = get_db()
        try:
            cursor = get_cursor(conn)

            cursor.execute('''
                SELECT id FROM connectors
                WHERE connector_type = 'efactura' AND name = %s
            ''', (company_cif,))
            existing = cursor.fetchone()

            if existing:
                cursor.execute('''
                    UPDATE connectors
                    SET credentials = %s,
                        status = 'connected',
                        updated_at = CURRENT_TIMESTAMP
                    WHERE id = %s
                ''', (json.dumps(tokens), existing['id']))
            else:
                cursor.execute('''
                    INSERT INTO connectors (connector_type, name, status, credentials, config)
                    VALUES ('efactura', %s, 'connected', %s, '{}')
                ''', (company_cif, json.dumps(tokens)))

            conn.commit()
            return True
        except Exception:
            conn.rollback()
            raise
        finally:
            release_db(conn)

    def delete_tokens(self, company_cif: str) -> bool:
        """Remove OAuth tokens for a company (disconnect).

        Args:
            company_cif: Company CIF

        Returns:
            True if tokens were removed
        """
        conn = get_db()
        try:
            cursor = get_cursor(conn)
            cursor.execute('''
                UPDATE connectors
                SET credentials = '{}',
                    status = 'disconnected',
                    updated_at = CURRENT_TIMESTAMP
                WHERE connector_type = 'efactura' AND name = %s
            ''', (company_cif,))
            affected = cursor.rowcount
            conn.commit()
            return affected > 0
        except Exception:
            conn.rollback()
            raise
        finally:
            release_db(conn)

    def get_status(self, company_cif: str) -> dict:
        """Get OAuth authentication status for a company.

        Args:
            company_cif: Company CIF

        Returns:
            Dict with authenticated, expires_at, is_expired, cif
        """
        tokens = self.get_tokens(company_cif)

        if not tokens or not tokens.get('access_token'):
            return {
                'authenticated': False,
                'expires_at': None,
                'cif': company_cif,
            }

        expires_at = tokens.get('expires_at')
        is_expired = False

        if expires_at:
            if isinstance(expires_at, str):
                expires_dt = datetime.fromisoformat(expires_at.replace('Z', ''))
            else:
                expires_dt = expires_at
            is_expired = datetime.utcnow() >= expires_dt

        return {
            'authenticated': True,
            'expires_at': expires_at,
            'is_expired': is_expired,
            'cif': company_cif,
        }
