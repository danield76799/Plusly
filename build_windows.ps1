# Build script for Plusly Windows
$env:OPENSSL_ROOT_DIR = "C:\Program Files\OpenSSL-Win64"
$env:PATH = "$env:OPENSSL_ROOT_DIR\bin;C:\Program Files\NASM;$env:PATH"

Write-Host "OPENSSL_ROOT_DIR set to: $env:OPENSSL_ROOT_DIR"
Write-Host "NASM path added"

# Verify tools
openssl version
nasm -v

# Build the Windows app
flutter build windows --release
