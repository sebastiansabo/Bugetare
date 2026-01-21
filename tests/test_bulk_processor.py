"""Unit tests for Bulk Processor module.

Tests for:
- bulk_processor.py: Value parsing, date parsing, invoice type detection, Meta/Google/TikTok parsing
"""
import sys
import os

# Set dummy DATABASE_URL before importing modules that require it
os.environ.setdefault('DATABASE_URL', 'postgresql://test:test@localhost:5432/test')

import pytest
from unittest.mock import patch, MagicMock
from datetime import datetime

# Add project root to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'jarvis'))

from accounting.bugetare.bulk_processor import (
    parse_value,
    parse_romanian_date,
    parse_english_date,
    detect_invoice_type,
    parse_meta_invoice,
    parse_google_ads_invoice,
    parse_tiktok_invoice,
    parse_anthropic_invoice,
    parse_efactura_invoice,
    parse_generic_invoice,
    process_bulk_invoices,
    generate_summary_text
)


# ============== VALUE PARSING TESTS ==============

class TestParseValue:
    """Tests for parse_value() function."""

    def test_european_format_comma_decimal(self):
        """European format: 1.234,56"""
        assert parse_value('3.499,00') == 3499.00

    def test_us_format_dot_decimal(self):
        """US format: 1,234.56"""
        assert parse_value('3,499.00') == 3499.00

    def test_comma_only_as_decimal(self):
        """874,90 -> 874.90"""
        assert parse_value('874,90') == 874.90

    def test_simple_decimal(self):
        """1234.56"""
        assert parse_value('1234.56') == 1234.56

    def test_no_decimal(self):
        """1234"""
        assert parse_value('1234') == 1234.0

    def test_whitespace_stripped(self):
        """  123,45  """
        assert parse_value('  123,45  ') == 123.45

    def test_large_european_number(self):
        """1.234.567,89"""
        assert parse_value('1.234.567,89') == 1234567.89

    def test_large_us_number(self):
        """1,234,567.89"""
        assert parse_value('1,234,567.89') == 1234567.89

    def test_multiple_dots_format(self):
        """3.499.00 (last dot is decimal)"""
        assert parse_value('3.499.00') == 3499.00

    def test_comma_as_thousand_separator(self):
        """12,345 (no decimal part, comma is thousand separator)"""
        assert parse_value('12,345') == 12345.0


# ============== DATE PARSING TESTS ==============

class TestParseRomanianDate:
    """Tests for parse_romanian_date() function."""

    def test_short_month_lowercase(self):
        """22 nov. 2025"""
        result = parse_romanian_date('22 nov. 2025')
        assert result is not None
        assert result.year == 2025
        assert result.month == 11
        assert result.day == 22

    def test_full_month_lowercase(self):
        """15 noiembrie 2025"""
        result = parse_romanian_date('15 noiembrie 2025')
        assert result is not None
        assert result.month == 11

    def test_short_month_uppercase(self):
        """1 Ian 2025"""
        result = parse_romanian_date('1 IAN 2025')
        # Should handle case-insensitive
        assert result is not None

    def test_single_digit_day(self):
        """5 mar. 2025"""
        result = parse_romanian_date('5 mar. 2025')
        assert result.day == 5
        assert result.month == 3

    def test_unknown_format_returns_none(self):
        """Invalid date string"""
        result = parse_romanian_date('invalid date')
        assert result is None


class TestParseEnglishDate:
    """Tests for parse_english_date() function."""

    def test_month_day_year(self):
        """December 4, 2025"""
        result = parse_english_date('December 4, 2025')
        assert result is not None
        assert result.year == 2025
        assert result.month == 12
        assert result.day == 4

    def test_day_month_year(self):
        """4 December 2025"""
        result = parse_english_date('4 December 2025')
        assert result is not None
        assert result.month == 12

    def test_short_month(self):
        """Dec 15, 2025"""
        result = parse_english_date('Dec 15, 2025')
        assert result is not None
        assert result.month == 12

    def test_no_comma(self):
        """November 1 2025"""
        result = parse_english_date('November 1 2025')
        assert result is not None

    def test_empty_returns_none(self):
        assert parse_english_date('') is None

    def test_none_returns_none(self):
        assert parse_english_date(None) is None


