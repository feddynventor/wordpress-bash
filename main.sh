
# Entrypoint which scans for the data/ directory
# and all .config files recursively
#
# arg1 : @fetch.sh

DATA_DIR=$(pwd)/data/

find $DATA_DIR -name ".config" -printf '%h\n' | while read DIR; do
  ./fetch.sh "$DIR" "$1"
done
