"""Validate data/diseases.json against the design doc (Appendix A).

Exit code 0 means the data is valid. Exit code 1 prints each problem found.
"""

import json
import sys
from pathlib import Path

DATA_PATH = Path("data/diseases.json")
EXPECTED_COUNT = 30
MULTI_ORIGIN_IDS = {11, 18, 21, 24}
REQUIRED_TEXT_FIELDS = ("name", "place", "year", "fact")


def validate(diseases: list) -> list[str]:
    problems = []

    if len(diseases) != EXPECTED_COUNT:
        problems.append(f"expected {EXPECTED_COUNT} diseases, found {len(diseases)}")

    ids = [d.get("id") for d in diseases]
    if ids != list(range(1, len(diseases) + 1)):
        problems.append("ids must run 1..N in order with no gaps or duplicates")

    for disease in diseases:
        label = f"#{disease.get('id')} {disease.get('name')}"

        for field in REQUIRED_TEXT_FIELDS:
            value = disease.get(field)
            if not isinstance(value, str) or not value.strip():
                problems.append(f"{label}: '{field}' must be a non-empty string")

        locations = disease.get("locations")
        if not isinstance(locations, list) or not locations:
            problems.append(f"{label}: 'locations' must be a non-empty list")
            continue

        expected = 2 if disease.get("id") in MULTI_ORIGIN_IDS else 1
        if len(locations) != expected:
            problems.append(f"{label}: expected {expected} location(s), found {len(locations)}")

        for loc in locations:
            lat, lon = loc.get("lat"), loc.get("lon")
            if not isinstance(lat, (int, float)) or not -90 <= lat <= 90:
                problems.append(f"{label}: latitude {lat!r} is not a number from -90 to 90")
            if not isinstance(lon, (int, float)) or not -180 <= lon <= 180:
                problems.append(f"{label}: longitude {lon!r} is not a number from -180 to 180")

    return problems


def main() -> int:
    try:
        diseases = json.loads(DATA_PATH.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        print(f"Cannot read {DATA_PATH}: {error}")
        return 1

    problems = validate(diseases)
    for problem in problems:
        print(f"ERROR: {problem}")
    if problems:
        return 1

    print(f"OK: {len(diseases)} diseases validated.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
