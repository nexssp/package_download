NexssStdin=`cat`
# NexssStdout=$(echo "$NexssStdin"|jq ".outputBash = \"Hello from Bash! $BASH_VERSION\"")
# NexssStdout=$(echo "$NexssStdin"|jq -r ".test = \"test\"")

# we need to

if [ ! -z "$NexssStdin" ]
then
    downloadPathCache=$(echo "$NexssStdin"|jq -r '.downloadPathCache')
    
    if [ ! $downloadPathCache = null ]
    then                 
        downloadsFolder="$NEXSS_CACHE_PATH/$DOWNLOAD_FOLDER"
    else
        cwd=$(echo "$NexssStdin"|jq -r '.cwd')
        downloadsFolder=$(echo "$NexssStdin"|jq -r '.downloadsFolder')
        if [ $downloadsFolder = null ]
        then            
            downloadsFolder="$cwd"
        else
            downloadsFolder="$cwd/$downloadsFolder"
        fi
    fi

    echo "NEXSS/ok:Downloads folder $downloadsFolder">&2

    downloads=$(echo "$NexssStdin"|jq -r '.nxsIn[]?')
    
    if [[ -z $downloads ]]
    then 
        echo "NEXSS/error:Nothing to download">&2
        NexssStdout=$(echo "$NexssStdin"|jq ".nxsStop=1")
        
    else    
        
        downloadNocache=$(echo "$NexssStdin"|jq -r '.downloadNocache')

        regex='^(https?|ftp|file)://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]\.[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]$'
        arr=()
        for url in $downloads
        do
            if [[ $url =~ $regex ]]
            then
                filename="${url##*/}" # get base url
                item="$downloadsFolder/$filename"      
                if [ -f $tem ]
                then
                    echo "NEXSS/info:File $item already exists. Use --downloadNocache to reupload">&2
                else
                    echo "NEXSS/info:Downloading $url..">&2
                fi
                [ -f $tem ] && rm $item

                # -L - follow the redirections
                curl -s -L $url --create-dirs -o $item #2>&1 #/dev/null

                arr+=( $item )
            else        
                echo "NEXSS/error:Item $url is not valid url!!">&2
                NexssStdout=$(echo "$NexssStdin"|jq ".nxsStop=1")
            fi
        done
    fi
    NexssStdout=$(echo "$NexssStdout"|jq "del(.nxsIn)")
    NexssStdout=$(echo "$NexssStdout"|jq ".nxsOut = \"$arr\"")
else    
    echo "NEXSS/error:Stream is empty, did you pass anything to the stream?">&2
    exit 1
fi

echo $NexssStdout>&1