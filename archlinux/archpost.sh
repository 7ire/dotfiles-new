#!/usr/bin/env bash



# -----------------------------------------------------------------------------
#                  Arch Linux post install parameters
# -----------------------------------------------------------------------------
# Username
user=""
# Swap size
swapsize="16G"
# -----------------------------------------------------------------------------



# -----------------------------------------------------------------------------
#                  Export paramenters
# -----------------------------------------------------------------------------
export user swapsize



# -----------------------------------------------------------------------------
#                  Output debug messages
# -----------------------------------------------------------------------------

# Output debug message with color
print_debug() {
  local color="$1"
  local message="$2"
  echo -e "\e[${color}m${message}\e[0m"
}

print_success() {
  print_debug "32" "$1"
}

print_error() {
  print_debug "31" "$1"
}

print_info() {
  print_debug "36" "$1"
}

print_warning() {
  print_debug "33" "$1"
}