# ============== INVOICE TYPE DETECTION ==============

class TestDetectInvoiceType:
    """Tests for detect_invoice_type() function."""

    def test_detects_meta(self):
        assert detect_invoice_type('Meta Platforms Ireland') == 'meta'

    def test_detects_meta_fbads(self):
        assert detect_invoice_type('FBADS-123-456') == 'meta'

    def test_detects_meta_facebook(self):
        assert detect_invoice_type('Facebook Ads invoice') == 'meta'

    def test_detects_google_ads(self):
        assert detect_invoice_type('Google Ads Invoice') == 'google_ads'

    def test_detects_google_adwords(self):
        assert detect_invoice_type('Google AdWords Campaign') == 'google_ads'

    def test_detects_anthropic(self):
        assert detect_invoice_type('Anthropic Invoice') == 'anthropic'

    def test_detects_anthropic_claude(self):
        assert detect_invoice_type('Claude API Usage') == 'anthropic'

    def test_detects_tiktok(self):
        assert detect_invoice_type('TikTok Information Technologies') == 'tiktok'

    def test_detects_efactura(self):
        assert detect_invoice_type('RO eFactura document') == 'efactura'

    def test_detects_dreamstime(self):
        assert detect_invoice_type('Dreamstime Stock Photos') == 'dreamstime'

    def test_unknown_returns_generic(self):
        assert detect_invoice_type('Unknown Company Invoice') == 'generic'


# ============== META INVOICE PARSING ==============

class TestParseMetaInvoice:
    """Tests for parse_meta_invoice() function."""

    def test_extracts_supplier_info(self):
        text = 'Some Meta invoice text'
        result = parse_meta_invoice(text)
        assert result['supplier'] == 'Meta Platforms Ireland Limited'
        assert result['supplier_vat'] == 'IE9692928F'

    def test_extracts_invoice_number_fbads(self):
        text = 'Invoice FBADS-123-456789'
        result = parse_meta_invoice(text)
        assert result['invoice_number'] == 'FBADS-123-456789'

    def test_extracts_invoice_number_tranzactie(self):
        text = 'ID tranzacție 123-456789'
        result = parse_meta_invoice(text)
        assert result['invoice_number'] == '123-456789'

    def test_extracts_value_efectuat(self):
        text = 'Efectuat 380,30 RON'
        result = parse_meta_invoice(text)
        assert result['invoice_value'] == 380.30

    def test_extracts_currency_ron(self):
        text = 'Total 100 RON'
        result = parse_meta_invoice(text)
        assert result['currency'] == 'RON'

    def test_extracts_currency_eur(self):
        text = 'Total 100 EUR'
        result = parse_meta_invoice(text)
        assert result['currency'] == 'EUR'

    def test_extracts_customer_vat(self):
        text = 'VAT: RO50186814'
        result = parse_meta_invoice(text)
        assert result['customer_vat'] == 'RO50186814'

    def test_items_dict_exists(self):
        text = 'Meta invoice'
        result = parse_meta_invoice(text)
        assert 'items' in result
        assert isinstance(result['items'], dict)


# ============== GOOGLE ADS INVOICE PARSING ==============

class TestParseGoogleAdsInvoice:
    """Tests for parse_google_ads_invoice() function."""

    def test_extracts_supplier_info(self):
        result = parse_google_ads_invoice('Google invoice')
        assert result['supplier'] == 'Google Ireland Limited'
        assert result['supplier_vat'] == 'IE6388047V'

    def test_extracts_invoice_number(self):
        text = 'Invoice number: 1234567890'
        result = parse_google_ads_invoice(text)
        assert result['invoice_number'] == '1234567890'

    def test_extracts_invoice_date(self):
        text = 'Invoice date: December 15, 2025'
        result = parse_google_ads_invoice(text)
        assert result['invoice_date'] == 'December 15, 2025'

    def test_extracts_total_amount(self):
        text = 'Total amount due: 1,234.56'
        result = parse_google_ads_invoice(text)
        assert result['invoice_value'] == 1234.56


