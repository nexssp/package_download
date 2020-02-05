# Nexss PROGRAMMER 2.0

Downloads files from Web.

## Examples

```sh
# downloads to files to the currentfolder/downloads
nexss Download --files=https://prdownloads.sourceforge.net/tcl/tcl8610-src.zip --files=https://prdownloads.sourceforge.net/tcl/tk8610-src.zip --files=https://core.tcl-lang.org/tcllib/uv/tcllib-1.19.zip --downloadPathCache

# if you add --cache it will download to the ${env:NEXSS_CACHE_PATH}/downloads
# 'downloads' is setup in the config.env
```

## Parameters

**--downloadPathCache** - will download to the cache folder (not the current folder)
**--donwloadNocache** - will not use cache and re-download if already exists.
