# UNIVERSEAPI

A PowerShell module for accessing Minecraft server APIs, with built-in support for EarthMC Aurora API and easy extensibility for other Minecraft servers.

## Features

- 🎯 **EarthMC Aurora API Support**: Built-in functions for accessing the EarthMC Aurora API at `https://api.earthmc.net/v3/aurora`
- 🔧 **Modular Design**: Easy to extend for other Minecraft server APIs
- 🛡️ **Error Handling**: Comprehensive error handling with retry logic
- 📊 **Logging**: Built-in logging for debugging and monitoring
- ⚙️ **Configurable**: Customizable timeouts, retry attempts, and headers
- 🔌 **Extensible**: Generic functions that work with any REST API

## Installation

1. Clone or download this repository
2. Import the module in PowerShell:

```powershell
Import-Module .\UniverseAPI.psd1
```

## Quick Start

### Basic EarthMC Aurora API Usage

```powershell
# Get general Aurora server data
$auroraData = Get-EarthMCAuroraData

# Get specific Aurora endpoint data
$playersData = Get-EarthMCAuroraData -Endpoint "players"
$townsData = Get-EarthMCAuroraData -Endpoint "towns"
```

### Generic Minecraft Server API Usage

```powershell
# Use with the built-in EarthMC configuration
$serverInfo = Get-MinecraftServerInfo -ServerName "EarthMC" -Endpoint "v3/aurora"

# Use with a custom server
$customData = Get-MinecraftServerInfo -CustomBaseUrl "https://api.myserver.com" -Endpoint "status"
```

### Low-Level API Access

```powershell
# Direct API calls with full control
$result = Invoke-MinecraftAPI -BaseUrl "https://api.earthmc.net" -Endpoint "v3/aurora" -Headers @{
    "Authorization" = "Bearer your-token"
}
```

## Available Functions

### Core Functions

#### `Get-EarthMCAuroraData`
Retrieves data from the EarthMC Aurora API.

**Parameters:**
- `Endpoint` (optional): Specific Aurora endpoint to query
- `CustomHeaders` (optional): Additional headers to include

**Examples:**
```powershell
# Get base Aurora data
Get-EarthMCAuroraData

# Get players data
Get-EarthMCAuroraData -Endpoint "players"

# Get data with custom headers
Get-EarthMCAuroraData -Endpoint "towns" -CustomHeaders @{"X-API-Key" = "your-key"}
```

#### `Get-MinecraftServerInfo`
Generic function for getting information from any Minecraft server API.

**Parameters:**
- `ServerName`: Name of registered server configuration
- `CustomBaseUrl`: Custom base URL for unregistered servers
- `Endpoint`: API endpoint to query
- `Headers` (optional): Additional headers

**Examples:**
```powershell
# Use registered server
Get-MinecraftServerInfo -ServerName "EarthMC" -Endpoint "v3/aurora"

# Use custom server
Get-MinecraftServerInfo -CustomBaseUrl "https://api.myserver.com" -Endpoint "status"
```

#### `Invoke-MinecraftAPI`
Low-level function for making HTTP requests to any API.

**Parameters:**
- `BaseUrl`: Base URL of the API
- `Endpoint`: Specific endpoint to call
- `Method` (optional): HTTP method (default: GET)
- `Headers` (optional): Request headers
- `Body` (optional): Request body for POST/PUT
- `Timeout` (optional): Request timeout in seconds

**Examples:**
```powershell
# GET request
Invoke-MinecraftAPI -BaseUrl "https://api.earthmc.net" -Endpoint "v3/aurora"

# POST request with body
Invoke-MinecraftAPI -BaseUrl "https://api.server.com" -Endpoint "data" -Method "POST" -Body '{"key": "value"}'
```

### Configuration Functions

#### `New-MinecraftAPIClient`
Creates a new API client configuration for easy reuse.

**Parameters:**
- `Name`: Configuration name
- `BaseUrl`: API base URL
- `Version` (optional): API version
- `Headers` (optional): Default headers
- `Endpoints` (optional): Predefined endpoints

**Example:**
```powershell
$client = New-MinecraftAPIClient -Name "MyServer" -BaseUrl "https://api.myserver.com" -Version "v2" -Headers @{
    "Authorization" = "Bearer token"
} -Endpoints @{
    "players" = "players"
    "stats" = "statistics"
}
```

#### `Set-MinecraftAPIConfiguration`
Updates global module configuration.

**Parameters:**
- `DefaultTimeout` (optional): Default request timeout
- `UserAgent` (optional): User agent string
- `MaxRetryAttempts` (optional): Maximum retry attempts

**Example:**
```powershell
Set-MinecraftAPIConfiguration -DefaultTimeout 60 -MaxRetryAttempts 5 -UserAgent "MyApp/1.0"
```

## Extending for Other APIs

The module is designed to be easily extended for other Minecraft server APIs:

### 1. Add a New Server Configuration

```powershell
# Add to the module's APIConfigurations
$script:APIConfigurations.MyServer = @{
    BaseUrl = "https://api.myserver.com"
    Version = "v1"
    Endpoints = @{
        Players = "players"
        Worlds = "worlds"
    }
    Headers = @{
        "Accept" = "application/json"
        "Authorization" = "Bearer your-token"
    }
}
```

### 2. Create Specific Functions

```powershell
function Get-MyServerData {
    param(
        [string]$Endpoint = "",
        [hashtable]$CustomHeaders = @{}
    )
    
    $config = $script:APIConfigurations.MyServer
    $fullEndpoint = "$($config.Version)/$Endpoint"
    
    return Invoke-MinecraftAPI -BaseUrl $config.BaseUrl -Endpoint $fullEndpoint -Headers $config.Headers
}
```

## Error Handling

The module includes comprehensive error handling:

- **Retry Logic**: Automatic retry for failed requests (configurable)
- **Timeout Handling**: Configurable timeouts for all requests
- **Detailed Logging**: Information, warning, and error logging
- **Graceful Failures**: Proper error messages and exceptions

## Examples

See `Examples.ps1` for comprehensive usage examples including:

- Basic API calls
- Custom server configurations
- Error handling demonstrations
- Advanced usage patterns

## Configuration

Default module configuration:

```powershell
DefaultTimeout = 30        # seconds
UserAgent = "UniverseAPI-PowerShell/1.0.0"
MaxRetryAttempts = 3
```

## Requirements

- PowerShell 5.1 or higher
- Internet connectivity for API calls
- Compatible with both Windows PowerShell and PowerShell Core

## API Documentation

For EarthMC API documentation, visit: https://earthmc.net/docs/api

## Contributing

To add support for additional Minecraft server APIs:

1. Add the server configuration to the `$script:APIConfigurations` hashtable
2. Create specific wrapper functions following the existing patterns
3. Update the module manifest to export new functions
4. Add examples and documentation

## License

This project is provided as-is for educational and development purposes.