# ============== TIKTOK INVOICE PARSING ==============

class TestParseTikTokInvoice:
    """Tests for parse_tiktok_invoice() function."""

    def test_extracts_supplier_info(self):
        result = parse_tiktok_invoice('TikTok invoice')
        assert result['supplier'] == 'TikTok Information Technologies UK Limited'
        assert result['supplier_vat'] == 'GB485763736'

    def test_extracts_invoice_number(self):
        text = 'Invoice # BDUK20253368656'
        result = parse_tiktok_invoice(text)
        assert result['invoice_number'] == 'BDUK20253368656'

    def test_extracts_invoice_date(self):
        text = 'Invoice Date 15, September, 2025'
        result = parse_tiktok_invoice(text)
        assert '15' in result['invoice_date']
        assert 'September' in result['invoice_date']

    def test_extracts_total_in_ron(self):
        text = 'Total in RON 22.00'
        result = parse_tiktok_invoice(text)
        assert result['invoice_value'] == 22.00

    def test_campaigns_alias_exists(self):
        result = parse_tiktok_invoice('TikTok')
        assert 'campaigns' in result


# ============== ANTHROPIC INVOICE PARSING ==============

class TestParseAnthropicInvoice:
    """Tests for parse_anthropic_invoice() function."""

    def test_extracts_supplier_info(self):
        result = parse_anthropic_invoice('Anthropic invoice')
        assert result['supplier'] == 'Anthropic, PBC'
        assert result['currency'] == 'USD'

    def test_extracts_invoice_number(self):
        text = 'Invoice number KCSFWF6E-0001'
        result = parse_anthropic_invoice(text)
        assert result['invoice_number'] == 'KCSFWF6E-0001'

    def test_extracts_amount_due(self):
        text = 'Amount due $50.00 USD'
        result = parse_anthropic_invoice(text)
        assert result['invoice_value'] == 50.00

    def test_extracts_credit_purchase_item(self):
        text = 'One-time credit purchase 1 $50.00'
        result = parse_anthropic_invoice(text)
        assert 'One-time credit purchase' in result['items']


# ============== EFACTURA PARSING ==============

class TestParseEfacturaInvoice:
    """Tests for parse_efactura_invoice() function."""

    def test_default_currency_ron(self):
        result = parse_efactura_invoice('')
        assert result['currency'] == 'RON'

    def test_extracts_data_emitere(self):
        text = 'Data emitere 2025-12-04'
        result = parse_efactura_invoice(text)
        assert result['invoice_date'] == '2025-12-04'

    def test_extracts_supplier_vat(self):
        text = 'Identificatorul TVA\nRO12345678'
        result = parse_efactura_invoice(text)
        assert result['supplier_vat'] == 'RO12345678'

    def test_extracts_total_plata(self):
        text = 'TOTAL PLATA\n647,35'
        result = parse_efactura_invoice(text)
        assert result['invoice_value'] == 647.35


# ============== GENERIC INVOICE PARSING ==============

class TestParseGenericInvoice:
    """Tests for parse_generic_invoice() function."""

    def test_extracts_factura_nr(self):
        text = 'Factura nr. ABC-123'
        result = parse_generic_invoice(text)
        assert result['invoice_number'] == 'ABC-123'

    def test_extracts_invoice_no(self):
        text = 'Invoice no: INV-2025-001'
        result = parse_generic_invoice(text)
        assert result['invoice_number'] == 'INV-2025-001'

    def test_extracts_date(self):
        text = 'Data: 15.11.2025'
        result = parse_generic_invoice(text)
        assert result['invoice_date'] == '15.11.2025'

    def test_extracts_total(self):
        text = 'Total: 1234.56 RON'
        result = parse_generic_invoice(text)
        assert result['invoice_value'] == 1234.56

    def test_extracts_currency(self):
        text = 'Amount 100 EUR'
        result = parse_generic_invoice(text)
        assert result['currency'] == 'EUR'

    def test_default_currency_ron(self):
        text = 'Total: 100'
        result = parse_generic_invoice(text)
        assert result['currency'] == 'RON'


