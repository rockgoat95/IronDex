
from utils.supabase_manager import SupabaseManager

class DataRepository:
    def __init__(self):
        self.sb_manager = SupabaseManager()

    def get_brand_names(self) -> list:
        """Fetches all brand names from the database."""
        try:
            response = self.sb_manager.client.table("brands").select("name").execute()
            return [brand['name'] for brand in response.data] if response.data else []
        except Exception as e:
            print(f"Error fetching brand names: {e}")
            return []

    def get_brand_machines(self, brand_name: str) -> list:
        """Fetches all machines for a given brand name."""
        try:
            brand_id_response = self.sb_manager.client.table("brands").select("id").eq("name", brand_name).execute()
            if not brand_id_response.data:
                print(f"Brand '{brand_name}' not found.")
                return []

            brand_id = brand_id_response.data[0]['id']
            machines_response = self.sb_manager.client.table("machines").select("name, type").eq("brand_id", brand_id).execute()
            return machines_response.data
        except Exception as e:
            print(f"Error fetching machines for brand {brand_name}: {e}")
            return []
