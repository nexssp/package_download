# Nexss PROGRAMMER 2.0.0 - PowerShell
# Default template for JSON Data
# STDIN
[Console]::OutputEncoding = [Text.UTF8Encoding]::UTF8
[Console]::InputEncoding = [Text.UTF8Encoding]::UTF8

$NexssStdin = $input
$NexssStdout = $NexssStdin | ConvertFrom-Json


# $env:NEXSS_CACHE_PATH - is default nexss env folder
# $env:DOWNLOAD_FOLDER - is specified in the config.env of this module
if ($NexssStdout.cache) {
    $downloadsFolder = "$env:NEXSS_CACHE_PATH\$env:DOWNLOAD_FOLDER\"
}
else {
    $downloadsFolder = "$($NexssStdout.cwd)/$env:DOWNLOAD_FOLDER"
}

$NexssStdout | Add-Member -Force -NotePropertyMembers  @{downloadsFolder = "$downloadsFolder" }

function isURIWeb($address) {
    $uri = $address -as [System.URI]
    $uri.AbsoluteURI -ne $null -and $uri.Scheme -match '[http|https]'
}

if ( ! ( Test-Path $downloadsFolder)) {    
    New-Item -ItemType "directory" -Path $downloadsFolder | Out-Null
}

$wc = New-Object System.Net.WebClient  
foreach ($sourceFile in $NexssStdout._) { 
    if (!(isURIWeb($sourceFile))) {
        Write-Host "NEXSS DOWNLOAD: This is not url: $sourceFile"
        exit;
    }
        
    $sourceFileName = $sourceFile.SubString($sourceFile.LastIndexOf('/') + 1)   
    $targetPath = Join-Path -Path $downloadsFolder -ChildPath $sourceFileName  

    if (Test-Path $targetPath) {
        if ($NexssStdout.debug) {
            Write-Host "NEXSS DOWNLOAD: $targetPath already exists." -BackgroundColor Cyan
        } 
    }
    else {
        if ($NexssStdout.debug) {
            Write-Host "NEXSS DOWNLOAD: Downloading $sourceFile to file location $targetPath"
        }
        $wc.DownloadFile($sourceFile, $targetPath)
        if ($NexssStdout.debug) {            
            Write-Host "NEXSS DOWNLOAD: Downloaded $sourceFileName." -ForegroundColor yellow
        }
    }   
    
    $downloadedPaths += $targetPath
} 

$NexssStdout | Add-Member -Force -NotePropertyMembers  @{downloadedPaths = "$downloadedPaths" }

$NexssStdout | Add-Member -Force -NotePropertyMembers  @{"_" = @() }
# STDOUT
Write-Host 	(ConvertTo-Json -Compress $NexssStdout)
