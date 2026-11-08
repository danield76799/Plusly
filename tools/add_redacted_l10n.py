#!/usr/bin/env python3
"""Voegt de sleutels voor verwijderde berichten toe aan Plusly's arb-bestanden.

Gebruik: python3 tools/add_redacted_l10n.py
"""
import json
from collections import OrderedDict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

NIEUW = {
    "redactedTapToShow": ("tik om te tonen", "tap to show"),
    "redactedTapToHide": ("Tik om te verbergen 🗑️", "Tap to hide 🗑️"),
    "redactedOriginalContent": (
        "Originele inhoud (tik om te verbergen):",
        "Original content (tap to hide):",
    ),
    "redactedContentUnavailable": (
        "De originele inhoud is niet meer beschikbaar.",
        "The original content is no longer available.",
    ),
}

TAAL = {"intl_nl.arb": 0, "intl_en.arb": 1}


def voeg_toe(pad: Path, index: int) -> None:
    data = json.loads(pad.read_text(encoding="utf-8"), object_pairs_hook=OrderedDict)
    for key, waarden in NIEUW.items():
        if key not in data:
            data[key] = waarden[index]
    pad.write_text(
        json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    print(f"{pad.name}: {len(data)} sleutels")


if __name__ == "__main__":
    for naam, index in TAAL.items():
        voeg_toe(ROOT / "assets" / "l10n" / naam, index)
