#!/bin/bash

# Function to display help
function show_help() {
    echo
    echo "Usage: bash $0 <domain>"
    echo
    echo "Example: bash $0 example.com"
    echo
    echo "This script performs the following actions on the specified domain:"
    echo "  1. Creates a directory for the domain."
    echo "  2. Retrieves URLs from waybackurls and filters for 200 OK status."
    echo "  3. Filters URLs for various vulnerabilities (ssti, xss, ssrf, redirect, lfi, idor, sqli)."
    echo
    echo
    exit 0
}

# Check if help flag is passed
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
fi

# Check if domain argument is provided
if [ -z "$1" ]; then
    echo "Error: No domain provided."
    echo "Use -h or --help for usage information."
    exit 1
fi

DOMAIN=$1

mkdir "$DOMAIN"
cd "$DOMAIN"

echo "$DOMAIN" | waybackurls | tee all_Url_$DOMAIN.txt

cat all_Url_$DOMAIN.txt | httpx -mc 200 | tee 200_OK_Url.txt

cat 200_OK_Url.txt | sort | uniq | tee OK_Url_$DOMAIN.txt

gf ssti OK_Url_$DOMAIN.txt | tee ssti.txt
gf xss OK_Url_$DOMAIN.txt | tee xss.txt
gf ssrf OK_Url_$DOMAIN.txt | tee ssrf.txt
gf redirect OK_Url_$DOMAIN.txt | tee redirect.txt
gf lfi OK_Url_$DOMAIN.txt | tee lfi.txt
gf idor OK_Url_$DOMAIN.txt | tee idor.txt
gf sqli OK_Url_$DOMAIN.txt | tee sqli.txt

wc -l OK_Url_$DOMAIN.txt lfi.txt ssrf.txt xss.txt redirect.txt idor.txt sqli.txt ssti.txt
