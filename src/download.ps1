# Nexss PROGRAMMER 2.0 - Package Download
# This one will be removed after package run ends
$nxsParameters = @("downloadPathCache", "downloadNocache", "downloadFast")
$input | . "$($env:NEXSS_PACKAGES_PATH)/Nexss/Lib/NexssIn.ps1"


# Get isURIWeb
. "$($env:NEXSS_PACKAGES_PATH)/Nexss/Lib/Validate.ps1"
# $env:NEXSS_CACHE_PATH - is default nexss env folder
# $env:DOWNLOAD_FOLDER - is specified in the config.env of this module
if ($NexssStdout.downloadPathCache) {
    $downloadsFolder = "$env:NEXSS_CACHE_PATH\$env:DOWNLOAD_FOLDER\"
}
else {
    if ($NexssStdout.destinationFolder) {
        $downloadsFolder = "$($NexssStdout.destinationFolder)"
    }
    else {
        $downloadsFolder = "$($NexssStdout.cwd)"
    }
}

if ( ! ( Test-Path $downloadsFolder)) {
    nxsInfo("Creating download Folder: $downloadsFolder")    
    New-Item -ItemType "directory" -Path $downloadsFolder | Out-Null
}

nxsInfo("Download Folder: $downloadsFolder")
$NexssStdout | Add-Member -Force -NotePropertyMembers  @{downloadsFolder = "$downloadsFolder" }

$wc = New-Object System.Net.WebClient  
$downloadedPaths = @()
$total = $inFieldValue_1.Count

if ($total -eq 0) {
    nxsError("NEXSS/error:Nothing to download")
    exit
}

nxsInfo("Starting Download $total files(s)..")

$i = 0
foreach ($sourceFile in $inFieldValue_1) { 
    $i++
    $percentComplete = ($i / $total) * 100
    
    if (!(isURIWeb($sourceFile))) {
        nxsError("This is not url: $sourceFile") 
        exit;
    }
        
    $sourceFileName = $sourceFile.SubString($sourceFile.LastIndexOf('/') + 1)

    $targetPath = Join-Path -Path $downloadsFolder -ChildPath $sourceFileName  

    if ((Test-Path $targetPath) -and !($NexssStdout.downloadNocache)) {
        nxsOk("$targetPath already exists. Use --downloadNocache to re-download.")
    }
    else {
        nxsInfo("Downloading $sourceFile to file location $targetPath")
        Write-Progress -Activity "Downloading... ($i/$total)" -Status "File: $sourceFileName" #-PercentComplete $percentComplete
        if ($NexssStdout.downloadFast) {
            $meassure = Measure-Command { $wc.DownloadFile($sourceFile, $targetPath) }
        }
        else {
            $meassure = Measure-Command { Invoke-WebRequest -Uri $sourceFile -OutFile $targetPath }
        }

        nxsOk("Downloaded in $($meassure.Seconds) s. Use --downloadFast for faster downloading, but without download progress information.")
        $NexssStdout | Add-Member -Force -NotePropertyMembers  @{downloadSeconds = $meassure.Seconds }
    }   
    
    $downloadedPaths += $targetPath
} 
if ( $downloadedPaths) {
    $NexssStdout | Add-Member -Force -NotePropertyMembers  @{"$resultField_1" = $downloadedPaths }
}
else {
    $NexssStdout.PSObject.Properties.Remove($resultField_1)
    
}

. "$($env:NEXSS_PACKAGES_PATH)/Nexss/Lib/NexssOut.ps1"
