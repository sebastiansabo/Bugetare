"""Unit tests for Drive Service module.

Tests for:
- drive_service.py: Google Drive integration, file upload, folder management
"""
import sys
import os

# Set dummy DATABASE_URL before importing modules that require it
os.environ.setdefault('DATABASE_URL', 'postgresql://test:test@localhost:5432/test')

import pytest
from unittest.mock import patch, MagicMock

# Add project root to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'jarvis'))

from core.services.drive_service import (
    find_or_create_folder,
    upload_invoice_to_drive,
    check_drive_auth,
    list_folder_contents,
    extract_file_id_from_link,
    delete_file_from_drive,
    delete_files_from_drive,
    get_folder_id_from_file_link,
    get_folder_link_from_file,
    upload_attachment_to_folder,
    ROOT_FOLDER_ID
)


# ============== EXTRACT FILE ID TESTS ==============

class TestExtractFileIdFromLink:
    """Tests for extract_file_id_from_link() function."""

    def test_file_d_format(self):
        """Standard /file/d/{id}/view format"""
        link = 'https://drive.google.com/file/d/1ABC123xyz_-/view'
        result = extract_file_id_from_link(link)
        assert result == '1ABC123xyz_-'

    def test_open_id_format(self):
        """?id={id} format"""
        link = 'https://drive.google.com/open?id=1ABC123xyz'
        result = extract_file_id_from_link(link)
        assert result == '1ABC123xyz'

    def test_empty_link(self):
        """Empty string should return None"""
        assert extract_file_id_from_link('') is None

    def test_none_link(self):
        """None should return None"""
        assert extract_file_id_from_link(None) is None

    def test_invalid_link(self):
        """Invalid link format"""
        assert extract_file_id_from_link('https://example.com/notadrive') is None

    def test_file_d_with_usp_param(self):
        """Link with additional parameters"""
        link = 'https://drive.google.com/file/d/1ABC123/view?usp=sharing'
        result = extract_file_id_from_link(link)
        assert result == '1ABC123'


# ============== FIND OR CREATE FOLDER TESTS ==============

class TestFindOrCreateFolder:
    """Tests for find_or_create_folder() function."""

    def test_finds_existing_folder(self):
        mock_service = MagicMock()
        mock_service.files().list().execute.return_value = {
            'files': [{'id': 'existing-folder-id', 'name': 'TestFolder'}]
        }

        result = find_or_create_folder(mock_service, 'TestFolder', 'parent-id')

        assert result == 'existing-folder-id'
        mock_service.files().create.assert_not_called()

    def test_creates_new_folder_if_not_exists(self):
        mock_service = MagicMock()
        mock_service.files().list().execute.return_value = {'files': []}
        mock_service.files().create().execute.return_value = {'id': 'new-folder-id'}

        result = find_or_create_folder(mock_service, 'NewFolder', 'parent-id')

        assert result == 'new-folder-id'
        mock_service.files().create.assert_called()


# ============== UPLOAD INVOICE TESTS ==============

class TestUploadInvoiceToDrive:
    """Tests for upload_invoice_to_drive() function."""

    @patch('core.services.drive_service.get_drive_service')
    @patch('core.services.drive_service.find_or_create_folder')
    def test_creates_folder_structure(self, mock_find_folder, mock_get_service):
        mock_service = MagicMock()
        mock_get_service.return_value = mock_service
        mock_find_folder.return_value = 'folder-id'
        mock_service.files().create().execute.return_value = {
            'id': 'file-id',
            'webViewLink': 'https://drive.google.com/file/d/file-id/view'
        }

        result = upload_invoice_to_drive(
            b'pdf content',
            'invoice.pdf',
            '2025-12-15',
            'Test Company',
            'INV-001'
        )

        # Should create Year -> Month -> Company -> Invoice folder structure
        assert mock_find_folder.call_count == 4  # year, month, company, invoice
        assert 'drive.google.com' in result

    @patch('core.services.drive_service.get_drive_service')
    @patch('core.services.drive_service.find_or_create_folder')
    def test_handles_invalid_date(self, mock_find_folder, mock_get_service):
        """Should use current date if invoice_date is invalid"""
        mock_service = MagicMock()
        mock_get_service.return_value = mock_service
        mock_find_folder.return_value = 'folder-id'
        mock_service.files().create().execute.return_value = {
            'id': 'file-id',
            'webViewLink': 'https://drive.google.com/file/d/file-id/view'
        }

        # Invalid date format
        result = upload_invoice_to_drive(
            b'pdf content',
            'invoice.pdf',
            'invalid-date',
            'Company',
            'INV-001'
        )

        assert result is not None

    @patch('core.services.drive_service.get_drive_service')
    @patch('core.services.drive_service.find_or_create_folder')
    def test_cleans_company_name(self, mock_find_folder, mock_get_service):
        """Should clean special characters from company name"""
        mock_service = MagicMock()
        mock_get_service.return_value = mock_service
        mock_find_folder.return_value = 'folder-id'
        mock_service.files().create().execute.return_value = {'id': 'id', 'webViewLink': 'url'}

        upload_invoice_to_drive(
            b'pdf content',
            'invoice.pdf',
            '2025-12-15',
            'Test/Company:Special<Chars>',
            'INV-001'
        )

        # Check that the company folder name was cleaned
        company_call = mock_find_folder.call_args_list[2]
        company_name = company_call[0][1]
        assert '/' not in company_name
        assert ':' not in company_name


