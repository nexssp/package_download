NexssStdin=`cat`
# NexssStdout=$(echo "$NexssStdin"|jq ".outputBash = \"Hello from Bash! $BASH_VERSION\"")
# NexssStdout=$(echo "$NexssStdin"|jq -r ".test = \"test\"")
folderToAdd=$(echo "$NexssStdin"|jq -r ".nxsIn[0]")

if [ ! -d $folderToAdd ]
then
  echo "NEXSS/error:Folder $folderToAdd does not exist">&2
  exit 1
else
    echo "NEXSS/ok:Adding path to your PATH: $folderToAdd">&2
    # Adds only once as grep checks if exists
    grep -qxF "export PATH=\"$folderToAdd:\$PATH\"" ~/.bashrc || echo "export PATH=\"$folderToAdd:\$PATH\"" > ~/.bashrc
    echo $NexssStdout>&1
fi