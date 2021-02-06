<#
.SYNOPSIS
    Packages the build output into a .streamDeckPlugin file for loading
    into the StreamDeck app.
.DESCRIPTION
    Uses Elgato's DistributionTool.exe utility to validate and package the contents
    of the output folder for the specified build configuration.
.EXAMPLE
    PS> .\Package-Plugin.ps1
    Creates the .streamDeckPlugin file for the default Debug build config.
.EXAMPLE
    PS> .\Package-Plugin.ps1 -Configuration Release
    Creates the .streamDeckPlugin file for the Release build config.
.PARAMETER Configuration
    The optional build configuration. May be either 'Debug' or 'Release'.
.NOTES
    The resulting package file will be created in
#>
[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [ValidateSet('Debug', 'Release')]
    [string]
    $Configuration = 'Debug'
)

$uuid = 'com.springhillsoftware.commandline'
$buildOutputPath = "..\src\streamdeck-commandline\bin\$Configuration"
$packageFilePath = "$buildOutputPath\$uuid.streamDeckPlugin"
$sdApplicationPath = "$env:Programfiles\Elgato\StreamDeck\StreamDeck.exe"
$sdPluginPath = "$env:APPDATA\Elgato\StreamDeck\Plugins\$uuid.sdPlugin"

function stopProcess() {
    [CmdletBinding()]
    param (
        [string]
        $processName
    )

    $p = Get-Process $processName -ErrorAction SilentlyContinue
    if ($p) {
        $p | Stop-Process
        $p | Wait-Process -Timeout 5
        if (Get-Process $processName -ErrorAction SilentlyContinue) {
            throw "Unable to stop process '$processName'."
        }
    }
}

# Stop the StreamDeck and plugin processes, if running.
stopProcess -processName 'StreamDeck' -ErrorAction Stop
stopProcess -processName 'streamdeck-commandline' -ErrorAction Stop

# Remove the plugin from the StreamDeck app's plugins folder.
Get-Item $sdPluginPath -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction Stop

# Remove the existing package file, the distribution tool won't overwrite.
Get-ChildItem $packageFilePath -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction Stop

# Build the package file.
.\DistributionTool.exe -b -i "$buildOutputPath\$uuid.sdPlugin" -o $buildOutputPath
if ($LastExitCode -ne 0) {
    throw "DistributionTool.exe failed with exit code $LastExitCode."
    return
}

# Start an instance of the StreamDeck app and wait for it to be ready.
Start-Process -FilePath $sdApplicationPath -ErrorAction Stop
Start-Sleep -Seconds 7

# Open the package file. The .streamDeckPlugin extension is registered to the SD app,
# which will load the updated plugin.
Start-Process -FilePath $packageFilePath
