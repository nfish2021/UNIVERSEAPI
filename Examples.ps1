# Example Usage Script for UniverseAPI PowerShell Module
# This script demonstrates various ways to use the UniverseAPI module

# Import the module (assumes it's in the same directory)
Import-Module .\UniverseAPI.psd1 -Force

Write-Host "=== UniverseAPI Module Demo ===" -ForegroundColor Green
Write-Host ""

# Example 1: Basic EarthMC Aurora API call
Write-Host "1. Getting EarthMC Aurora server data..." -ForegroundColor Yellow
try {
    $auroraData = Get-EarthMCAuroraData
    Write-Host "✓ Successfully retrieved Aurora data" -ForegroundColor Green
    Write-Host "Sample data structure:" -ForegroundColor Cyan
    if ($auroraData) {
        $auroraData | ConvertTo-Json -Depth 2 | Write-Host
    }
}
catch {
    Write-Host "✗ Failed to retrieve Aurora data: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "This is expected if there's no internet connection or the API is unavailable." -ForegroundColor Yellow
}

Write-Host ""

# Example 2: Using the generic server info function
Write-Host "2. Using generic server info function..." -ForegroundColor Yellow
try {
    $serverInfo = Get-MinecraftServerInfo -ServerName "EarthMC" -Endpoint "v3/aurora"
    Write-Host "✓ Successfully retrieved server info using generic function" -ForegroundColor Green
}
catch {
    Write-Host "✗ Failed to retrieve server info: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Example 3: Creating a custom API client for another server
Write-Host "3. Creating custom API client configuration..." -ForegroundColor Yellow
$customClient = New-MinecraftAPIClient -Name "MyCustomServer" -BaseUrl "https://api.mycustomserver.com" -Version "v2" -Headers @{
    "Authorization" = "Bearer your-token-here"
    "X-Custom-Header" = "custom-value"
} -Endpoints @{
    "players" = "players"
    "worlds" = "worlds"
    "stats" = "statistics"
}

Write-Host "✓ Custom API client created:" -ForegroundColor Green
$customClient | ConvertTo-Json -Depth 2 | Write-Host

Write-Host ""

# Example 4: Configuring module settings
Write-Host "4. Configuring module settings..." -ForegroundColor Yellow
Set-MinecraftAPIConfiguration -DefaultTimeout 60 -MaxRetryAttempts 5 -UserAgent "MyCustomApp/1.0"
Write-Host "✓ Module configuration updated" -ForegroundColor Green

Write-Host ""

# Example 5: Using the low-level API function
Write-Host "5. Using low-level API function..." -ForegroundColor Yellow
try {
    # This would work with any API endpoint
    $result = Invoke-MinecraftAPI -BaseUrl "https://api.earthmc.net" -Endpoint "v3/aurora" -Headers @{
        "Accept" = "application/json"
        "User-Agent" = "UniverseAPI-Demo/1.0"
    }
    Write-Host "✓ Low-level API call successful" -ForegroundColor Green
}
catch {
    Write-Host "✗ Low-level API call failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Example 6: Error handling demonstration
Write-Host "6. Demonstrating error handling..." -ForegroundColor Yellow
try {
    # This should fail gracefully
    $badResult = Get-MinecraftServerInfo -CustomBaseUrl "https://nonexistent.api.com" -Endpoint "test"
}
catch {
    Write-Host "✓ Error handled gracefully: $($_.Exception.Message)" -ForegroundColor Green
}

Write-Host ""
Write-Host "=== Demo Complete ===" -ForegroundColor Green
Write-Host ""
Write-Host "Available Functions:" -ForegroundColor Cyan
Write-Host "- Get-EarthMCAuroraData: Get data from EarthMC Aurora API" -ForegroundColor White
Write-Host "- Get-MinecraftServerInfo: Generic function for any Minecraft server API" -ForegroundColor White  
Write-Host "- Invoke-MinecraftAPI: Low-level HTTP API function" -ForegroundColor White
Write-Host "- New-MinecraftAPIClient: Create custom API client configurations" -ForegroundColor White
Write-Host "- Set-MinecraftAPIConfiguration: Configure module settings" -ForegroundColor White

Write-Host ""
Write-Host "For more information, use Get-Help <function-name> -Detailed" -ForegroundColor Yellow