# Plusly Signing Key Setup voor Windows
# Dit script genereert een signing key en toont instructies voor GitHub secrets

Write-Host "Plusly Signing Key Setup" -ForegroundColor Green
Write-Host "========================" -ForegroundColor Green
Write-Host ""

# Check of keytool beschikbaar is (onderdeel van Java)
try {
    $keytool = Get-Command keytool -ErrorAction Stop
    Write-Host "✓ keytool gevonden" -ForegroundColor Green
} catch {
    Write-Host "✗ keytool niet gevonden. Installeer Java JDK:" -ForegroundColor Red
    Write-Host "  Download van: https://adoptium.net/" -ForegroundColor Yellow
    Write-Host "  Of via winget: winget install EclipseAdoptium.Temurin.17.JDK" -ForegroundColor Yellow
    exit 1
}

# Vraag om repository
$repo = Read-Host "GitHub repository (bijv. danield76799/Plusly)"
if ([string]::IsNullOrWhiteSpace($repo)) {
    Write-Host "Error: Repository naam is verplicht" -ForegroundColor Red
    exit 1
}

# Vraag om wachtwoord
$password = Read-Host "Keystore wachtwoord (minimaal 6 karakters)" -AsSecureString
$passwordPlain = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))

if ($passwordPlain.Length -lt 6) {
    Write-Host "Error: Wachtwoord moet minimaal 6 karakters zijn" -ForegroundColor Red
    exit 1
}

# Vraag om key alias
$alias = Read-Host "Key alias (standaard: plusly)"
if ([string]::IsNullOrWhiteSpace($alias)) {
    $alias = "plusly"
}

# Genereer keystore
Write-Host ""
Write-Host "Keystore genereren..." -ForegroundColor Green

$keystoreFile = "plusly-release.keystore"
$keystoreB64 = "plusly-release.b64"

# Verwijder oude files als ze bestaan
if (Test-Path $keystoreFile) { Remove-Item $keystoreFile }
if (Test-Path $keystoreB64) { Remove-Item $keystoreB64 }

# Genereer keystore
& keytool -genkey -v -keystore $keystoreFile -alias $alias -keyalg RSA -keysize 2048 -validity 10000 -storepass $passwordPlain -keypass $passwordPlain -dname "CN=Plusly, OU=Development, O=Plusly, L=Unknown, ST=Unknown, C=NL"

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Keystore genereren mislukt" -ForegroundColor Red
    exit 1
}

Write-Host "✓ Keystore gegenereerd: $keystoreFile" -ForegroundColor Green

# Base64 encode
$bytes = [System.IO.File]::ReadAllBytes($keystoreFile)
$b64 = [Convert]::ToBase64String($bytes)
$b64 | Out-File -Encoding ASCII $keystoreB64

Write-Host "✓ Base64 encoding gemaakt: $keystoreB64" -ForegroundColor Green

# Toon instructies voor GitHub secrets
Write-Host ""
Write-Host "✅ Setup voltooid!" -ForegroundColor Green
Write-Host ""
Write-Host "⚠️  BELANGRIJK - Bewaar deze files veilig:" -ForegroundColor Yellow
Write-Host "  - $keystoreFile (je signing key)"
Write-Host "  - $keystoreB64 (base64 versie)"
Write-Host ""
Write-Host "Deze files staan in de huidige directory."
Write-Host ""
Write-Host "Voeg deze secrets toe aan GitHub:" -ForegroundColor Cyan
Write-Host "  1. Ga naar: https://github.com/$repo/settings/secrets/actions"
Write-Host "  2. Klik 'New repository secret'"
Write-Host ""
Write-Host "  Secret naam: KEYSTORE_BASE64"
Write-Host "  Secret waarde: (kopieer de inhoud van $keystoreB64)"
Write-Host ""
Write-Host "  Secret naam: KEYSTORE_PASSWORD"
Write-Host "  Secret waarde: $passwordPlain"
Write-Host ""
Write-Host "  Secret naam: KEY_ALIAS"
Write-Host "  Secret waarde: $alias"
Write-Host ""
Write-Host "  Secret naam: KEY_PASSWORD"
Write-Host "  Secret waarde: $passwordPlain"
Write-Host ""
Write-Host "Als je de keystore verliest, kun je NOOIT meer updates uitbrengen voor je app!" -ForegroundColor Red
Write-Host ""
Write-Host "Druk op Enter om af te sluiten..."
Read-Host