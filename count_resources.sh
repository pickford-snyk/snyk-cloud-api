 #!/bin/bash

 Help() {
    # Display Help
    echo "Pass a resources JSON file to this script in order to count resources."
    echo
    echo "Syntax: count_resources.sh [-h|--help|-f|--file]"
    echo "options:"
    echo "-h, --help     Print this help"
    echo "-f, --file     Pass the filename"
 }

 FILE_PATH=""

 # Confirm JQ is installed
 jq_exit=$(jq --version| echo $?)
 if [ "$jq_exit" != "0" ]; then
   echo "JQ not found. JQ must be installed to use this."
   exit 1
 fi

 if [ "$1" == "--file" ] || [ "$1" == "-f" ]; then
   FILE_PATH=$2
 fi

 cat "$FILE_PATH" | jq -r '.data[] | .attributes | .resource_type' | sort | uniq -c