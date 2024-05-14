#!/bin/bash

ALREADY_EXISTS=1

# Check if P4PORT starts with ssl:
if [[ "$P4PORT" == ssl:* ]]; then
  USE_SSL=1
else
  USE_SSL=0
fi

# Create directories if they don't exist
if [ ! -d "$P4ROOT" ]; then
  ALREADY_EXISTS=0
  mkdir -p "$P4ROOT"
fi
if [ ! -d "$(dirname "$P4JOURNAL")" ]; then
  mkdir -p "$(dirname "$P4JOURNAL")"
fi

generate_ssl() {
  echo "Generating SSL certificate..."
  echo "Country: $SSL_COUNTRY"
  echo "State: $SSL_STATE"
  echo "Locality: $SSL_LOCALITY"
  echo "Organization: $SSL_ORGANIZATION"
  echo "Organizational Unit: $SSL_ORGANIZATIONAL_UNIT"
  echo "Common Name: $SSL_COMMON_NAME"
  openssl req -x509 -nodes -days $SSL_EXPIRY -newkey rsa:2048 \
    -keyout "$P4SSLDIR/privatekey.txt" -out "$P4SSLDIR/certificate.txt" \
    -subj "/C=$SSL_COUNTRY/ST=$SSL_STATE/L=$SSL_LOCALITY/O=$SSL_ORGANIZATION/OU=$SSL_ORGANIZATIONAL_UNIT/CN=$SSL_COMMON_NAME" \
    2>/dev/null
}

# Enable SSL support
if [ $USE_SSL -eq 1 ]; then
  if [ ! -d "$P4SSLDIR" ]; then
    mkdir -p "$P4SSLDIR"
  fi

  if [ ! -f "$P4SSLDIR/privatekey.txt" ] || [ ! -f "$P4SSLDIR/certificate.txt" ]; then
    generate_ssl
  fi

  # Check if SSL certificate will expire in 24 hours
  if openssl x509 -checkend 86400 -noout -in "$P4SSLDIR/certificate.txt"; then
    # Certificate is still valid
    echo "No need to generate a new SSL certificate..."
  else
    generate_ssl
  fi

  # Secure the folder and files
  chmod 0700 "$P4SSLDIR"
  chmod 0600 "$P4SSLDIR/privatekey.txt"
  chmod 0600 "$P4SSLDIR/certificate.txt"
fi

# Configure the server for unicode support
if [ $ALREADY_EXISTS -eq 0 ]; then
  echo
  echo "First time setup..."
  p4d -xi
fi

echo
echo "######################         SERVER INFO         ######################"
echo
echo "P4PORT: $P4PORT"
echo "P4ROOT: $P4ROOT"
echo "P4JOURNAL: $P4JOURNAL"
echo "P4SSLDIR: $P4SSLDIR"
if [ $USE_SSL -eq 1 ]; then
  p4d -Gf
fi
echo
echo "######################   Server is ready to start   ######################"
echo

# Start the server
exec p4d
