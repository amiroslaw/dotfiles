#!/bin/bash

# Function to pull the filename from the target
# We use this for defining the saved filename
extract_filename() {
  local start_pos
  start_pos=$(awk -F"/" '{print length($0)-length($NF)}' <<< "${1:?Null string}")
  printf -- '%s\n' "${1:start_pos}"
}

# Function to extract download target from sci-hub html
get_target() {
  printf -- '%s' "https:"
  curl -s https://sci-hub.se/"${1:?No target specified}" | 
    grep location.href |
    grep -Eo '//[^ ]+pdf'
}

# Download our target via tor
get_url_via_tor() {
  # Ensure that Tor is running
  if ! systemctl is-active --quiet tor; then
    printf -- '%s\n' "Tor is not running yet: Starting Tor"
    if ! systemctl start tor; then
      printf -- '%s\n' /
        "An error occured while initializing Tor"
        "Make sure to correct this error, fix it and try again"
    fi
  fi
  target_url="$(proxychains -q get_target "${1}")"
  printf -- '%s\n' "${target_url}"
  proxychains -q curl "${target_url}" -o "$(extract_filename "${target_url}")"
  printf -- '%s\n' /
    "Saved as $(extract_filename "${target_url}")"
    "Once you are done do not forget to turn off Tor :)"
}

# Download our target
get_url() {
  target_url=$(get_target "${1}")
  printf -- '%s\n' "${target_url}"
  curl "${target_url}" -o "$(extract_filename "${target_url}")"
  printf -- '%s\n' "Saved as $(extract_filename "${target_url}")"
}

# Usage function
# This is exempt from our indentation rules as it's a heredoc
print_usage() {
cat <<USAGE
Usage: scihub [-h|--help|-t|--tor] [url]

Options:
    -h | --help    This usage message.
    -t | --tor     Attempt to fetch via tor network

Examples:
    scihub https://academic.oup.com/jn/article/130/4/1049S/4686675
    scihub --tor https://academic.oup.com/jn/article/130/4/1049S/4686675
USAGE
  return 0
}

# Go interactive and get the url from the user if required
read_url() {
  read -rp 'url: ' input_url
}

# Ensure that the given url actually works, fail out if it doesn't
validate_url() {
  if ! curl --output /dev/null -s --head --fail "${1:?No URL supplied}"; then
    printf -- '%s\n' "url: '${1}' not accesible, aborting"
    exit 1
  fi
}

# Do the things
case "${1}" in
  (-t|--tor)
    shift
    # If no url is given, go interactive
    [[ -z "${1}" ]] && read_url
    validate_url "${1:-$input_url}"
    printf -- '%s\n' "Getting resource via Tor service"
    get_url_via_tor "${1:-$input_url}"
  ;;
  (-h|--help|-?|--*) print_usage ;;
  (''|*)
    [[ -z "${1}" ]] && read_url
    validate_url "${1:-$input_url}"
    get_url "${1:-$input_url}"
  ;;
esac