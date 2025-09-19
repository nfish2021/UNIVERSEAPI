#Requires -Version 5.1

# UniverseAPI PowerShell Module
# A modular PowerShell script for accessing Minecraft server APIs

#region Module Variables
$script:ModuleConfig = @{
    DefaultTimeout = 30
    UserAgent = "UniverseAPI-PowerShell/1.0.0"
    MaxRetryAttempts = 3
}

$script:APIConfigurations = @{
    EarthMC = @{
        BaseUrl = "https://api.earthmc.net"
        Version = "v3"
        Endpoints = @{
            Aurora = "aurora"
            Nova = "nova"
        }
        Headers = @{
            "Accept" = "application/json"
        }
    }
}
#endregion

#region Helper Functions
function Write-APILog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,
        
        [Parameter()]
        [ValidateSet('Info', 'Warning', 'Error', 'Debug')]
        [string]$Level = 'Info'
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    switch ($Level) {
        'Info' { Write-Information $logMessage -InformationAction Continue }
        'Warning' { Write-Warning $logMessage }
        'Error' { Write-Error $logMessage }
        'Debug' { Write-Debug $logMessage }
    }
}

function Test-APIResponse {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [Microsoft.PowerShell.Commands.BasicHtmlWebResponseObject]$Response
    )
    
    if ($Response.StatusCode -ge 200 -and $Response.StatusCode -lt 300) {
        return $true
    }
    
    Write-APILog -Message "API request failed with status code: $($Response.StatusCode)" -Level 'Error'
    return $false
}

function ConvertFrom-APIResponse {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [Microsoft.PowerShell.Commands.BasicHtmlWebResponseObject]$Response
    )
    
    try {
        if ($Response.Content) {
            return ($Response.Content | ConvertFrom-Json)
        }
        else {
            Write-APILog -Message "Response content is empty" -Level 'Warning'
            return $null
        }
    }
    catch {
        Write-APILog -Message "Failed to parse JSON response: $($_.Exception.Message)" -Level 'Error'
        throw
    }
}
#endregion

#region Core API Functions
function Invoke-MinecraftAPI {
    <#
    .SYNOPSIS
    Generic function to invoke Minecraft server APIs.
    
    .DESCRIPTION
    This function provides a generic way to call any Minecraft server API endpoint.
    It handles authentication, error handling, and response parsing.
    
    .PARAMETER BaseUrl
    The base URL of the API (e.g., "https://api.earthmc.net")
    
    .PARAMETER Endpoint
    The specific endpoint to call (e.g., "v3/aurora")
    
    .PARAMETER Method
    HTTP method to use (default: GET)
    
    .PARAMETER Headers
    Additional headers to include in the request
    
    .PARAMETER Body
    Request body for POST/PUT requests
    
    .PARAMETER Timeout
    Request timeout in seconds (default: 30)
    
    .EXAMPLE
    Invoke-MinecraftAPI -BaseUrl "https://api.earthmc.net" -Endpoint "v3/aurora"
    
    .EXAMPLE
    Invoke-MinecraftAPI -BaseUrl "https://api.earthmc.net" -Endpoint "v3/aurora" -Headers @{"Authorization" = "Bearer token"}
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$BaseUrl,
        
        [Parameter(Mandatory = $true)]
        [string]$Endpoint,
        
        [Parameter()]
        [ValidateSet('GET', 'POST', 'PUT', 'DELETE', 'PATCH')]
        [string]$Method = 'GET',
        
        [Parameter()]
        [hashtable]$Headers = @{},
        
        [Parameter()]
        [string]$Body,
        
        [Parameter()]
        [int]$Timeout = $script:ModuleConfig.DefaultTimeout
    )
    
    begin {
        Write-APILog -Message "Starting API request to $BaseUrl/$Endpoint" -Level 'Debug'
    }
    
    process {
        try {
            # Construct the full URL
            $fullUrl = "$BaseUrl/$Endpoint".TrimEnd('/')
            
            # Prepare default headers
            $requestHeaders = @{
                "User-Agent" = $script:ModuleConfig.UserAgent
                "Accept" = "application/json"
            }
            
            # Merge custom headers
            foreach ($key in $Headers.Keys) {
                $requestHeaders[$key] = $Headers[$key]
            }
            
            # Prepare request parameters
            $requestParams = @{
                Uri = $fullUrl
                Method = $Method
                Headers = $requestHeaders
                TimeoutSec = $Timeout
                ErrorAction = 'Stop'
            }
            
            # Add body if provided
            if ($Body) {
                $requestParams.Body = $Body
                if (-not $requestHeaders.ContainsKey("Content-Type")) {
                    $requestParams.Headers["Content-Type"] = "application/json"
                }
            }
            
            Write-APILog -Message "Making $Method request to: $fullUrl" -Level 'Info'
            
            # Make the API request with retry logic
            $retryCount = 0
            do {
                try {
                    $response = Invoke-WebRequest @requestParams
                    break
                }
                catch {
                    $retryCount++
                    if ($retryCount -ge $script:ModuleConfig.MaxRetryAttempts) {
                        throw
                    }
                    
                    Write-APILog -Message "Request failed, retrying ($retryCount/$($script:ModuleConfig.MaxRetryAttempts)): $($_.Exception.Message)" -Level 'Warning'
                    Start-Sleep -Seconds (2 * $retryCount)
                }
            } while ($retryCount -lt $script:ModuleConfig.MaxRetryAttempts)
            
            # Validate response
            if (Test-APIResponse -Response $response) {
                Write-APILog -Message "API request successful" -Level 'Info'
                return ConvertFrom-APIResponse -Response $response
            }
            else {
                throw "API request failed with status code: $($response.StatusCode)"
            }
        }
        catch {
            Write-APILog -Message "API request failed: $($_.Exception.Message)" -Level 'Error'
            throw
        }
    }
}

