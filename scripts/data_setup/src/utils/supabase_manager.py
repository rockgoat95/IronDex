import os
import uuid

import requests
from config.supabase import SUPABASE_SERVICE_ROLE_KEY, SUPABASE_URL
from supabase import Client, create_client


class SupabaseManager:
    """
    A centralized manager for handling all Supabase operations,
    including storage files, table data uploads, and data queries.
    """

    def __init__(self):
        """Initializes the Supabase client."""
        if not SUPABASE_URL or not SUPABASE_SERVICE_ROLE_KEY:
            raise ConnectionError(
                "Supabase credentials not found in environment variables."
            )

        try:
            self.client: Client = create_client(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)
            print("SupabaseManager initialized successfully.")
        except Exception as e:
            raise ConnectionError(f"Failed to create Supabase client: {e}")

    def upload_from_local_path(
        self, *, bucket_name: str, file_path: str, destination_path: str | None = None
    ):
        """
        Uploads a file from a local path to Supabase storage.

        Args:
            bucket_name: The name of the storage bucket.
            file_path: The local path of the file to upload.
            destination_path: Optional destination path in the bucket. If
                None, uses the original filename.

        Returns:
            The public URL of the uploaded file.
        """
        if not os.path.exists(file_path):
            raise FileNotFoundError(f"Local file not found: {file_path}")

        dest = destination_path or os.path.basename(file_path)

        with open(file_path, "rb") as f:
            # First, check if file already exists to avoid re-uploading
            res = self.client.storage.from_(bucket_name).list(
                path=os.path.dirname(dest) or None
            )
            if dest in [item["name"] for item in res]:
                print(
                    (
                        f"File '{dest}' already exists in bucket "
                        f"'{bucket_name}'. Skipping upload."
                    )
                )
            else:
                self.client.storage.from_(bucket_name).upload(path=dest, file=f)
                print(f"Successfully uploaded '{dest}' to bucket '{bucket_name}'.")

        return self.client.storage.from_(bucket_name).get_public_url(dest)

    def upload_from_url(self, *, bucket_name: str, url: str):
        """
            Downloads a file from a URL and uploads it to Supabase storage.
        For freemotionfitness.com URLs, uses local fallback files from
        data/freemotion/ directory.
        """
        try:
            # Special handling for freemotionfitness.com URLs (CAPTCHA protection)
            if url.startswith("https://freemotionfitness.com/"):
                return self._upload_freemotion_from_local(bucket_name, url)

            # Regular URL download and upload
            return self._upload_from_remote_url(bucket_name, url)

        except Exception as e:
            print(f"An unexpected error occurred during URL upload: {e}")
            return None

    def _upload_freemotion_from_local(self, bucket_name: str, url: str):
        """
        Uploads freemotion images from local data/freemotion directory.
        Extracts filename from URL and searches in local directory.
        """
        filename = url.split("/")[-1]
        freemotion_dir = os.path.join(
            os.path.dirname(__file__), "../../data/freemotion"
        )
        local_file_path = os.path.join(freemotion_dir, filename)

        if not os.path.exists(local_file_path):
            print(f"❌ Local freemotion file not found: {filename}")
            print(f"   Searched in: {freemotion_dir}")
            return None

        print(f"✅ Found local freemotion file: {filename}")

        # Generate destination path with UUID to avoid conflicts
        file_extension = os.path.splitext(filename)[-1]
        destination_path = f"{uuid.uuid4()}{file_extension}"

        # Use existing upload_from_local_path method
        try:
            with open(local_file_path, "rb") as f:
                # Determine content type based on file extension
                content_type = self._get_content_type_from_extension(file_extension)

                self.client.storage.from_(bucket_name).upload(
                    path=destination_path,
                    file=f,
                    file_options={"content-type": content_type},
                )

            print(
                (
                    "Successfully uploaded freemotion file "
                    f"{filename} to {destination_path}"
                )
            )
            return self.client.storage.from_(bucket_name).get_public_url(
                destination_path
            )

        except Exception as e:
            print(f"❌ Error uploading freemotion file {filename}: {e}")
            return None

    def _upload_from_remote_url(self, bucket_name: str, url: str):
        """
        Downloads and uploads a file from a remote URL with validation.
        """
        headers = {
            "User-Agent": (
                "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
                "AppleWebKit/537.36 (KHTML, like Gecko) "
                "Chrome/58.0.3029.110 Safari/537.36"
            )
        }
        response = requests.get(url, headers=headers, timeout=30)
        response.raise_for_status()
        content = response.content
        content_type = response.headers.get("content-type", "application/octet-stream")

        # Validate that we received an actual image, not HTML (CAPTCHA protection)
        if not content_type.startswith("image/"):
            print(f"❌ 경고: 이미지가 아닌 응답받음 - Content-Type: {content_type}")
            if "captcha" in content.decode("utf-8", errors="ignore").lower():
                raise ValueError(f"CAPTCHA 차단됨 - URL: {url}")
            else:
                raise ValueError(f"이미지가 아닌 응답 - Content-Type: {content_type}")

        # Generate a random filename with proper extension
        file_extension = os.path.splitext(url.split("?")[0])[-1]
        if not file_extension or len(file_extension) > 5:
            file_extension = self._get_extension_from_content_type(content_type)

        destination_path = f"{uuid.uuid4()}{file_extension}"

        self.client.storage.from_(bucket_name).upload(
            path=destination_path,
            file=content,
            file_options={"content-type": content_type},
        )
        print(f"Successfully uploaded file from {url} to {destination_path}")

        return self.client.storage.from_(bucket_name).get_public_url(destination_path)

    def _get_content_type_from_extension(self, extension: str) -> str:
        """Returns appropriate content-type based on file extension."""
        ext_to_mime = {
            ".jpg": "image/jpeg",
            ".jpeg": "image/jpeg",
            ".png": "image/png",
            ".webp": "image/webp",
            ".svg": "image/svg+xml",
            ".gif": "image/gif",
        }
        return ext_to_mime.get(extension.lower(), "application/octet-stream")

    def _get_extension_from_content_type(self, content_type: str) -> str:
        """Returns appropriate file extension based on content-type."""
        mime_to_ext = {
            "image/jpeg": ".jpg",
            "image/png": ".png",
            "image/webp": ".webp",
            "image/svg+xml": ".svg",
            "image/gif": ".gif",
        }
        return mime_to_ext.get(content_type, "")

    def upsert_to_table(
        self,
        *,
        table_name: str,
        data: list,
        schema: str | None = None,
    ):
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
            if schema:
                query = self.client.postgrest.schema(schema).from_(table_name)
            else:
                query = self.client.table(table_name)

            query.upsert(data).execute()
            print(f"Successfully upserted {len(data)} rows to table '{table_name}'.")
        except Exception as e:
            print(f"Error upserting data to table '{table_name}': {e}")
