#!/usr/bin/env bash
# Check if the number of arguments is correct
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <FILE_PATH> <HEADER_VALUE> <FOOTER_VALUE>"
    exit 1
fi

# Extract file path, header, and footer values from arguments
FILE_PATH="$1"
HEADER_VALUE="${2:2}"
FOOTER_VALUE="${3:2}"

# Execute sed commands to replace header and footer values
sed -E -i "" "s|(bytes public constant header = )hex\"[^\"]*\"|\1hex\"$HEADER_VALUE\"|" "$FILE_PATH"
sed -E -i "" "s|(bytes public constant footer = )hex\"[^\"]*\"|\1hex\"$FOOTER_VALUE\"|" "$FILE_PATH"
