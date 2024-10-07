# Créer les dossiers pour les résultats
$resultsPath = ".\Results"
$csvPath = "$resultsPath\CSV"
$pdfPath = "$resultsPath\PDF"
$jsonPath = "$resultsPath\JSON"

# Créer les dossiers s'ils n'existent pas
if (-not (Test-Path $resultsPath)) {
    New-Item -ItemType Directory -Path $resultsPath | Out-Null
}
if (-not (Test-Path $csvPath)) {
    New-Item -ItemType Directory -Path $csvPath | Out-Null
}
if (-not (Test-Path $pdfPath)) {
    New-Item -ItemType Directory -Path $pdfPath | Out-Null
}
if (-not (Test-Path $jsonPath)) {
    New-Item -ItemType Directory -Path $jsonPath | Out-Null
}

# Fonction pour collecter les informations matérielles
function Get-HardwareInfo {
    $cpu = Get-CimInstance Win32_Processor | Select-Object Name, NumberOfCores, MaxClockSpeed
    $memory = Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum
    $disks = Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" | Select-Object DeviceID, Size, FreeSpace

    # Formater les résultats pour l'exportation
    $formattedMemory = [PSCustomObject]@{
        TotalCapacityGB = [math]::round($memory.Sum / 1GB, 2)  # Conversion en Go
    }

    return @{
        CPU    = $cpu
        Memory = $formattedMemory
        Disks  = $disks
    }
}

# Fonction pour collecter les informations logicielles
function Get-SoftwareInfo {
    # Utiliser Win32_Product
    $installedApps = Get-CimInstance Win32_Product | Select-Object Name, Version, Vendor

    # Utiliser les clés de registre pour une liste complète des logiciels installés
    $registryPath = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
    $installedAppsRegistry = Get-ItemProperty $registryPath | Select-Object DisplayName, DisplayVersion, Publisher

    # Combiner les résultats
    return $installedApps + $installedAppsRegistry | Where-Object { $_.DisplayName -ne $null }
}

# Fonction pour exporter les données en CSV
function Export-ToCSV {
    param (
        [array]$data,
        [string]$path
    )
    $data | Export-Csv -Path $path -NoTypeInformation -Encoding UTF8
}

# Fonction pour exporter les données en JSON
function Export-ToJSON {
    param (
        [array]$data,
        [string]$path
    )
    $data | ConvertTo-Json | Out-File -FilePath $path -Encoding UTF8
}

# Fonction pour exporter les données en PDF (simple version, nécessite une bibliothèque)
function Export-ToPDF {
    param (
        [array]$data,
        [string]$path
    )

    # Crée un document PDF simple. Assurez-vous d'avoir une bibliothèque pour cela (comme SelectPdf ou autre).
    # Exemple : Utilisation d'une bibliothèque tierce pour créer un PDF serait nécessaire ici.

    # Placeholder : Code pour exporter en PDF
    $pdfContent = "PDF Export Placeholder for Data: $($data | Out-String)"
    $pdfContent | Out-File -FilePath $path -Encoding UTF8
}

# Collecte des informations
$hardwareInfo = Get-HardwareInfo
$softwareInfo = Get-SoftwareInfo

# Exporter les résultats vers des fichiers
Export-ToCSV -data $hardwareInfo.CPU -path "$csvPath\InventaireCPU.csv"
Export-ToCSV -data @($hardwareInfo.Memory) -path "$csvPath\InventaireMemory.csv"
Export-ToCSV -data $hardwareInfo.Disks -path "$csvPath\InventaireDisks.csv"
Export-ToCSV -data $softwareInfo -path "$csvPath\InventaireSoftware.csv"

# Exporter en JSON
Export-ToJSON -data $hardwareInfo.CPU -path "$jsonPath\InventaireCPU.json"
Export-ToJSON -data @($hardwareInfo.Memory) -path "$jsonPath\InventaireMemory.json"
Export-ToJSON -data $hardwareInfo.Disks -path "$jsonPath\InventaireDisks.json"
Export-ToJSON -data $softwareInfo -path "$jsonPath\InventaireSoftware.json"

# Exporter en PDF (placeholder)
Export-ToPDF -data $hardwareInfo.CPU -path "$pdfPath\InventaireCPU.pdf"
Export-ToPDF -data @($hardwareInfo.Memory) -path "$pdfPath\InventaireMemory.pdf"
Export-ToPDF -data $hardwareInfo.Disks -path "$pdfPath\InventaireDisks.pdf"
Export-ToPDF -data $softwareInfo -path "$pdfPath\InventaireSoftware.pdf"

Write-Host "L'inventaire a été exporté avec succès dans le dossier Results."