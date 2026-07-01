param(
    [string]$Url
)

if (-not $Url) {
    Write-Host "Not link !"
    exit
}

$Destination = Join-Path $PSScriptRoot "bin.zip"

# Création du client Web
$wc = New-Object System.Net.WebClient

# Récupération de la taille du fichier (si possible)
try {
    $req = [System.Net.WebRequest]::Create($Url)
    $req.Method = "HEAD"
    $resp = $req.GetResponse()
    $size = $resp.Headers["Content-Length"]
    $resp.Close()
} catch {
    $size = $null
}

# Téléchargement manuel
$stream = $wc.OpenRead($Url)
$file = [System.IO.File]::Create($Destination)

$buffer = New-Object byte[] 4096
$total = 0

while (($read = $stream.Read($buffer, 0, $buffer.Length)) -gt 0) {
    $file.Write($buffer, 0, $read)
    $total += $read

    if ($size) {
        $percent = [math]::Round(($total / $size) * 100)

        Write-Progress -Activity "Downloading file of servers..." `
                       -Status "$percent %" `
                       -PercentComplete $percent
    }
}

$stream.Close()
$file.Close()

Write-Progress -Activity "Downloading..." -Completed
Write-Host "Cleanup"