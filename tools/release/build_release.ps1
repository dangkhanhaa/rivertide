# Builds the store release of "Con Nuoc" (P2-60): the Android App Bundle for
# Google Play and the APK for direct download.
#
#   powershell -ExecutionPolicy Bypass -File tools\release\build_release.ps1
#   powershell -ExecutionPolicy Bypass -File tools\release\build_release.ps1 -Only aab
#   powershell -ExecutionPolicy Bypass -File tools\release\build_release.ps1 -AllowDebugKey   # local test only
#
# BEFORE EVERY UPLOAD bump the version (Google Play refuses a versionCode it
# has already seen):
#   app\pubspec.yaml          version: 0.1.0+1  ->  0.1.1+2   (name + build number)
#   app\lib\core\config\env.dart   Env.version = '0.1.1'      (shown in the app)
# The number after "+" is the versionCode: it must only ever go UP, by at
# least 1 per upload, on every track (internal, closed, production).
# Windows PowerShell 5.1 compatible.

param(
    [ValidateSet('both', 'aab', 'apk')]
    [string]$Only = 'both',
    [string]$JdkHome = 'D:\dev\jdk-21.0.13+9',
    [string]$Flutter = 'C:\dev\flutter\bin\flutter.bat',
    [switch]$AllowDebugKey
)

$ErrorActionPreference = 'Stop'
$repo = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$app = Join-Path $repo 'app'
$keytool = Join-Path $JdkHome 'bin\keytool.exe'

# 1. Signing key present? Without it Gradle falls back to the debug key,
#    which Google Play rejects.
$hasKey = Test-Path (Join-Path $app 'android\key.properties')
if (-not $hasKey -and -not $AllowDebugKey) {
    throw 'app\android\key.properties missing: run tools\release\make_upload_key.ps1 first (or -AllowDebugKey for a local test build).'
}

# 2. Version: pubspec and Env.version must agree.
$pubVersion = (Select-String -Path (Join-Path $app 'pubspec.yaml') -Pattern '^version:\s*(\S+)').Matches[0].Groups[1].Value
$envVersion = (Select-String -Path (Join-Path $app 'lib\core\config\env.dart') -Pattern "String version = '([^']+)'").Matches[0].Groups[1].Value
$name, $code = $pubVersion -split '\+'
Write-Host "Version: $name (versionCode $code); in-app Env.version: $envVersion"
if ($name -ne $envVersion) {
    throw "pubspec version name '$name' != Env.version '$envVersion' (app\lib\core\config\env.dart)."
}
if (-not $code) { throw 'pubspec version needs a build number: version: x.y.z+N' }

$env:JAVA_HOME = $JdkHome
Push-Location $app
try {
    $define = '--dart-define-from-file=env/community.json'
    if ($Only -ne 'apk') {
        & $Flutter build appbundle --release $define
        if ($LASTEXITCODE -ne 0) { throw "flutter build appbundle failed ($LASTEXITCODE)" }
    }
    if ($Only -ne 'aab') {
        & $Flutter build apk --release $define
        if ($LASTEXITCODE -ne 0) { throw "flutter build apk failed ($LASTEXITCODE)" }
    }
} finally {
    Pop-Location
}

# 3. Show what was built and who signed it (must NOT say "CN=Android Debug").
#    The .aab carries a JAR signature keytool can read; the .apk (minSdk 24)
#    has only v2/v3 signatures: check it with the Android SDK's
#    `apksigner verify --print-certs app-release.apk` if needed.
$outputs = @(
    (Join-Path $repo 'build\app\outputs\bundle\release\app-release.aab'),
    (Join-Path $repo 'build\app\outputs\flutter-apk\app-release.apk'),
    (Join-Path $app 'build\app\outputs\bundle\release\app-release.aab'),
    (Join-Path $app 'build\app\outputs\flutter-apk\app-release.apk')
) | Where-Object { Test-Path $_ }
foreach ($f in $outputs) {
    $item = Get-Item $f
    $hash = (Get-FileHash $f -Algorithm SHA256).Hash
    Write-Host ''
    Write-Host ("{0}  {1:N1} MB  {2:yyyy-MM-dd HH:mm}" -f $item.FullName, ($item.Length / 1MB), $item.LastWriteTime)
    Write-Host "  SHA-256 file: $hash"
    if (Test-Path $keytool) {
        & $keytool -printcert -jarfile $f | Select-String -Pattern 'Owner:|SHA256:' | Select-Object -First 2
    }
}
Write-Host ''
if (-not $hasKey) {
    Write-Warning 'Signed with the DEBUG key: for local testing only, do not upload.'
}
Write-Host 'Upload the .aab in Play Console (docs/release/google-play.md). Keep the .apk for the web download.'
