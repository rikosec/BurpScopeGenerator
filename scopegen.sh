#!/bin/bash

# Function to display help message
show_help() {
    echo "Usage: $0 <domain> [-il <subdomains_file>] [-m <mode>]"
    echo
    echo "Options:"
    echo "  <domain>                Specify the domain for which to generate the scope."
    echo "  -il <subdomains_file>   Specify a file with a list of subdomains."
    echo "  -m <mode>               Specify the mode (https or wildcard). Default is https."
    echo
    echo "Examples:"
    echo "  $0 example.com -m https"
    echo "  $0 -il subdomains.txt -m wildcard"
}

# Function to generate JSON entry for a domain
generate_json_entry() {
    local domain=$1
    local protocol=$2
     # Correctly escape and format the domain for regex
    if [[ "$domain" == *\** ]]; then
        # Wildcard domain
        domain=$(echo "$domain" | sed -e 's/\./\\\\./g' -e 's/\*/\.\*/g')
    else
        # Regular domain
        domain=$(echo "$domain" | sed 's/\./\\\\./g')
    fi

    echo "        {"
    echo "          \"enabled\": true,"
    echo "          \"protocol\": \"$protocol\","
    echo "          \"host\": \"$domain\","
    echo "          \"port\": \"\","
    echo "          \"file\": \"\""
    echo "        }"
}

# Function to start JSON
start_json() {
    echo "{"
    echo "  \"target\": {"
    echo "    \"scope\": {"
    echo "      \"include\": ["
}

# Function to end JSON
end_json() {
    echo "      ],"
    echo "      \"exclude\": []"
    echo "    }"
    echo "  }"
    echo "}"
}

# Initialize variables
DOMAIN=""
SUBDOMAINS_FILE=""
MODE="https"  # Default to https
INCLUDE_SUBDOMAINS=false

# Check if no arguments are provided
if [ $# -eq 0 ]; then
    show_help
    exit 1
fi

# Parse arguments
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        -il)
        SUBDOMAINS_FILE="$2"
        INCLUDE_SUBDOMAINS=true
        shift # past argument
        shift # past value
        ;;
        -m)
        MODE="$2"
        shift # past argument
        shift # past value
        ;;
        *)
        DOMAIN="$1"
        shift # past argument
        ;;
    esac
done

# Check if domain or subdomains file is provided
if [ -z "$DOMAIN" ] && [ ! "$INCLUDE_SUBDOMAINS" = true ]; then
    echo "Error: No domain or subdomains file provided."
    show_help
    exit 1
fi

# Open file for writing
exec 3>scope.json

# Function to handle the scope generation logic
generate_scope() {
    local mode=$1
    local domain=$2
    local protocol="https"

    if [ "$mode" = "wildcard" ]; then
        protocol="any"
        domain="*.$domain"
    fi

    start_json >&3
    echo "$(generate_json_entry "$domain" "$protocol")" >&3
    end_json >&3
}

# Generate scope based on the mode
if [ -n "$DOMAIN" ] && [ ! "$INCLUDE_SUBDOMAINS" = true ]; then
    generate_scope "$MODE" "$DOMAIN"
fi

# Generate scope for subdomains from file
if [ "$INCLUDE_SUBDOMAINS" = true ]; then
    if [ -f "$SUBDOMAINS_FILE" ]; then
        start_json >&3
        FIRST_LINE=true
        while read -r line; do
            if [ "$FIRST_LINE" = true ]; then
                FIRST_LINE=false
            else
                echo "," >&3
            fi
            [ "$MODE" = "wildcard" ] && line="*.$line"
            echo "$(generate_json_entry "$line" "https")" >&3
        done < "$SUBDOMAINS_FILE"
        end_json >&3
    else
        echo "Subdomains file not found: $SUBDOMAINS_FILE"
        exit 1
    fi
fi

# Close file
exec 3>&-

echo "Scope saved to scope.json"

