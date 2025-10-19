import http.client
import json
from urllib.parse import urlencode

API_HOST = "exercisedb.p.rapidapi.com"
API_KEY = "1559a86030msh7ef5c0ec01002f7p1ef3f8jsn86b93a23573f"
EXERCISE_ID = "0009"
RESOLUTION = "360x360"


def main():
    params = urlencode({"exerciseId": EXERCISE_ID, "resolution": RESOLUTION})

    conn = http.client.HTTPSConnection(API_HOST)
    headers = {
        "x-rapidapi-key": API_KEY,
        "x-rapidapi-host": API_HOST,
    }

    conn.request("GET", f"/image?{params}", headers=headers)

    res = conn.getresponse()
    data = res.read().decode("utf-8", errors="replace")

    try:
        parsed = json.loads(data)
    except json.JSONDecodeError:
        parsed = data

    if isinstance(parsed, dict):
        print(json.dumps(parsed, ensure_ascii=False, indent=2))
    else:
        print(parsed)


if __name__ == "__main__":
    main()
