#!/usr/bin/env python3
"""Voegt de WhatsApp-groene-bubbel-teksten toe aan Plusly's arb-bestanden."""
import json
from collections import OrderedDict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

NIEUW = {
    "whatsAppGreenBubble": ("WhatsApp-groene bubbel", "WhatsApp green bubble"),
    "whatsAppGreenBubbleDescription": (
        "Gebruik WhatsApp-groen voor je eigen berichten",
        "Use WhatsApp green for your own messages",
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
