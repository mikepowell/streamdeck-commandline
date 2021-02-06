# Tools

## Package-Plugin.ps1

PowerShell script that uses `DistributionTool.exe` to package the plugin and install it in the StreamDeck app.

Based on BarRaider's [install.bat](https://github.com/BarRaider/streamdeck-tools/blob/master/utils/install.bat) script.

## DistributionTool.exe

Validates and exports plugins for the Elgato Stream Deck plugin store. It is provided by
Elgato and can be downloaded [here](https://developer.elgato.com/documentation/stream-deck/sdk/exporting-your-plugin/).

### Usage

`DistributionTool [-h] [-b] [-v] [-i FILE] [-o DIRECTORY]`

### Optional arguments
```
  -b, --build                        Verify and build a plugin.
  -v, --version                      The version number of this tool.
  -h, --help                         This help dialog.
  -i FILE, --input FILE              Path to the plugin (.sdPlugin).
  -o DIRECTORY, --output DIRECTORY   Path to the output directory.
```
