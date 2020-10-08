# Nexss PROGRAMMER 2.0

Downloads files from Web.

## Examples

```sh
# downloads to files to the currentfolder/downloads
nexss Download https://prdownloads.sourceforge.net/tcl/tcl8610-src.zip https://prdownloads.sourceforge.net/tcl/tk8610-src.zip https://core.tcl-lang.org/tcllib/uv/tcllib-1.19.zip --downloadPathCache

nexss Download https://nexss.com/myfile.zip --downloadsFolder=${env:NEXSS_APPS_PATH}/myfile

# if you add --downloadPathCache it will download to the ${env:NEXSS_CACHE_PATH}/downloads
# 'downloads' is setup in the config.env
```

```ps1
# Example Download file and run
$NexssDownloadInfo = $(nexss Download --files=http://repo.msys2.org/distrib/x86_64/msys2-x86_64-20190524.exe) | ConvertFrom-Json
& $NexssDownloadInfo.files
```

## Parameters

**--downloadPathCache** - will download to the cache folder (not the current folder)  
**--downloadNocache** - will not use cache and re-download if already exists.  
**--downloadFast** - for faster downloads (but without progress bar) - \* OnlyWindows