# ============== BULK PROCESSING TESTS ==============

class TestProcessBulkInvoices:
    """Tests for process_bulk_invoices() function."""

    @patch('accounting.bugetare.bulk_processor.extract_text_from_bytes')
    def test_processes_single_invoice(self, mock_extract):
        mock_extract.return_value = 'Meta Platforms Ireland FBADS-123-456 Efectuat 100,00 RON'

        files = [(b'pdf content', 'invoice.pdf')]
        result = process_bulk_invoices(files)

        assert result['count'] == 1
        assert result['total'] == 100.0
        assert len(result['invoices']) == 1

    @patch('accounting.bugetare.bulk_processor.extract_text_from_bytes')
    def test_processes_multiple_invoices(self, mock_extract):
        mock_extract.side_effect = [
            'Meta Platforms Efectuat 100,00 RON',
            'Meta Platforms Efectuat 200,00 RON'
        ]

        files = [(b'pdf1', 'inv1.pdf'), (b'pdf2', 'inv2.pdf')]
        result = process_bulk_invoices(files)

        assert result['count'] == 2
        assert result['total'] == 300.0

    @patch('accounting.bugetare.bulk_processor.extract_text_from_bytes')
    def test_skips_empty_text(self, mock_extract):
        mock_extract.return_value = ''

        files = [(b'empty', 'empty.pdf')]
        result = process_bulk_invoices(files)

        assert result['count'] == 0

    @patch('accounting.bugetare.bulk_processor.extract_text_from_bytes')
    def test_returns_by_supplier(self, mock_extract):
        mock_extract.return_value = 'Meta Platforms Ireland Efectuat 100,00 RON'

        files = [(b'pdf', 'invoice.pdf')]
        result = process_bulk_invoices(files)

        assert 'by_supplier' in result
        assert 'Meta Platforms Ireland Limited' in result['by_supplier']

    @patch('accounting.bugetare.bulk_processor.extract_text_from_bytes')
    def test_returns_by_item(self, mock_extract):
        mock_extract.return_value = 'Meta invoice'

        files = [(b'pdf', 'invoice.pdf')]
        result = process_bulk_invoices(files)

        assert 'by_item' in result
        assert 'by_campaign' in result  # Alias


# ============== SUMMARY TEXT GENERATION ==============

class TestGenerateSummaryText:
    """Tests for generate_summary_text() function."""

    def test_includes_total_info(self):
        report = {
            'count': 5,
            'total': 1234.56,
            'currency': 'RON',
            'by_month': {},
            'by_supplier': {},
            'by_item': {}
        }
        result = generate_summary_text(report)

        assert 'Total Invoices: 5' in result
        assert '1,234.56' in result
        assert 'RON' in result

    def test_includes_monthly_breakdown(self):
        report = {
            'count': 1,
            'total': 100,
            'currency': 'RON',
            'by_month': {'2025-11': {'count': 1, 'total': 100}},
            'by_supplier': {},
            'by_item': {}
        }
        result = generate_summary_text(report)

        assert 'MONTHLY SUMMARY' in result
        assert 'November 2025' in result

    def test_includes_supplier_breakdown(self):
        report = {
            'count': 1,
            'total': 100,
            'currency': 'RON',
            'by_month': {},
            'by_supplier': {'Test Supplier': {'count': 1, 'total': 100}},
            'by_item': {}
        }
        result = generate_summary_text(report)

        assert 'BY SUPPLIER' in result
        assert 'Test Supplier' in result


# Run with: pytest tests/test_bulk_processor.py -v
if __name__ == '__main__':
    pytest.main([__file__, '-v'])
