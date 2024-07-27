$menu = 'Open in PowerShell Admin'
$registryPaths = @(
    'Registry::HKEY_CLASSES_ROOT\directory\shell\runas',
    'Registry::HKEY_CLASSES_ROOT\directory\background\shell\runas',
    'Registry::HKEY_CLASSES_ROOT\drive\shell\runas'
)

foreach ($path in $registryPaths) {
    if (Test-Path $path) {
        Remove-Item -Path $path -Recurse -Force
        Write-Output "Removed: $path"
    } else {
        Write-Output "Path not found: $path"
    }
}
