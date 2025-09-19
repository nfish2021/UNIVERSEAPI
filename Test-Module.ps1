# Basic test script for UniverseAPI PowerShell Module
# This script validates that the module loads correctly and functions are available

Write-Host "=== UniverseAPI Module Tests ===" -ForegroundColor Green

# Test 1: Module Import
Write-Host "`nTest 1: Module Import..." -ForegroundColor Yellow
try {
    Import-Module .\UniverseAPI.psd1 -Force
    Write-Host "✓ Module imported successfully" -ForegroundColor Green
}
catch {
    Write-Host "✗ Module import failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Test 2: Check exported functions
Write-Host "`nTest 2: Checking exported functions..." -ForegroundColor Yellow
$expectedFunctions = @(
    'Get-MinecraftServerInfo',
    'Get-EarthMCAuroraData',
    'Invoke-MinecraftAPI',
    'New-MinecraftAPIClient',
    'Set-MinecraftAPIConfiguration'
)

$availableFunctions = Get-Command -Module UniverseAPI
$functionNames = $availableFunctions.Name

foreach ($func in $expectedFunctions) {
    if ($func -in $functionNames) {
        Write-Host "✓ Function $func is available" -ForegroundColor Green
    }
    else {
        Write-Host "✗ Function $func is missing" -ForegroundColor Red
    }
}

# Test 3: Test help documentation
Write-Host "`nTest 3: Testing help documentation..." -ForegroundColor Yellow
try {
    $help = Get-Help Get-EarthMCAuroraData -ErrorAction Stop
    if ($help.Synopsis) {
        Write-Host "✓ Help documentation is available" -ForegroundColor Green
    }
    else {
        Write-Host "✗ Help documentation is incomplete" -ForegroundColor Red
    }
}
catch {
    Write-Host "✗ Help documentation test failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 4: Test configuration function
Write-Host "`nTest 4: Testing configuration..." -ForegroundColor Yellow
try {
    Set-MinecraftAPIConfiguration -DefaultTimeout 45 -MaxRetryAttempts 2
    Write-Host "✓ Configuration function works" -ForegroundColor Green
}
catch {
    Write-Host "✗ Configuration function failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 5: Test client creation
Write-Host "`nTest 5: Testing client creation..." -ForegroundColor Yellow
try {
    $testClient = New-MinecraftAPIClient -Name "TestServer" -BaseUrl "https://test.com" -Version "v1"
    if ($testClient.Name -eq "TestServer") {
        Write-Host "✓ Client creation works" -ForegroundColor Green
    }
    else {
        Write-Host "✗ Client creation returned unexpected result" -ForegroundColor Red
    }
}
catch {
    Write-Host "✗ Client creation failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 6: Test parameter validation (should fail gracefully)
Write-Host "`nTest 6: Testing parameter validation..." -ForegroundColor Yellow
try {
    # This should fail because ServerName doesn't exist
    Get-MinecraftServerInfo -ServerName "NonExistentServer" -Endpoint "test" -ErrorAction Stop
    Write-Host "✗ Parameter validation failed - should have thrown an error" -ForegroundColor Red
}
catch {
    if ($_.Exception.Message -like "*not found*") {
        Write-Host "✓ Parameter validation works correctly" -ForegroundColor Green
    }
    else {
        Write-Host "✗ Unexpected error in parameter validation: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`n=== Test Summary ===" -ForegroundColor Green
Write-Host "Module testing completed. Check results above for any failures." -ForegroundColor White
Write-Host "Note: Network connectivity tests are not performed in this basic test suite." -ForegroundColor Yellow