
# This file calls Wordpress APIs as instructed in the config file in the specified directory
# and stores a JSON file per category ID
#
# (this is made to virtually bypass the per_page limit of 100)
# TODO: implement page browsing
#
# arg1 : directory containing .config file
# arg2 : second level domain
#

# Config
DOMAIN=$2.it

# arg1 : (mandatory) comma separated categories wp_id
# arg2 : days to look back
# arg3 : limit
# arg4 : comma separated categories to exclude
# posts_url "42,41" "5" "" "1,2"
function posts_url {
  if [ -z "$1" ]; then return; fi
  DATE=""
  if [ ! -z "$2" ]; then
    DATE="&after=$(date --date "$2 days ago" --iso-8601)T00:00:00"
  fi
  LIMIT="&per_page=100"
  if [ ! -z "$3" ]; then
    LIMIT="&per_page=${3}"
  fi
  EXCLUDE=""
  if [ ! -z "$4" ]; then
    EXCLUDE="&categories_exclude=${4}"
  fi
  echo "https://$DOMAIN/wp-json/wp/v2/posts?_fields=id,date,modified,title,categories,acf,featured_media&categories=$1$DATE$LIMIT$EXCLUDE"
}

# config file params
MAX=$( jq '.max | select (.!=null)' "$1/.config" )
DAYS=$( jq '.days | select (.!=null)' "$1/.config" )
EXCLUDE=$( jq '.exclude | join(",") | select (.!=null)' "$1/.config" | tr -d '"' )  #comma separated

jq -c '.id[]' "$1/.config" | while read SET; do
  # decorated ID object
  ID=$( jq '.id' <<< $SET )
  NAME=$( jq '.name' <<< $SET )
  # else SET is ID
  if [ -z $ID ]; then
    ID=$SET
  fi

  URL=$( posts_url "$ID" "$DAYS" "$MAX" "$EXCLUDE" )
  RESPONSE=$( wget "$URL" -O - )

  if [ ! -z $NAME ]; then
    printf "$RESPONSE" | jq --arg k $( echo "$NAME" | tr -d '"' ) '.[] += {"main_category" : $k}' > $1/$ID
  else
    printf "$RESPONSE" > $1/$ID
  fi
done