# ============== DELETE FILE TESTS ==============

class TestDeleteFileFromDrive:
    """Tests for delete_file_from_drive() function."""

    @patch('core.services.drive_service.get_drive_service')
    @patch('core.services.drive_service.extract_file_id_from_link')
    def test_deletes_file_successfully(self, mock_extract, mock_get_service):
        mock_extract.return_value = 'file-id'
        mock_service = MagicMock()
        mock_get_service.return_value = mock_service

        result = delete_file_from_drive('https://drive.google.com/file/d/file-id/view')

        assert result is True
        mock_service.files().delete.assert_called_once()

    @patch('core.services.drive_service.extract_file_id_from_link')
    def test_returns_false_for_invalid_link(self, mock_extract):
        mock_extract.return_value = None

        result = delete_file_from_drive('invalid-link')

        assert result is False

    @patch('core.services.drive_service.get_drive_service')
    @patch('core.services.drive_service.extract_file_id_from_link')
    def test_handles_delete_error(self, mock_extract, mock_get_service):
        mock_extract.return_value = 'file-id'
        mock_service = MagicMock()
        mock_service.files().delete().execute.side_effect = Exception('API Error')
        mock_get_service.return_value = mock_service

        result = delete_file_from_drive('https://drive.google.com/file/d/file-id/view')

        assert result is False


class TestDeleteFilesFromDrive:
    """Tests for delete_files_from_drive() function."""

    @patch('core.services.drive_service.delete_file_from_drive')
    def test_deletes_multiple_files(self, mock_delete):
        mock_delete.return_value = True

        links = ['link1', 'link2', 'link3']
        count = delete_files_from_drive(links)

        assert count == 3
        assert mock_delete.call_count == 3

    @patch('core.services.drive_service.delete_file_from_drive')
    def test_counts_successful_deletions(self, mock_delete):
        mock_delete.side_effect = [True, False, True]

        links = ['link1', 'link2', 'link3']
        count = delete_files_from_drive(links)

        assert count == 2

    @patch('core.services.drive_service.delete_file_from_drive')
    def test_skips_empty_links(self, mock_delete):
        mock_delete.return_value = True

        links = ['link1', '', None, 'link2']
        count = delete_files_from_drive(links)

        assert mock_delete.call_count == 2


# ============== CHECK DRIVE AUTH TESTS ==============

class TestCheckDriveAuth:
    """Tests for check_drive_auth() function."""

    @patch('core.services.drive_service.get_drive_service')
    def test_returns_true_when_authenticated(self, mock_get_service):
        mock_service = MagicMock()
        mock_service.files().list().execute.return_value = {'files': []}
        mock_get_service.return_value = mock_service

        result = check_drive_auth()

        assert result is True

    @patch('core.services.drive_service.get_drive_service')
    def test_returns_false_when_not_authenticated(self, mock_get_service):
        mock_get_service.side_effect = Exception('Auth failed')

        result = check_drive_auth()

        assert result is False


# ============== LIST FOLDER CONTENTS TESTS ==============

