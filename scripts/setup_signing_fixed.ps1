# Plusly Signing Key Setup for Windows
Write-Host "Plusly Signing Key Setup" -ForegroundColor Green
Write-Host "========================" -ForegroundColor Green
Write-Host ""

# Check if keytool is available
try {
    $keytool = Get-Command keytool -ErrorAction Stop
    Write-Host "OK keytool found" -ForegroundColor Green
} catch {
    Write-Host "ERROR keytool not found. Install Java JDK:" -ForegroundColor Red
    Write-Host "  Download from: https://adoptium.net/" -ForegroundColor Yellow
    exit 1
}

# Ask for repository
$repo = Read-Host "GitHub repository (e.g. danield76799/Plusly)"
if ([string]::IsNullOrWhiteSpace($repo)) {
    Write-Host "Error: Repository name is required" -ForegroundColor Red
    exit 1
}

# Ask for password
$password = Read-Host "Keystore password (minimum 6 characters)" -AsSecureString
$passwordPlain = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))

if ($passwordPlain.Length -lt 6) {
    Write-Host "Error: Password must be at least 6 characters" -ForegroundColor Red
    exit 1
}

# Ask for key alias
$alias = Read-Host "Key alias (default: plusly)"
if ([string]::IsNullOrWhiteSpace($alias)) {
    $alias = "plusly"
}

# Generate keystore
Write-Host ""
Write-Host "Generating keystore..." -ForegroundColor Green

$keystoreFile = "plusly-release.keystore"
$keystoreB64 = "plusly-release.b64"

# Remove old files if they exist
if (Test-Path $keystoreFile) { Remove-Item $keystoreFile }
if (Test-Path $keystoreB64) { Remove-Item $keystoreB64 }

# Generate keystore
$keytoolArgs = @(
    "-genkey",
    "-v",
    "-keystore", $keystoreFile,
    "-alias", $alias,
    "-keyalg", "RSA",
    "-keysize", "2048",
    "-validity", "10000",
    "-storepass", $passwordPlain,
    "-keypass", $passwordPlain,
    "-dname", "CN=Plusly, OU=Development, O=Plusly, L=Unknown, ST=Unknown, C=NL"
)

& keytool $keytoolArgs

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Keystore generation failed" -ForegroundColor Red
    exit 1
}

Write-Host "OK Keystore generated: $keystoreFile" -ForegroundColor Green

# Base64 encode
$bytes = [System.IO.File]::ReadAllBytes($keystoreFile)
$b64 = [Convert]::ToBase64String($bytes)
$b64 | Out-File -Encoding ASCII $keystoreB64

Write-Host "OK Base64 encoding created: $keystoreB64" -ForegroundColor Green

# Show instructions for GitHub secrets
Write-Host ""
Write-Host "Setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "IMPORTANT - Keep these files safe:" -ForegroundColor Yellow
Write-Host "  - $keystoreFile (your signing key)"
Write-Host "  - $keystoreB64 (base64 version)"
Write-Host ""
Write-Host "These files are in the current directory."
Write-Host ""
Write-Host "Add these secrets to GitHub:" -ForegroundColor Cyan
Write-Host "  1. Go to: https://github.com/$repo/settings/secrets/actions"
Write-Host "  2. Click 'New repository secret'"
Write-Host ""
Write-Host "  Secret name: KEYSTORE_BASE64"
Write-Host "  Secret value: (copy contents of $keystoreB64)"
Write-Host ""
Write-Host "  Secret name: KEYSTORE_PASSWORD"
Write-Host "  Secret value: $passwordPlain"
Write-Host ""
Write-Host "  Secret name: KEY_ALIAS"
Write-Host "  Secret value: $alias"
Write-Host ""
Write-Host "  Secret name: KEY_PASSWORD"
Write-Host "  Secret value: $passwordPlain"
Write-Host ""
Write-Host "WARNING: If you lose the keystore, you can NEVER release updates for your app!" -ForegroundColor Red
Write-Host ""
Write-Host "Press Enter to exit..."
Read-Host
