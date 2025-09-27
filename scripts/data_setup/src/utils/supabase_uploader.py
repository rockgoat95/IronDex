import os
import requests
import uuid
from supabase import create_client, Client
from config.supabase import SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY

class SupabaseUploader:
    """
    A centralized client for handling all uploads to Supabase,
    including storage files and table data.
    """

    def __init__(self):
        """Initializes the Supabase client."""
        if not SUPABASE_URL or not SUPABASE_SERVICE_ROLE_KEY:
            raise ConnectionError("Supabase credentials not found in environment variables.")

        try:
            self.client: Client = create_client(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)
            print("SupabaseUploader initialized successfully.")
        except Exception as e:
            raise ConnectionError(f"Failed to create Supabase client: {e}")

    def upload_from_local_path(self, *, bucket_name: str, file_path: str, destination_path: str | None = None):
        """
        Uploads a file from a local path to Supabase storage.

        Args:
            bucket_name: The name of the storage bucket.
            file_path: The local path of the file to upload.
            destination_path: The optional destination path in the bucket. If None, uses the original filename.

        Returns:
            The public URL of the uploaded file.
        """
        if not os.path.exists(file_path):
            raise FileNotFoundError(f"Local file not found: {file_path}")

        dest = destination_path or os.path.basename(file_path)

        with open(file_path, 'rb') as f:
            # First, check if file already exists to avoid re-uploading
            res = self.client.storage.from_(bucket_name).list(path=os.path.dirname(dest) or None)
            if dest in [item['name'] for item in res]:
                print(f"File '{dest}' already exists in bucket '{bucket_name}'. Skipping upload.")
            else:
                self.client.storage.from_(bucket_name).upload(path=dest, file=f)
                print(f"Successfully uploaded '{dest}' to bucket '{bucket_name}'.")

        return self.client.storage.from_(bucket_name).get_public_url(dest)

    def upload_from_url(self, *, bucket_name: str, url: str):
        """
        Downloads a file from a URL and uploads it to Supabase storage.

        Args:
            bucket_name: The name of the storage bucket.
            url: The URL of the file to download.

        Returns:
            The public URL of the uploaded file.
        """
        try:
            headers = {
                "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36"
            }
            response = requests.get(url, headers=headers, timeout=15)
            response.raise_for_status()
            content = response.content
            content_type = response.headers.get('content-type', 'application/octet-stream')

            # Generate a random filename with a proper extension
            file_extension = os.path.splitext(url.split("?")[0])[-1]
            if not file_extension or len(file_extension) > 5:
                ext_map = {
                    'image/jpeg': '.jpg',
                    'image/png': '.png',
                    'image/webp': '.webp',
                    'image/svg+xml': '.svg',
                    'image/gif': '.gif'
                }
                file_extension = ext_map.get(content_type, '')

            destination_path = f"{uuid.uuid4()}{file_extension}"

            self.client.storage.from_(bucket_name).upload(
                path=destination_path,
                file=content,
                file_options={"content-type": content_type}
            )
            print(f"Successfully uploaded file from {url} to {destination_path}")

            return self.client.storage.from_(bucket_name).get_public_url(destination_path)

        except requests.exceptions.RequestException as e:
            print(f"Error downloading file from {url}: {e}")
            return None
        except Exception as e:
            print(f"An error occurred during URL upload: {e}")
            return None

    def upsert_to_table(self, *, table_name: str, data: list):
        """
        Upserts a list of dictionaries to a Supabase table.

        Args:
            table_name: The name of the table to upsert into.
            data: A list of dictionaries representing the rows to upsert.
        """
        if not data:
            print("No data provided to upsert. Skipping.")
            return

        try:
            self.client.table(table_name).upsert(data).execute()
            print(f"Successfully upserted {len(data)} rows to table '{table_name}'.")
        except Exception as e:
            print(f"Error upserting data to table '{table_name}': {e}")