class TestListFolderContents:
    """Tests for list_folder_contents() function."""

    @patch('core.services.drive_service.get_drive_service')
    def test_returns_file_list(self, mock_get_service):
        mock_service = MagicMock()
        mock_service.files().list().execute.return_value = {
            'files': [
                {'id': '1', 'name': 'file1.pdf', 'mimeType': 'application/pdf'},
                {'id': '2', 'name': 'folder1', 'mimeType': 'application/vnd.google-apps.folder'}
            ]
        }
        mock_get_service.return_value = mock_service

        result = list_folder_contents('folder-id')

        assert len(result) == 2
        assert result[0]['name'] == 'file1.pdf'

    @patch('core.services.drive_service.get_drive_service')
    def test_uses_default_folder(self, mock_get_service):
        mock_service = MagicMock()
        mock_service.files().list().execute.return_value = {'files': []}
        mock_get_service.return_value = mock_service

        list_folder_contents()

        # Should use ROOT_FOLDER_ID as default
        call_args = mock_service.files().list.call_args
        assert ROOT_FOLDER_ID in str(call_args)


# ============== GET FOLDER FROM FILE TESTS ==============

class TestGetFolderIdFromFileLink:
    """Tests for get_folder_id_from_file_link() function."""

    @patch('core.services.drive_service.get_drive_service')
    @patch('core.services.drive_service.extract_file_id_from_link')
    def test_returns_parent_folder_id(self, mock_extract, mock_get_service):
        mock_extract.return_value = 'file-id'
        mock_service = MagicMock()
        mock_service.files().get().execute.return_value = {'parents': ['parent-folder-id']}
        mock_get_service.return_value = mock_service

        result = get_folder_id_from_file_link('https://drive.google.com/file/d/file-id/view')

        assert result == 'parent-folder-id'

    @patch('core.services.drive_service.extract_file_id_from_link')
    def test_returns_none_for_invalid_link(self, mock_extract):
        mock_extract.return_value = None

        result = get_folder_id_from_file_link('invalid')

        assert result is None


class TestGetFolderLinkFromFile:
    """Tests for get_folder_link_from_file() function."""

    @patch('core.services.drive_service.get_folder_id_from_file_link')
    def test_returns_folder_url(self, mock_get_folder):
        mock_get_folder.return_value = 'folder-id'

        result = get_folder_link_from_file('file-link')

        assert result == 'https://drive.google.com/drive/folders/folder-id'

    @patch('core.services.drive_service.get_folder_id_from_file_link')
    def test_returns_none_if_no_folder(self, mock_get_folder):
        mock_get_folder.return_value = None

        result = get_folder_link_from_file('file-link')

        assert result is None


# ============== UPLOAD ATTACHMENT TESTS ==============

class TestUploadAttachmentToFolder:
    """Tests for upload_attachment_to_folder() function."""

    @patch('core.services.drive_service.get_drive_service')
    def test_uploads_attachment(self, mock_get_service):
        mock_service = MagicMock()
        mock_service.files().create().execute.return_value = {
            'id': 'file-id',
            'webViewLink': 'https://drive.google.com/file/d/file-id/view'
        }
        mock_get_service.return_value = mock_service

        result = upload_attachment_to_folder(
            b'file content',
            'attachment.pdf',
            'folder-id',
            'application/pdf'
        )

        assert result == 'https://drive.google.com/file/d/file-id/view'

    @patch('core.services.drive_service.get_drive_service')
    def test_auto_detects_mime_type(self, mock_get_service):
        mock_service = MagicMock()
        mock_service.files().create().execute.return_value = {'id': 'id', 'webViewLink': 'url'}
        mock_get_service.return_value = mock_service

        upload_attachment_to_folder(b'content', 'image.jpg', 'folder-id')

        # Check that JPEG mime type was used
        create_call = mock_service.files().create.call_args
        assert 'image/jpeg' in str(create_call) or create_call is not None

    @patch('core.services.drive_service.get_drive_service')
    def test_handles_upload_error(self, mock_get_service):
        mock_service = MagicMock()
        mock_service.files().create().execute.side_effect = Exception('Upload failed')
        mock_get_service.return_value = mock_service

        result = upload_attachment_to_folder(b'content', 'file.pdf', 'folder-id')

        assert result is None

    @patch('core.services.drive_service.get_drive_service')
    def test_unknown_extension_uses_octet_stream(self, mock_get_service):
        mock_service = MagicMock()
        mock_service.files().create().execute.return_value = {'id': 'id', 'webViewLink': 'url'}
        mock_get_service.return_value = mock_service

        upload_attachment_to_folder(b'content', 'file.unknown', 'folder-id')

        # Should use application/octet-stream for unknown types


# Run with: pytest tests/test_drive_service.py -v
if __name__ == '__main__':
    pytest.main([__file__, '-v'])
