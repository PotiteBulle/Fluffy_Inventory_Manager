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
    return Get-CimInstance Win32_Product | Select-Object Name, Version, Vendor
}

# Fonction pour exporter les données en CSV
function Export-ToCSV {
    param (
        [array]$data,
        [string]$path
    )
    $data | Export-Csv -Path $path -NoTypeInformation -Encoding UTF8
}

# Collecte des informations
$hardwareInfo = Get-HardwareInfo
$softwareInfo = Get-SoftwareInfo

# Exporter les résultats vers des fichiers CSV
Export-ToCSV -data $hardwareInfo.CPU -path "InventaireCPU.csv"
Export-ToCSV -data @($hardwareInfo.Memory) -path "InventaireMemory.csv"  # Notez le format tableau
Export-ToCSV -data $hardwareInfo.Disks -path "InventaireDisks.csv"
Export-ToCSV -data $softwareInfo -path "InventaireSoftware.csv"

Write-Host "L'inventaire a été exporté avec succès."
