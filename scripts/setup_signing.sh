#!/bin/bash

# Plusly Signing Key Setup Script
# Dit script genereert een signing key en voegt deze toe aan GitHub secrets

set -e

# Kleuren voor output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Plusly Signing Key Setup${NC}"
echo "=========================="
echo ""

# Check of benodigde tools beschikbaar zijn
if ! command -v keytool &> /dev/null; then
    echo -e "${RED}Error: keytool niet gevonden. Installeer Java JDK.${NC}"
    echo "Ubuntu/Debian: sudo apt install default-jdk"
    echo "Mac: brew install openjdk"
    exit 1
fi

if ! command -v gh &> /dev/null; then
    echo -e "${RED}Error: GitHub CLI (gh) niet gevonden. Installeer deze eerst.${NC}"
    echo "Ubuntu/Debian: sudo apt install gh"
    echo "Mac: brew install gh"
    echo "Daarna login: gh auth login"
    exit 1
fi

# Check of gebruiker is ingelogd bij GitHub
if ! gh auth status &> /dev/null; then
    echo -e "${RED}Error: Niet ingelogd bij GitHub CLI.${NC}"
    echo "Run eerst: gh auth login"
    exit 1
fi

# Vraag om repository
read -p "GitHub repository (bijv. danield76799/Plusly): " REPO

if [ -z "$REPO" ]; then
    echo -e "${RED}Error: Repository naam is verplicht${NC}"
    exit 1
fi

# Vraag om keystore wachtwoord
echo ""
echo -e "${YELLOW}Keystore wachtwoord (minimaal 6 karakters):${NC}"
read -s -p "Wachtwoord: " KEYSTORE_PASSWORD
echo ""

if [ ${#KEYSTORE_PASSWORD} -lt 6 ]; then
    echo -e "${RED}Error: Wachtwoord moet minimaal 6 karakters zijn${NC}"
    exit 1
fi

read -s -p "Herhaal wachtwoord: " KEYSTORE_PASSWORD_CONFIRM
echo ""

if [ "$KEYSTORE_PASSWORD" != "$KEYSTORE_PASSWORD_CONFIRM" ]; then
    echo -e "${RED}Error: Wachtwoorden komen niet overeen${NC}"
    exit 1
fi

# Vraag om key alias
read -p "Key alias (standaard: plusly): " KEY_ALIAS
KEY_ALIAS=${KEY_ALIAS:-plusly}

# Vraag om key wachtwoord (kan hetzelfde zijn als keystore)
read -p "Key wachtwoord hetzelfde als keystore? (j/n): " SAME_PASSWORD

if [[ $SAME_PASSWORD =~ ^[Jj]$ ]]; then
    KEY_PASSWORD=$KEYSTORE_PASSWORD
else
    echo -e "${YELLOW}Key wachtwoord:${NC}"
    read -s -p "Wachtwoord: " KEY_PASSWORD
    echo ""
fi

# Genereer keystore
echo ""
echo -e "${GREEN}Keystore genereren...${NC}"

KEYSTORE_FILE="plusly-release.keystore"
KEYSTORE_B64="plusly-release.b64"

# Verwijder oude files als ze bestaan
[ -f "$KEYSTORE_FILE" ] && rm "$KEYSTORE_FILE"
[ -f "$KEYSTORE_B64" ] && rm "$KEYSTORE_B64"

# Genereer keystore met keytool
keytool -genkey \
    -v \
    -keystore "$KEYSTORE_FILE" \
    -alias "$KEY_ALIAS" \
    -keyalg RSA \
    -keysize 2048 \
    -validity 10000 \
    -storepass "$KEYSTORE_PASSWORD" \
    -keypass "$KEY_PASSWORD" \
    -dname "CN=Plusly, OU=Development, O=Plusly, L=Unknown, ST=Unknown, C=NL"

echo -e "${GREEN}Keystore gegenereerd: $KEYSTORE_FILE${NC}"

# Base64 encode
if command -v base64 &> /dev/null; then
    # Linux/Mac
    base64 -i "$KEYSTORE_FILE" -o "$KEYSTORE_B64"
else
    # Windows PowerShell
    powershell -Command "[Convert]::ToBase64String([IO.File]::ReadAllBytes('$KEYSTORE_FILE')) | Out-File -Encoding ASCII '$KEYSTORE_B64'"
fi

echo -e "${GREEN}Base64 encoding gemaakt: $KEYSTORE_B64${NC}"

# Toevoegen aan GitHub secrets
echo ""
echo -e "${GREEN}Secrets toevoegen aan GitHub...${NC}"

# KEYSTORE_BASE64
echo -n "KEYSTORE_BASE64 toevoegen..."
gh secret set KEYSTORE_BASE64 \
    --repo "$REPO" \
    --body "$(cat "$KEYSTORE_B64")"
echo -e " ${GREEN}OK${NC}"

# KEYSTORE_PASSWORD
echo -n "KEYSTORE_PASSWORD toevoegen..."
gh secret set KEYSTORE_PASSWORD \
    --repo "$REPO" \
    --body "$KEYSTORE_PASSWORD"
echo -e " ${GREEN}OK${NC}"

# KEY_ALIAS
echo -n "KEY_ALIAS toevoegen..."
gh secret set KEY_ALIAS \
    --repo "$REPO" \
    --body "$KEY_ALIAS"
echo -e " ${GREEN}OK${NC}"

# KEY_PASSWORD
echo -n "KEY_PASSWORD toevoegen..."
gh secret set KEY_PASSWORD \
    --repo "$REPO" \
    --body "$KEY_PASSWORD"
echo -e " ${GREEN}OK${NC}"

# Backup instructies
echo ""
echo -e "${GREEN}✅ Setup voltooid!${NC}"
echo ""
echo -e "${YELLOW}⚠️  BELANGRIJK - Bewaar deze files veilig:${NC}"
echo "  - $KEYSTORE_FILE (je signing key)"
echo "  - $KEYSTORE_B64 (base64 versie)"
echo ""
echo "Deze files staan in de huidige directory."
echo "Bewaar ze op een veilige plek (bijv. password manager of encrypted storage)."
echo ""
echo "Als je de keystore verliest, kun je NOOIT meer updates uitbrengen voor je app!"
echo ""
echo -e "${GREEN}Je kunt nu de 'Build Release APK' workflow starten op GitHub Actions.${NC}"
