#!/bin/bash

Help() {
   # Display Help
   echo "Get the resources in Snyk Cloud for an organization."
   echo "Your token can be passed manually or saved as an"
   echo "environment variable named <SNYK_CLOUD_RESOURCES_TOKEN>."
   echo
   echo "Results will be put in a file named response.json"
   echo
   echo "To get a count of resources, pass the output from"
   echo "this file to the count_resources.sh."
   echo
   echo "Syntax: get_resources.sh [-h|--help|-o|--org]"
   echo "options:"
   echo "-h, --help     Print this help"
   echo "-o, --org      Pass the organization ID"
}

############################################################
# Main program                                             #
############################################################

ORG_ID=""
TOKEN=""
BASE_URL="https://api.snyk.io"
URL_PATH="cloud/resources"
API_VERSION="2023-04-21%7Ebeta"
LIMIT_PARAM="limit="
LIMIT="100"
INCREMENT=2

# Confirm JQ is installed
jq_exit=$(jq --version| echo $?)
if [ "$jq_exit" != "0" ]; then
  echo "JQ not found. JQ must be installed to use this."
  exit 1
fi

# Print help
if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
  Help
  exit
fi

# Get the org ID
if [ "$1" == "--org" ] || [ "$1" == "-o" ]; then
  ORG_ID=$2
fi

# Collect the token if it's not set
if [ "$TOKEN" == "" ]; then
  echo "Please enter your token:"
  read -s token
  TOKEN=$token
fi

# Collect the org ID if it's not set
if [ "$TOKEN" == "" ]; then
  echo "Please enter your org ID:"
  read organization
  TOKEN=$organization
fi

# Construct the URL, create an output file and make the initial API call
URL="${BASE_URL}/rest/orgs/${ORG_ID}/${URL_PATH}?version=${API_VERSION}&limit=${LIMIT}"
timestamp=$(date +%s)
touch resources_$timestamp.json

echo $URL
response=$(curl -X GET "${URL}" \
    -H "Accept: application/vnd.api+json" \
    -H "Authorization: Token ${TOKEN}")
echo $response >> resources_$timestamp.json

# Check if there are more pages
NEXT=$(echo $response | jq ' .links.next' | tr -d '"')

# Continue to call the API until there aren't more pages
while [[ $NEXT != "" ]]
do
    echo "Collecting page $INCREMENT"
    response=$(curl -X GET "${BASE_URL}${NEXT}" \
    -H "Accept: application/vnd.api+json" \
    -H "Authorization: Token ${TOKEN}")
    echo $response >> resources_$timestamp.json
    NEXT=$(echo $response | jq ' .links.next' | tr -d '"')
    ((INCREMENT++))
    sleep 1
done