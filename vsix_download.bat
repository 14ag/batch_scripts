@echo off
setlocal enabledelayedexpansion



if "%~1"=="" (
    echo Usage: %~nx0 [URL]
    echo Example: %~nx0 https://marketplace.visualstudio.com/items?itemName=Vue.volar
    echo.
	set /p "URL=url to the extension: "
) else (
	set "URL=%~1"
)



set "ITEM_PARAM=%URL:*itemName=%"

for /f "tokens=1 delims=&" %%A in ("%ITEM_PARAM%") do set "ITEM_ID=%%A"

for /f "tokens=1,2 delims=." %%A in ("%ITEM_ID%") do (
    set "PUBLISHER=%%A"
    set "EXTENSION=%%B"
)

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
"$ProgressPreference = 'SilentlyContinue';" ^
"$ErrorActionPreference = 'Stop';" ^
"$itemId = '%ITEM_ID%';" ^
"$publisher = '%PUBLISHER%';" ^
"$extension = '%EXTENSION%';" ^
"$apiUrl = 'https://marketplace.visualstudio.com/_apis/public/gallery/extensionquery';" ^
"$body = @{" ^
"    filters = @(@{" ^
"        criteria = @(@{ filterType = 7; value = $itemId })" ^
"    });" ^
"    flags = 870" ^
"} | ConvertTo-Json -Depth 5;" ^
"$headers = @{ 'Accept' = 'application/json;api-version=3.0-preview.1' };" ^
"$response = Invoke-RestMethod -Uri $apiUrl -Method Post -Body $body -ContentType 'application/json' -Headers $headers;" ^
"if ($null -eq $response.results[0].extensions[0]) { Write-Error 'Extension not found.'; exit 1; }" ^
"$extData = $response.results[0].extensions[0];" ^
"$displayName = $extData.displayName;" ^
"$latestVersion = $extData.versions[0].version;" ^
"Write-Host 'Extension Name: ' $displayName;" ^
"Write-Host 'Publisher:      ' $publisher;" ^
"Write-Host 'Latest Version: ' $latestVersion;" ^
"$downloadUrl = 'https://' + $publisher + '.gallery.vsassets.io/_apis/public/gallery/publisher/' + $publisher + '/extension/' + $extension + '/' + $latestVersion + '/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage';" ^
"$outputFile = $itemId + '-' + $latestVersion + '.vsix';" ^
"Write-Host 'Downloading VSIX bundle to' $outputFile '...';" ^
"Invoke-WebRequest -Uri $downloadUrl -OutFile $outputFile;" ^
"Write-Host 'Download complete.'"

endlocal