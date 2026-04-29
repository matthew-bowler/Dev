<#
.SYNOPSIS
Gets computer accounts from Active Directory.

.DESCRIPTION
Queries Active Directory for computer objects and returns a practical set of
inventory properties. Results can be displayed in the console or exported to a
CSV file.

.PARAMETER SearchBase
Optional distinguished name of the OU or container to search.

.PARAMETER Name
Optional computer name pattern. Wildcards are supported, such as "NYC-*".

.PARAMETER Enabled
Optional enabled state filter. Use $true for enabled computers or $false for
disabled computers.

.PARAMETER OutputCsv
Optional path to export results as CSV.

.EXAMPLE
.\Get-ADComputers.ps1

.EXAMPLE
.\Get-ADComputers.ps1 -SearchBase "OU=Workstations,DC=contoso,DC=com" -Name "NYC-*" -Enabled $true

.EXAMPLE
.\Get-ADComputers.ps1 -OutputCsv .\ad-computers.csv
#>

[CmdletBinding()]
param(
    [Parameter()]
    [string]$SearchBase,

    [Parameter()]
    [string]$Name = '*',

    [Parameter()]
    [bool]$Enabled,

    [Parameter()]
    [string]$OutputCsv
)

$ErrorActionPreference = 'Stop'

if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
    throw 'The ActiveDirectory PowerShell module is required. Install RSAT Active Directory tools and run this script from a domain-joined machine or management host.'
}

Import-Module ActiveDirectory

$escapedName = $Name.Replace("'", "''")
$filterParts = @("Name -like '$escapedName'")

if ($PSBoundParameters.ContainsKey('Enabled')) {
    $filterParts += "Enabled -eq `$$($Enabled.ToString().ToLowerInvariant())"
}

$getComputerParams = @{
    Filter     = $filterParts -join ' -and '
    Properties = @(
        'DNSHostName',
        'Enabled',
        'IPv4Address',
        'LastLogonDate',
        'OperatingSystem',
        'OperatingSystemVersion',
        'WhenCreated'
    )
}

if ($SearchBase) {
    $getComputerParams.SearchBase = $SearchBase
}

$computers = @(Get-ADComputer @getComputerParams |
    Select-Object Name,
        DNSHostName,
        Enabled,
        IPv4Address,
        OperatingSystem,
        OperatingSystemVersion,
        LastLogonDate,
        WhenCreated,
        DistinguishedName |
    Sort-Object Name)

if ($OutputCsv) {
    $outputDirectory = Split-Path -Path $OutputCsv -Parent

    if ($outputDirectory -and -not (Test-Path -Path $outputDirectory)) {
        New-Item -Path $outputDirectory -ItemType Directory -Force | Out-Null
    }

    $computers | Export-Csv -Path $OutputCsv -NoTypeInformation
    Write-Host "Exported $($computers.Count) computer record(s) to $OutputCsv"
    return
}

$computers
