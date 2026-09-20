#!/usr/bin/env python3
import json

# Nieuwe strings (EN + NL)
new_strings = {
    "en": {
        "pushRegistering": "Setting up push notifications...",
        "pushRegistered": "Push notifications are active ✅",
        "pushRegisterFailed": "Push setup failed. Retry?"
    },
    "nl": {
        "pushRegistering": "Pushmeldingen instellen...",
        "pushRegistered": "Pushmeldingen zijn actief ✅",
        "pushRegisterFailed": "Push instellen mislukt. Opnieuw proberen?"
    }
}

for lang in ["en", "nl"]:
    filepath = f"assets/l10n/intl_{lang}.arb"
    with open(filepath, "r") as f:
        data = json.load(f)
    
    # Voeg nieuwe strings toe
    for key, value in new_strings[lang].items():
        if key not in data:
            data[key] = value
            data[f"@{key}"] = {
                "description": f"String for {key}"
            }
    
    # Schrijf terug met correcte JSON
    with open(filepath, "w") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
        f.write("\n")

print("✅ ARB-bestanden succesvol bijgewerkt")