function New-MinecraftAPIClient {
    <#
    .SYNOPSIS
    Creates a new Minecraft API client configuration.
    
    .DESCRIPTION
    This function creates a reusable API client configuration that can be used
    with other functions in this module.
    
    .PARAMETER Name
    Name for this API configuration
    
    .PARAMETER BaseUrl
    The base URL of the API
    
    .PARAMETER Version
    API version (if applicable)
    
    .PARAMETER Headers
    Default headers to include with requests
    
    .PARAMETER Endpoints
    Hashtable of available endpoints
    
    .EXAMPLE
    $client = New-MinecraftAPIClient -Name "MyServer" -BaseUrl "https://api.myserver.com" -Version "v1"
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,
        
        [Parameter(Mandatory = $true)]
        [string]$BaseUrl,
        
        [Parameter()]
        [string]$Version,
        
        [Parameter()]
        [hashtable]$Headers = @{},
        
        [Parameter()]
        [hashtable]$Endpoints = @{}
    )
    
    $config = @{
        Name = $Name
        BaseUrl = $BaseUrl.TrimEnd('/')
        Version = $Version
        Headers = $Headers
        Endpoints = $Endpoints
        CreatedAt = Get-Date
    }
    
    Write-APILog -Message "Created API client configuration for: $Name" -Level 'Info'
    return $config
}

function Set-MinecraftAPIConfiguration {
    <#
    .SYNOPSIS
    Sets or updates the global API configuration.
    
    .DESCRIPTION
    This function allows you to configure global settings for the API module.
    
    .PARAMETER DefaultTimeout
    Default timeout for API requests in seconds
    
    .PARAMETER UserAgent
    User agent string to use for requests
    
    .PARAMETER MaxRetryAttempts
    Maximum number of retry attempts for failed requests
    
    .EXAMPLE
    Set-MinecraftAPIConfiguration -DefaultTimeout 60 -MaxRetryAttempts 5
    #>
    
    [CmdletBinding()]
    param(
        [Parameter()]
        [int]$DefaultTimeout,
        
        [Parameter()]
        [string]$UserAgent,
        
        [Parameter()]
        [int]$MaxRetryAttempts
    )
    
    if ($DefaultTimeout) {
        $script:ModuleConfig.DefaultTimeout = $DefaultTimeout
        Write-APILog -Message "Set default timeout to $DefaultTimeout seconds" -Level 'Info'
    }
    
    if ($UserAgent) {
        $script:ModuleConfig.UserAgent = $UserAgent
        Write-APILog -Message "Set user agent to: $UserAgent" -Level 'Info'
    }
    
    if ($MaxRetryAttempts) {
        $script:ModuleConfig.MaxRetryAttempts = $MaxRetryAttempts
        Write-APILog -Message "Set max retry attempts to: $MaxRetryAttempts" -Level 'Info'
    }
}
#endregion

