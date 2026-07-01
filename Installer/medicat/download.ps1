$tempFolder = "$PSScriptRoot\temp"
$htmFile = Get-ChildItem $tempFolder -Filter *.htm | Select-Object -First 1
if (-not $htmFile) {
    Write-Host "Not file .htm found exiting..."
    exit
}
$sizeFile = "$tempFolder\size.txt"
$totalSize = [int64](Get-Content $sizeFile)
Start-Process "msedge.exe" -ArgumentList $htmFile.FullName -WindowStyle Minimized
$downloadFolder = "$env:USERPROFILE\Downloads"

while ($true) {
    $tempFile = Get-ChildItem $downloadFolder -Filter *.crdownload | Select-Object -First 1
    if ($tempFile) { break }
    Start-Sleep -Milliseconds 500
}
$lastSize = 0

while (Test-Path $tempFile.FullName) {

    $size = (Get-Item $tempFile.FullName).Length

    if ($size -ne $lastSize) {
        $percent = [math]::Round(($size / $totalSize) * 100)
        Write-Progress -Activity "Downloading Medicat v2" -Status "$percent%" -PercentComplete $percent
        $lastSize = $size
    }

    Start-Sleep -Milliseconds 500
}
Write-Host "Cleaning up !"
Stop-Process -Name "msedge" -Force