#!/bin/bash

# Exit script on error
set -e

# Check for root rights
if [[ "${EUID}" -ne 0 ]]; then
  echo "Error: This script must be executed with root privileges (sudo)." >&2
  exit 1
fi

# Check if a username argument was provided
if [[ -z "$1" ]]; then
  echo "Usage: $0 <username>" >&2
  exit 1
fi

USERNAME="$1"

# Check if the user already exists
if id "$USERNAME" &>/dev/null; then
    echo "Error: User $USERNAME already exists." >&2
    exit 1
fi

# Determine the correct admin group based on the OS
if grep -qiE "debian|ubuntu" /etc/os-release; then
    ADMIN_GROUP="sudo"
else
    # RedHat, CentOS, Alpine and others usually use wheel
    ADMIN_GROUP="wheel"
fi

# Creating a user with /home/ directory, bash shell, and append to the admin group
useradd -m -s /bin/bash -G "$ADMIN_GROUP" "$USERNAME"

echo "User '$USERNAME' was succesfully created and added to the group '$ADMIN_GROUP'."
echo "Don't forget to set the password: passwd $USERNAME"
