import os
import io
from datetime import datetime
from google.oauth2 import service_account
from googleapiclient.discovery import build
from googleapiclient.http import MediaIoBaseUpload

# Google Drive API scopes
SCOPES = ['https://www.googleapis.com/auth/drive.file']

# Root folder ID from shared link
ROOT_FOLDER_ID = '1MbMlTE0jKnZlxCL0sW1eY4umETOfcx9M'

# Service account credentials file path
CREDENTIALS_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SERVICE_ACCOUNT_FILE = os.path.join(CREDENTIALS_DIR, 'service-account.json')

# Alternative: credentials from environment variable (for production)
SERVICE_ACCOUNT_JSON = os.environ.get('GOOGLE_SERVICE_ACCOUNT_JSON')


def get_drive_service():
    """Get authenticated Google Drive service using Service Account."""

    if SERVICE_ACCOUNT_JSON:
        # Use credentials from environment variable (recommended for production)
        import json
        service_account_info = json.loads(SERVICE_ACCOUNT_JSON)
        credentials = service_account.Credentials.from_service_account_info(
            service_account_info, scopes=SCOPES
        )
    elif os.path.exists(SERVICE_ACCOUNT_FILE):
        # Use credentials from file
        credentials = service_account.Credentials.from_service_account_file(
            SERVICE_ACCOUNT_FILE, scopes=SCOPES
        )
    else:
        raise FileNotFoundError(
            f"Google Drive credentials not found.\n"
            f"Either set GOOGLE_SERVICE_ACCOUNT_JSON environment variable,\n"
            f"or place service-account.json at: {SERVICE_ACCOUNT_FILE}\n\n"
            f"To create a service account:\n"
            f"1. Go to Google Cloud Console -> IAM & Admin -> Service Accounts\n"
            f"2. Create a service account\n"
            f"3. Create a JSON key and download it\n"
            f"4. Share your Google Drive folder with the service account email"
        )

    return build('drive', 'v3', credentials=credentials)


def find_or_create_folder(service, folder_name: str, parent_id: str) -> str:
    """Find existing folder or create new one. Returns folder ID."""
    # Search for existing folder
    query = f"name='{folder_name}' and '{parent_id}' in parents and mimeType='application/vnd.google-apps.folder' and trashed=false"
    results = service.files().list(q=query, fields="files(id, name)").execute()
    files = results.get('files', [])

    if files:
        return files[0]['id']

    # Create new folder
    file_metadata = {
        'name': folder_name,
        'mimeType': 'application/vnd.google-apps.folder',
        'parents': [parent_id]
    }
    folder = service.files().create(body=file_metadata, fields='id').execute()
    return folder['id']


def upload_invoice_to_drive(
    file_bytes: bytes,
    filename: str,
    supplier: str,
    invoice_date: str,
    mime_type: str = 'application/pdf'
) -> str:
    """
    Upload invoice to Google Drive organized by Year/Supplier.
    Returns the file's web view link.

    Structure: Root Folder / Year / Supplier / filename
    """
    service = get_drive_service()

    # Extract year from invoice date
    try:
        date_obj = datetime.strptime(invoice_date, '%Y-%m-%d')
        year = str(date_obj.year)
    except:
        year = str(datetime.now().year)

    # Clean supplier name for folder (remove special characters)
    clean_supplier = ''.join(c for c in supplier if c.isalnum() or c in ' -_').strip()
    if not clean_supplier:
        clean_supplier = 'Unknown Supplier'

    # Create folder structure: Root / Year / Supplier
    year_folder_id = find_or_create_folder(service, year, ROOT_FOLDER_ID)
    supplier_folder_id = find_or_create_folder(service, clean_supplier, year_folder_id)

    # Upload the file
    file_metadata = {
        'name': filename,
        'parents': [supplier_folder_id]
    }

    media = MediaIoBaseUpload(
        io.BytesIO(file_bytes),
        mimetype=mime_type,
        resumable=True
    )

    file = service.files().create(
        body=file_metadata,
        media_body=media,
        fields='id, webViewLink'
    ).execute()

    return file.get('webViewLink', f"https://drive.google.com/file/d/{file['id']}/view")


def check_drive_auth() -> bool:
    """Check if Google Drive is authenticated."""
    try:
        service = get_drive_service()
        # Try to list files to verify access
        service.files().list(pageSize=1).execute()
        return True
    except Exception:
        return False


def list_folder_contents(folder_id: str = ROOT_FOLDER_ID) -> list:
    """List contents of a folder (for debugging)."""
    service = get_drive_service()
    query = f"'{folder_id}' in parents and trashed=false"
    results = service.files().list(q=query, fields="files(id, name, mimeType)").execute()
    return results.get('files', [])
