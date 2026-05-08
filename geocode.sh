#!/usr/bin/env bash
# Geocode places.csv → places.json using OpenStreetMap Nominatim
# Reads each row, queries Nominatim, attaches lat/lon, writes JSON.
# Caches results in .geocode-cache.json so re-runs only fetch new entries.

set -euo pipefail
cd "$(dirname "$0")"

CSV="places.csv"
OUT="places.json"
CACHE=".geocode-cache.json"
[ -f "$CACHE" ] || echo '{}' > "$CACHE"

UA="la-trip-2026/1.0 (personal travel map)"

# Read CSV with python (proper quoting handling), geocode, emit JSON
python3 - <<'PY'
import csv, json, os, time, urllib.parse, urllib.request, sys

CACHE_FILE = ".geocode-cache.json"
with open(CACHE_FILE) as f:
    cache = json.load(f)

UA = "la-trip-2026/1.0 (personal travel map)"

def geocode(query):
    if query in cache:
        return cache[query]
    url = "https://nominatim.openstreetmap.org/search?" + urllib.parse.urlencode({
        "q": query, "format": "json", "limit": 1
    })
    req = urllib.request.Request(url, headers={"User-Agent": UA})
    try:
        with urllib.request.urlopen(req, timeout=15) as r:
            data = json.load(r)
    except Exception as e:
        print(f"  ERROR: {query}: {e}", file=sys.stderr)
        data = []
    if data:
        result = {"lat": float(data[0]["lat"]), "lon": float(data[0]["lon"]), "display": data[0].get("display_name","")}
    else:
        result = None
    cache[query] = result
    with open(CACHE_FILE, "w") as f:
        json.dump(cache, f, ensure_ascii=False, indent=2)
    time.sleep(1.1)  # Nominatim rate limit
    return result

places = []
missing = []
with open("places.csv", newline="") as f:
    reader = csv.DictReader(f)
    for i, row in enumerate(reader, 1):
        query = row["query"].strip()
        print(f"[{i}] {row['name']} -> {query}", file=sys.stderr)
        result = geocode(query)
        if result:
            row["lat"] = result["lat"]
            row["lon"] = result["lon"]
        else:
            missing.append(row["name"])
            row["lat"] = None
            row["lon"] = None
        # Convert rating to float if present
        try:
            row["rating"] = float(row["rating"]) if row.get("rating","").strip() else None
        except ValueError:
            row["rating"] = None
        places.append(row)

trip = {
    "title": "LA & Las Vegas 2026",
    "dates": "2026-05-08 ~ 2026-05-17",
    "wife": "bokyung Lee",
    "places": places,
}

with open("places.json", "w") as f:
    json.dump(trip, f, ensure_ascii=False, indent=2)

print(f"\nWrote places.json with {len(places)} places", file=sys.stderr)
if missing:
    print(f"\nCouldn't geocode {len(missing)}:", file=sys.stderr)
    for m in missing:
        print(f"  - {m}", file=sys.stderr)
PY
