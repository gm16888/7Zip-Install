# Step 1: Get the latest version from 7-Zip website
try {
    $html = Invoke-WebRequest "https://www.7-zip.org/download.html" -UseBasicParsing
    $html.Content -match 'Download 7-Zip ([\d\.]+)' | Out-Null
    $latest = $matches[1]
    Write-Host "Latest 7-Zip version: $latest"
} catch {
    Write-Host "Failed to retrieve latest version."
    exit 1
}

# Step 2: Uninstall existing version using Uninstall.exe
$sevenZipFolder = "C:\Program Files\7-Zip"
$uninstaller = Join-Path $sevenZipFolder "Uninstall.exe"

if (Test-Path $uninstaller) {
    Write-Host "Uninstalling existing 7-Zip using native uninstaller..."
    Start-Process $uninstaller -ArgumentList "/S" -Wait
    Start-Sleep -Seconds 3
} else {
    Write-Host "No existing 7-Zip uninstaller found. Skipping uninstall."
}

# Step 3: Remove leftover folder if it still exists
if (Test-Path $sevenZipFolder) {
    Write-Host "Removing leftover 7-Zip folder..."
    Remove-Item -Path $sevenZipFolder -Recurse -Force -ErrorAction SilentlyContinue
}

# Step 4: Build download URL and download MSI
$msiFile = "7z$($latest.Replace('.', ''))-x64.msi"
$downloadUrl = "https://www.7-zip.org/a/$msiFile"
$installerPath = "$env:TEMP\$msiFile"

try {
    Write-Host "Downloading $msiFile from $downloadUrl..."
    Invoke-WebRequest -Uri $downloadUrl -OutFile $installerPath -UseBasicParsing
} catch {
    Write-Host "Download failed: $($_.Exception.Message)"
    exit 1
}

# Step 5: Install latest version silently
Write-Host "Installing 7-Zip $latest..."
Start-Process "msiexec.exe" -ArgumentList "/i `"$installerPath`" /qn /norestart" -Wait

# Step 6: Clean up
Remove-Item $installerPath -Force -ErrorAction SilentlyContinue
Write-Host "7-Zip $latest installed successfully."

