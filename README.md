# WordPress - BASH
This tool maps any WordPress website to your predefined tree structure

> As everything is a file,
a tree of files is ideal to store your content in a pretty organized way.
Thanks file system =D

Each subdirectory can contain:
- a `.config` file which specifies a list of WordPress category IDs, plus other directives
- other subdirectories
- both

```md
data
├── 7
├── Genres
│   ├── 11
│   ├── 12
│   └── 13
├── Sport
│   ├── 20
│   └── Highlights
│       └── 21
└── Talkshows
    ├── Talk A
    │   └── 83
    └── Talk C
        ├── 12
        └── 32
```

## data/ folder
This is the root of your submenus structure. So start making some `directories`!

Where you want your items to be, place a `.config`

> configs are written in JSON
as it is easily human readable

### id
The mandatory field is `id` and it's an array of category IDs
```
{
    "id": [
        11,
        12,
        { "id": 13, "name": "Fantasy" }
    ]
}
```
The script fetches one time per each specified ID, saving the corresponding JSON.
This is done in order to virtually multiply the `per_page` limit

Whether the `name` field is specified, a `main_category` field is added to the post entity.
This leaves the WordPress `categories` field untouch for further usage

### useful fields
Either one of those is required
- `days` which specify the maximum age relative to the current day. The `?after` parameter of the REST Api is used.
- `max` limits the fetched elements in the submenu. The `?per_page` parameter of the REST Api is used.

### other fields
- `exclude` is useful to fetch the categories specified in `id` but excluding posts across multiple categories included in this array.
```
{
    "id": [ 11,12 ],
    "exclude": [ 30 ]
}
```

## API Link
`DOMAIN= DAYS= LIMIT= wget \
    $DOMAIN/wp-json/wp/v2/posts\ \
    ?_fields\=id,date,modified,title,categories,acf,featured_media \
    &after\="$(date --date '$DAYS days ago' --iso-8601)"T00:00:00 \
    &per_page=${LIMIT} \
    &page=1 \
    | jq`

## TODO
The page management is not implemented, so it's possible to gather maximum 100 posts per category (as explained with the `id` field)
