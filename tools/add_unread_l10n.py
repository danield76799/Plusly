#!/usr/bin/env python3
"""Voegt de sleutel voor de ongelezen-scheiding toe aan Plusly's arb-bestanden.

Gebruik: python3 tools/add_unread_l10n.py
"""
import json
from collections import OrderedDict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

# (NL, EN) — ICU-plural, net als de bestaande nEdits/nViews-sleutels.
NIEUW = {
    "unreadMessages": (
        "{count, plural, =1{1 ongelezen bericht} other{{count} ongelezen berichten}}",
        "{count, plural, =1{1 unread message} other{{count} unread messages}}",
    ),
}
META = {
    "type": "text",
    "placeholders": {
        "count": {
            "type": "int",
            "example": "3",
        }
    },
}

TAAL = {"intl_nl.arb": 0, "intl_en.arb": 1}


def voeg_toe(pad: Path, index: int) -> None:
    data = json.loads(pad.read_text(encoding="utf-8"), object_pairs_hook=OrderedDict)
    nieuw = OrderedDict()
    for key, waarde in data.items():
        nieuw[key] = waarde
        # Plaats de @-metadata direct na de sleutel, zoals de rest van het
        # bestand dat doet.
        if key in NIEUW and f"@{key}" not in data:
            nieuw[f"@{key}"] = META
    for key, waarden in NIEUW.items():
        if key not in data:
            nieuw[key] = waarden[index]
            nieuw[f"@{key}"] = META
    pad.write_text(
        json.dumps(nieuw, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    print(f"{pad.name}: {len(nieuw)} sleutels")


if __name__ == "__main__":
    for naam, index in TAAL.items():
        voeg_toe(ROOT / "assets" / "l10n" / naam, index)
