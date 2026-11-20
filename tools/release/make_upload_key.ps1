# Creates the Google Play UPLOAD key for "Con Nuoc" (P2-60) - run ONCE, by the owner.
#
#   powershell -ExecutionPolicy Bypass -File tools\release\make_upload_key.ps1
#   powershell -ExecutionPolicy Bypass -File tools\release\make_upload_key.ps1 -KeyStore E:\keys\con-nuoc-upload.jks
#
# What it does:
#   1. makes a PKCS12 keystore (RSA 4096, alias "upload", valid ~27 years)
#      OUTSIDE the repository (default D:\dev\keys\con-nuoc-upload.jks);
#   2. generates a strong random password (never printed to the console,
#      never passed on a command line: keytool reads it from an env variable);
#   3. writes app\android\key.properties (git-ignored) so Gradle signs
#      release builds with it;
#   4. prints the certificate fingerprints and what to back up.
# It refuses to overwrite an existing keystore or key.properties.
# Windows PowerShell 5.1 compatible.

param(
    [string]$KeyStore = 'D:\dev\keys\con-nuoc-upload.jks',
    [string]$JdkHome = 'D:\dev\jdk-21.0.13+9',
    [string]$Alias = 'upload',
    [string]$DName = 'CN=Con Nuoc, OU=RiverTide, C=VN'
)

$ErrorActionPreference = 'Stop'
$repo = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$keyProps = Join-Path $repo 'app\android\key.properties'
$keytool = Join-Path $JdkHome 'bin\keytool.exe'

if (-not (Test-Path $keytool)) { throw "keytool not found: $keytool (pass -JdkHome)" }
if (Test-Path $KeyStore) { throw "Keystore already exists: $KeyStore - not overwritten." }
if (Test-Path $keyProps) { throw "key.properties already exists: $keyProps - not overwritten." }
$full = [System.IO.Path]::GetFullPath($KeyStore)
if ($full.StartsWith([string]$repo, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "The keystore must live OUTSIDE the repository ($repo)."
}

# 32 random bytes -> letters and digits only (safe in .properties files).
$bytes = New-Object byte[] 32
$rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
$rng.GetBytes($bytes)
$rng.Dispose()
$password = ([Convert]::ToBase64String($bytes) -replace '[^A-Za-z0-9]', '')
if ($password.Length -lt 32) { throw 'Password generation failed, run again.' }

New-Item -ItemType Directory -Force -Path (Split-Path $full) | Out-Null
$env:CON_NUOC_KS_PASS = $password
try {
    & $keytool -genkeypair -v -keystore $full -storetype PKCS12 `
        -alias $Alias -keyalg RSA -keysize 4096 -validity 10000 `
        -dname $DName -storepass:env CON_NUOC_KS_PASS -keypass:env CON_NUOC_KS_PASS
    if ($LASTEXITCODE -ne 0) { throw "keytool failed ($LASTEXITCODE)" }

    # Forward slashes: a backslash is an escape character in .properties files.
    # (No "+" inside the array below: in PowerShell "," binds tighter than "+".)
    $storePath = $full -replace '\\', '/'
    $today = Get-Date -Format 'yyyy-MM-dd'
    $content = @(
        '# Upload key for Google Play (P2-60). NEVER commit this file (git-ignored).',
        "# Made by tools/release/make_upload_key.ps1 on $today",
        "storeFile=$storePath",
        "storePassword=$password",
        "keyAlias=$Alias",
        "keyPassword=$password"
    )
    # ASCII, no BOM: Gradle reads .properties as ISO-8859-1.
    [System.IO.File]::WriteAllLines($keyProps, $content, (New-Object System.Text.ASCIIEncoding))

    Write-Host ''
    Write-Host '=== Certificate (give the SHA-256 to nobody but Google Play / API consoles) ==='
    & $keytool -list -v -keystore $full -alias $Alias -storepass:env CON_NUOC_KS_PASS |
        Select-String -Pattern 'Owner:|SHA1:|SHA256:|Valid'
} finally {
    Remove-Item Env:\CON_NUOC_KS_PASS -ErrorAction SilentlyContinue
}

Write-Host ''
Write-Host '=== DONE. Back these up NOW (losing them = cannot update the app easily) ==='
Write-Host "  1. The keystore file : $full"
Write-Host "  2. The password      : inside $keyProps (storePassword=...)"
Write-Host '  Keep 2 copies in 2 places: a password manager (file + password) AND an'
Write-Host '  offline USB drive kept at home. Never e-mail it, never put it in Git,'
Write-Host '  Google Drive shared folders or chat apps.'
Write-Host '  With Play App Signing (default for new apps) Google keeps the real app'
Write-Host '  signing key; if this UPLOAD key is lost or leaked, the account owner can'
Write-Host '  ask Google Play support to reset it - slow, so do not count on it.'
Write-Host ''
Write-Host 'Next: tools\release\build_release.ps1 (docs/release/google-play.md).'
