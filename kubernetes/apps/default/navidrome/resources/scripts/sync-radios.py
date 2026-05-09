#!/usr/bin/env python3
"""Sync internet radio stations defined in radios.yaml with Navidrome.

Append-only: stations already present in Navidrome (matched by name) are
left untouched. New entries get a createInternetRadioStation call.
Stations present in Navidrome but missing from the YAML are NOT deleted.

Environment:
    ND_INITIALADMINPASSWORD  — admin password (mounted from `navidrome` Secret)

Optional environment overrides:
    NAVIDROME_BASE   default: http://navidrome.default.svc.cluster.local:8080/rest
    NAVIDROME_USER   default: admin
    RADIOS_FILE      default: /etc/radios/radios.yaml
"""

from __future__ import annotations

import hashlib
import os
import secrets
import sys
from pathlib import Path

import requests
import yaml

NAVIDROME_BASE = os.environ.get(
    "NAVIDROME_BASE", "http://navidrome.default.svc.cluster.local:8080/rest"
)
NAVIDROME_USER = os.environ.get("NAVIDROME_USER", "admin")
NAVIDROME_PASS = os.environ["ND_INITIALADMINPASSWORD"]
RADIOS_FILE = Path(os.environ.get("RADIOS_FILE", "/etc/radios/radios.yaml"))
CLIENT_ID = "navidrome-sync-radios"


def auth_params() -> dict[str, str]:
    """Build Subsonic authentication query params (token + salt)."""
    salt = secrets.token_hex(16)
    token = hashlib.md5((NAVIDROME_PASS + salt).encode()).hexdigest()
    return {
        "u": NAVIDROME_USER,
        "t": token,
        "s": salt,
        "v": "1.16.1",
        "c": CLIENT_ID,
        "f": "json",
    }


def call(endpoint: str, **extra: str) -> dict:
    """GET a Subsonic endpoint and return the parsed JSON response."""
    params = {**auth_params(), **extra}
    response = requests.get(f"{NAVIDROME_BASE}/{endpoint}", params=params, timeout=10)
    response.raise_for_status()
    return response.json()


def existing_radio_names() -> set[str]:
    """Names of Internet Radios already registered in Navidrome."""
    resp = call("getInternetRadioStations")
    stations = (
        resp.get("subsonic-response", {})
        .get("internetRadioStations", {})
        .get("internetRadioStation", [])
    )
    return {s["name"] for s in stations}


def main() -> int:
    radios = yaml.safe_load(RADIOS_FILE.read_text())
    if not isinstance(radios, list):
        print(f"error: {RADIOS_FILE} must contain a YAML list", file=sys.stderr)
        return 2

    existing = existing_radio_names()
    print(f"[info] {len(existing)} radios already in Navidrome")
    print(f"[info] {len(radios)} radios defined in {RADIOS_FILE}")

    failed = 0
    for radio in radios:
        name = radio["name"]
        if name in existing:
            print(f"[skip] {name}")
            continue
        try:
            call(
                "createInternetRadioStation",
                name=name,
                streamUrl=radio["url"],
                homepageUrl=radio.get("homepage", ""),
            )
            print(f"[add ] {name} -> {radio['url']}")
        except requests.RequestException as exc:
            print(f"[fail] {name}: {exc}", file=sys.stderr)
            failed += 1

    print(f"[done] failed={failed}")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