#region EarthMC Specific Functions
function Get-EarthMCAuroraData {
    <#
    .SYNOPSIS
    Gets data from the EarthMC Aurora API.
    
    .DESCRIPTION
    This function retrieves data from the EarthMC Aurora server API.
    It's a specialized wrapper around the generic Invoke-MinecraftAPI function.
    
    .PARAMETER Endpoint
    Specific Aurora endpoint to query (default: base aurora endpoint)
    
    .PARAMETER CustomHeaders
    Additional headers to include in the request
    
    .EXAMPLE
    Get-EarthMCAuroraData
    
    .EXAMPLE
    Get-EarthMCAuroraData -Endpoint "players"
    
    .EXAMPLE
    Get-EarthMCAuroraData -Endpoint "towns" -CustomHeaders @{"X-Custom" = "value"}
    #>
    
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$Endpoint = "",
        
        [Parameter()]
        [hashtable]$CustomHeaders = @{}
    )
    
    begin {
        $config = $script:APIConfigurations.EarthMC
        Write-APILog -Message "Retrieving EarthMC Aurora data" -Level 'Info'
    }
    
    process {
        try {
            # Construct the endpoint path
            $fullEndpoint = "$($config.Version)/$($config.Endpoints.Aurora)"
            if ($Endpoint) {
                $fullEndpoint += "/$Endpoint"
            }
            
            # Merge headers
            $headers = $config.Headers.Clone()
            foreach ($key in $CustomHeaders.Keys) {
                $headers[$key] = $CustomHeaders[$key]
            }
            
            # Make the API call
            $result = Invoke-MinecraftAPI -BaseUrl $config.BaseUrl -Endpoint $fullEndpoint -Headers $headers
            
            Write-APILog -Message "Successfully retrieved EarthMC Aurora data" -Level 'Info'
            return $result
        }
        catch {
            Write-APILog -Message "Failed to retrieve EarthMC Aurora data: $($_.Exception.Message)" -Level 'Error'
            throw
        }
    }
}

function Get-MinecraftServerInfo {
    <#
    .SYNOPSIS
    Gets general information from a Minecraft server API.
    
    .DESCRIPTION
    This function provides a generic way to get server information from various
    Minecraft server APIs. It can be easily adapted for different servers.
    
    .PARAMETER ServerName
    Name of the server configuration to use (must be registered in APIConfigurations)
    
    .PARAMETER CustomBaseUrl
    Custom base URL to use instead of a registered configuration
    
    .PARAMETER Endpoint
    Specific endpoint to query
    
    .PARAMETER Headers
    Additional headers to include
    
    .EXAMPLE
    Get-MinecraftServerInfo -ServerName "EarthMC" -Endpoint "v3/aurora"
    
    .EXAMPLE
    Get-MinecraftServerInfo -CustomBaseUrl "https://api.myserver.com" -Endpoint "status"
    #>
    
    [CmdletBinding(DefaultParameterSetName = 'RegisteredServer')]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'RegisteredServer')]
        [string]$ServerName,
        
        [Parameter(Mandatory = $true, ParameterSetName = 'CustomServer')]
        [string]$CustomBaseUrl,
        
        [Parameter(Mandatory = $true)]
        [string]$Endpoint,
        
        [Parameter()]
        [hashtable]$Headers = @{}
    )
    
    process {
        try {
            if ($PSCmdlet.ParameterSetName -eq 'RegisteredServer') {
                if (-not $script:APIConfigurations.ContainsKey($ServerName)) {
                    throw "Server configuration '$ServerName' not found. Available servers: $($script:APIConfigurations.Keys -join ', ')"
                }
                
                $config = $script:APIConfigurations[$ServerName]
                $baseUrl = $config.BaseUrl
                
                # Merge configuration headers with custom headers
                $mergedHeaders = $config.Headers.Clone()
                foreach ($key in $Headers.Keys) {
                    $mergedHeaders[$key] = $Headers[$key]
                }
                $Headers = $mergedHeaders
            }
            else {
                $baseUrl = $CustomBaseUrl.TrimEnd('/')
            }
            
            Write-APILog -Message "Getting server info from: $baseUrl/$Endpoint" -Level 'Info'
            
            $result = Invoke-MinecraftAPI -BaseUrl $baseUrl -Endpoint $Endpoint -Headers $Headers
            
            Write-APILog -Message "Successfully retrieved server information" -Level 'Info'
            return $result
        }
        catch {
            Write-APILog -Message "Failed to retrieve server information: $($_.Exception.Message)" -Level 'Error'
            throw
        }
    }
}
#endregion

#region Module Initialization
Write-APILog -Message "UniverseAPI module loaded successfully" -Level 'Info'
Write-APILog -Message "Available API configurations: $($script:APIConfigurations.Keys -join ', ')" -Level 'Debug'
#endregion

# Export module members
Export-ModuleMember -Function @(
    'Get-MinecraftServerInfo',
    'Get-EarthMCAuroraData', 
    'Invoke-MinecraftAPI',
    'New-MinecraftAPIClient',
    'Set-MinecraftAPIConfiguration'
)