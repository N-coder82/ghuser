#!/bin/bash

# ====== Script Info ======
#title          :github_user.sh
#description    :Get user info from GitHub API and display if user exists and info about the user.
#author         :drop_all_tables
#date           :5/17/24
#version        :1.0
#usage          :bash github_user.sh
#notes          :Install Curl and jq to use this script.
#bash_version   :3.2.57(1)-release
# =========================

# Color definitions using variables
_GREEN="\033[32m"
_BLUE="\033[34m"
_RED="\033[31m"
_YELLOW="\033[33m"
_NC="\033[0m" # No color

# Function to check if required commands are available
check_dependencies() {
  local _missing=false
  for cmd in curl jq revolver; do
    if ! command -v $cmd &> /dev/null; then
      echo -e "${_RED}Error: $cmd is not installed.${_NC}"
      _missing=true
    fi
  done
  if [ "$_missing" = true ]; then
    exit 1
  fi
}

# Function to check if a GitHub user exists and display user info
check_github_user_info() {
  local _username=$1
  local _api_url="https://api.github.com/users/$_username"

  # Start loading animation
  revolver --style 'line' start 'Loading Data...'

  # Make a GET request to the GitHub API
  local _response
  _response=$(curl --silent --write-out "HTTPSTATUS:%{http_code}" "$_api_url" || echo "HTTPSTATUS:000")
  local _http_code
  _http_code="${_response##*HTTPSTATUS:}"  # Extracting HTTP status code using parameter expansion
  local _user_info
  _user_info="${_response%HTTPSTATUS:*}"  # Extracting user info by removing HTTP status code part

  # Stop loading animation
  revolver stop

  # Check if the response is valid JSON
  if ! echo "$_user_info" | jq . &> /dev/null; then
    echo -e "${_RED}Error: Invalid JSON response from GitHub API.${_NC}"
    exit 1
  fi

  # Check the HTTP status code
  case "$_http_code" in
    200)
      # User exists
      echo -e "${_GREEN}User exists on GitHub.${_NC}"
      local _user_name
      _user_name=$(echo "$_user_info" | jq -r '.name // "No name available"')
      local _user_bio
      _user_bio=$(echo "$_user_info" | jq -r '.bio // "No bio available"')
      local _public_repos_count
      _public_repos_count=$(echo "$_user_info" | jq -r '.public_repos')
      local _followers_count
      _followers_count=$(echo "$_user_info" | jq -r '.followers')

      echo -e "${_BLUE}Profile URL: https://github.com/$_username${_NC}"

      if [ "$_public_repos_count" -eq 0 ]; then
        echo -e "${_YELLOW}Warning: The user is private.${_NC}"
      else
        echo -e "${_BLUE}Name: ${_NC}${_user_name}"
        echo -e "${_BLUE}Bio: ${_NC}${_user_bio}"
        echo -e "${_BLUE}Public Repositories: ${_NC}${_public_repos_count}"
        echo -e "${_BLUE}Followers: ${_NC}${_followers_count}"
      fi
      ;;
    000)
      echo -e "${_RED}Error: Network error or no internet connection.${_NC}"
      ;;
    400)
      echo -e "${_RED}Error: Bad request. The request could not be understood or was missing required parameters.${_NC}"
      ;;
    403)
      echo -e "${_RED}Error: Forbidden. You do not have permission to access this resource.${_NC}"
      ;;
    404)
      echo -e "${_RED}Error: User '$_username' not found on GitHub.${_NC}"
      ;;
    500)
      echo -e "${_RED}Error: Internal server error. Something went wrong on GitHub's end.${_NC}"
      ;;
    502)
      echo -e "${_RED}Error: Bad gateway. Received an invalid response from the upstream server.${_NC}"
      ;;
    503)
      echo -e "${_RED}Error: Service unavailable. GitHub's servers are currently unavailable.${_NC}"
      ;;
    504)
      echo -e "${_RED}Error: Gateway timeout. The upstream server failed to send a request in the time allowed by the server.${_NC}"
      ;;
    *)
      echo -e "${_RED}Error: An unexpected error occurred (HTTP status code: $_http_code).${_NC}"
      ;;
  esac
}

# Validate arguments
if [ -z "$1" ]; then
  echo -e "${_YELLOW}Usage: $0 <github_username>${_NC}"
  exit 1
fi

# Check for required dependencies
check_dependencies

# Call the function with the provided username
check_github_user_info "$1"