# Configuration file for additional Minecraft Server APIs
# This file demonstrates how to extend the UniverseAPI module for other servers

# Example configurations for various Minecraft server APIs
$AdditionalAPIConfigurations = @{
    # Hypixel API Configuration
    Hypixel = @{
        BaseUrl = "https://api.hypixel.net"
        Version = "v2"
        Endpoints = @{
            Status = "status"
            Player = "player"
            Guild = "guild"
            SkyBlock = "skyblock"
            Boosters = "boosters"
            Leaderboards = "leaderboards"
        }
        Headers = @{
            "Accept" = "application/json"
            # Note: Hypixel requires an API key: "API-Key" = "your-api-key-here"
        }
        RequiresAuth = $true
        AuthType = "API-Key"
        RateLimit = @{
            RequestsPerMinute = 120
            RequestsPerMonth = 100000
        }
    }

    # Minehut API Configuration  
    Minehut = @{
        BaseUrl = "https://api.minehut.com"
        Version = ""
        Endpoints = @{
            Servers = "servers"
            Server = "server"
            Icons = "icons"
            Stats = "network/top_servers"
        }
        Headers = @{
            "Accept" = "application/json"
        }
        RequiresAuth = $false
    }

    # CraftingStore API Configuration
    CraftingStore = @{
        BaseUrl = "https://api.craftingstore.net"
        Version = "v7"
        Endpoints = @{
            Information = "information"
            Payments = "payments"
            Coupons = "coupons"
            Categories = "categories"
            Packages = "packages"
        }
        Headers = @{
            "Accept" = "application/json"
            # Note: Requires token: "Authorization" = "Bearer your-token-here"
        }
        RequiresAuth = $true
        AuthType = "Bearer"
    }

    # McAPI.us Configuration (Server Status)
    McAPI = @{
        BaseUrl = "https://mcapi.us"
        Version = ""
        Endpoints = @{
            ServerStatus = "server/status"
            ServerPing = "server/ping"
            ServerQuery = "server/query"
        }
        Headers = @{
            "Accept" = "application/json"
        }
        RequiresAuth = $false
    }

    # Example for a custom/private server
    CustomServer = @{
        BaseUrl = "https://api.yourserver.com"
        Version = "v1"
        Endpoints = @{
            Status = "status"
            Players = "players/online"
            Economy = "economy/stats"
            Logs = "logs/recent"
        }
        Headers = @{
            "Accept" = "application/json"
            "User-Agent" = "UniverseAPI-PowerShell/1.0.0"
            # Add authentication headers as needed
            # "Authorization" = "Bearer your-token"
            # "X-API-Key" = "your-api-key"
        }
        RequiresAuth = $true
        AuthType = "Bearer"
    }
}

# Function to register additional API configurations
function Register-AdditionalAPIConfigurations {
    <#
    .SYNOPSIS
    Registers additional API configurations with the UniverseAPI module.
    
    .DESCRIPTION
    This function adds the configurations defined in this file to the module's
    global API configurations, making them available for use with the standard functions.
    
    .EXAMPLE
    Register-AdditionalAPIConfigurations
    #>
    
    foreach ($serverName in $AdditionalAPIConfigurations.Keys) {
        $script:APIConfigurations[$serverName] = $AdditionalAPIConfigurations[$serverName]
        Write-Host "Registered API configuration for: $serverName" -ForegroundColor Green
    }
    
    Write-Host "All additional API configurations registered successfully!" -ForegroundColor Green
}

# Example functions for specific servers
function Get-HypixelPlayerData {
    <#
    .SYNOPSIS
    Gets player data from the Hypixel API.
    
    .DESCRIPTION
    Retrieves player information from Hypixel. Requires a valid API key.
    
    .PARAMETER PlayerUUID
    The UUID of the player to query
    
    .PARAMETER APIKey
    Your Hypixel API key
    
    .EXAMPLE
    Get-HypixelPlayerData -PlayerUUID "player-uuid-here" -APIKey "your-api-key"
    #>
    
    param(
        [Parameter(Mandatory = $true)]
        [string]$PlayerUUID,
        
        [Parameter(Mandatory = $true)]
        [string]$APIKey
    )
    
    $headers = @{
        "API-Key" = $APIKey
        "Accept" = "application/json"
    }
    
    $endpoint = "player?uuid=$PlayerUUID"
    
    return Invoke-MinecraftAPI -BaseUrl "https://api.hypixel.net" -Endpoint $endpoint -Headers $headers
}

function Get-MinehutServerList {
    <#
    .SYNOPSIS
    Gets the list of servers from Minehut.
    
    .DESCRIPTION
    Retrieves the list of active servers from the Minehut platform.
    
    .EXAMPLE
    Get-MinehutServerList
    #>
    
    return Get-MinecraftServerInfo -ServerName "Minehut" -Endpoint "servers"
}

function Test-MinecraftServerStatus {
    <#
    .SYNOPSIS
    Tests the status of any Minecraft server using McAPI.us.
    
    .DESCRIPTION
    Checks if a Minecraft server is online and retrieves basic information.
    
    .PARAMETER ServerAddress
    The address of the Minecraft server (e.g., "mc.hypixel.net")
    
    .PARAMETER Port
    The port of the server (default: 25565)
    
    .EXAMPLE
    Test-MinecraftServerStatus -ServerAddress "mc.hypixel.net"
    
    .EXAMPLE
    Test-MinecraftServerStatus -ServerAddress "myserver.com" -Port 25566
    #>
    
    param(
        [Parameter(Mandatory = $true)]
        [string]$ServerAddress,
        
        [Parameter()]
        [int]$Port = 25565
    )
    
    $endpoint = "server/status?ip=$ServerAddress&port=$Port"
    
    return Invoke-MinecraftAPI -BaseUrl "https://mcapi.us" -Endpoint $endpoint
}

# Usage example function
function Show-ConfigurationExamples {
    <#
    .SYNOPSIS
    Displays examples of how to use the additional API configurations.
    
    .DESCRIPTION
    Shows practical examples of using the extended API configurations.
    #>
    
    Write-Host "=== Additional API Configuration Examples ===" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "1. Register additional configurations:" -ForegroundColor Yellow
    Write-Host "   Register-AdditionalAPIConfigurations" -ForegroundColor White
    Write-Host ""
    
    Write-Host "2. Use Hypixel API:" -ForegroundColor Yellow
    Write-Host "   Get-HypixelPlayerData -PlayerUUID 'uuid' -APIKey 'key'" -ForegroundColor White
    Write-Host ""
    
    Write-Host "3. Get Minehut servers:" -ForegroundColor Yellow
    Write-Host "   Get-MinehutServerList" -ForegroundColor White
    Write-Host ""
    
    Write-Host "4. Check server status:" -ForegroundColor Yellow
    Write-Host "   Test-MinecraftServerStatus -ServerAddress 'mc.hypixel.net'" -ForegroundColor White
    Write-Host ""
    
    Write-Host "5. Use with generic function:" -ForegroundColor Yellow
    Write-Host "   Get-MinecraftServerInfo -ServerName 'Hypixel' -Endpoint 'status'" -ForegroundColor White
    Write-Host ""
}

# Export functions if this file is imported as a module
Export-ModuleMember -Function @(
    'Register-AdditionalAPIConfigurations',
    'Get-HypixelPlayerData',
    'Get-MinehutServerList', 
    'Test-MinecraftServerStatus',
    'Show-ConfigurationExamples'
) -Variable @(
    'AdditionalAPIConfigurations'
)

Write-Host "Additional API configurations loaded. Run 'Show-ConfigurationExamples' for usage examples." -ForegroundColor Cyan