
# Entrypoint which scans for the data/ directory
# and all .config files recursively
#

find $(pwd)/data/ -name ".config" -printf '%h\n' | while read DIR; do
  echo Fetching $DIR
  ./fetch.sh "$DIR" "$1"
done
