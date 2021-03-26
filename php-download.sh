#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# Check if arguments were spplied
# if not then print help message and exit
if [ $# -eq 0 ]
then
cat <<HELP
Usage: php-download.sh VERSION

   VERSION        Major.Minor version
                  Only versions listed at
                  https://www.php.net/downloads
                  is available.

Example:
   ./php-download 8.0

HELP
exit 1
fi

# PHP Major.Minor version
PHP="$1"

# Directory to download PHP to
PHP_DIR=".php"

# Lookup The latest patch version
PHP_FILE=$(curl https://www.php.net/downloads.php 2>&1 | \
   grep --only-matching --perl-regexp \
   "href=\"\/distributions\/\Kphp-$PHP.\d{1,3}.tar.xz(?=\")")
PHP_VERSION=${PHP_FILE%.tar.xz}
URL=https://www.php.net/distributions/$PHP_FILE

# Download and extract PHP
mkdir --parents $PHP_DIR
curl --output "$PHP_DIR/$PHP_FILE" "$URL"
tar --extract --directory $PHP_DIR --file "$PHP_DIR/$PHP_FILE"

# Get the number of CPUs
CPUS=$(lscpu | grep -oP "^CPU\(s\):\s+\K\d$")

# Build PHP
cd "$PHP_DIR/$PHP_VERSION"
./configure
make --jobs "$CPUS"
cd ../..

# Create a shortcut to php for convenience
ln --symbolic "$PHP_DIR/$PHP_VERSION/sapi/cli/php" "$PHP_VERSION"

# .replit config file
# This makes the run button work
cat <<REPLIT > .replit
run = "./$PHP_VERSION -S 0.0.0.0:8000 -t ."
REPLIT

# Print helpful instruction on how to start the server
cat <<NEXT
Run this to start the server:
   "$PHP_VERSION -S 0.0.0.0:8000 -t ."
Or click the Run button.
NEXT
