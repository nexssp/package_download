# Nexss PROGRAMMER 2.0.0 - PowerShell
# Default template for JSON Data
# STDIN
[Console]::OutputEncoding = [Text.UTF8Encoding]::UTF8
[Console]::InputEncoding = [Text.UTF8Encoding]::UTF8

$NexssStdin = $input
$NexssStdout = $NexssStdin | ConvertFrom-Json

# $env:NEXSS_CACHE_PATH - is default nexss env folder
# $env:DOWNLOAD_FOLDER - is specified in the config.env of this module
if ($NexssStdout.downloadPathCache) {
    $downloadsFolder = "$env:NEXSS_CACHE_PATH\$env:DOWNLOAD_FOLDER\"
}
else {
    $downloadsFolder = "$($NexssStdout.cwd)/$env:DOWNLOAD_FOLDER"
}

[Console]::Error.WriteLine("NEXSS/info:Download Folder: $downloadsFolder")

$NexssStdout | Add-Member -Force -NotePropertyMembers  @{downloadsFolder = "$downloadsFolder" }

function isURIWeb($address) {
    $uri = $address -as [System.URI]
    $uri.AbsoluteURI -ne $null -and $uri.Scheme -match '[http|https]'
}

if ( ! ( Test-Path $downloadsFolder)) {    
    New-Item -ItemType "directory" -Path $downloadsFolder | Out-Null
}

$wc = New-Object System.Net.WebClient  
$downloadedPaths = @()
$total = $NexssStdout.files.Count
[Console]::Error.WriteLine("NEXSS/info:Starting Download $total files(s)..")
if ($total -eq 0) {
    [Console]::Error.WriteLine("NEXSS/error:Nothing to download")
    exit
}

$i = 0
foreach ($sourceFile in $NexssStdout.files) { 
    $i++
    $percentComplete = ($i / $total) * 100
    
    if (!(isURIWeb($sourceFile))) {
        [Console]::Error.WriteLine("NEXSS/error:This is not url: $sourceFile") 
        exit;
    }
        
    $sourceFileName = $sourceFile.SubString($sourceFile.LastIndexOf('/') + 1)

    $targetPath = Join-Path -Path $downloadsFolder -ChildPath $sourceFileName  

    if ((Test-Path $targetPath) -and !($NexssStdout.downloadNocache)) {
        [Console]::Error.WriteLine("NEXSS/ok:$targetPath already exists. Use --downloadNocache to re-download.")
    }
    else {
        [Console]::Error.WriteLine("NEXSS/info:Downloading $sourceFile to file location $targetPath")
        Write-Progress -Activity "Downloading... ($i/$total)" -Status "File: $sourceFileName" -PercentComplete $percentComplete
        $wc.DownloadFile($sourceFile, $targetPath)
        
    }   
    
    $downloadedPaths += $targetPath
} 
if ( $downloadedPaths) {
    $NexssStdout | Add-Member -Force -NotePropertyMembers  @{files = $downloadedPaths }
}
else {
    $NexssStdout.PSObject.Properties.Remove("files")
    
}

$NexssStdout.PSObject.Properties.Remove("downloadPathCache")


# Because downloaded files are just files we call them files so they can be easy pass without parameters to the nexss module.
# Of course you can always rename data by using nexss Data/Rename etc..

# STDOUT
Write-Host 	(ConvertTo-Json -Compress $NexssStdout)
