#!/bin/bash

# Load environment variables
if [ -f "$(dirname "$0")/../docker-compose/.env" ]; then
    source "$(dirname "$0")/../docker-compose/.env"
else
    echo "ERROR: .env file not found"
    exit 1
fi

# Setup variables
SSL_DIR="$(dirname "$0")/../ssl"
DOMAIN=${DOMAIN_NAME:-keycloak.example.com}

# Create SSL directory if it doesn't exist
mkdir -p ${SSL_DIR}

echo "Generating self-signed SSL certificate for ${DOMAIN}..."

# Generate SSL certificate
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout ${SSL_DIR}/privkey.pem -out ${SSL_DIR}/fullchain.pem \
  -subj "/CN=${DOMAIN}" \
  -addext "subjectAltName=DNS:${DOMAIN},IP:${SERVER_IP:-127.0.0.1}"

# Check if certificate was created successfully
if [ $? -eq 0 ]; then
    echo "SSL certificate generated successfully:"
    echo "  - Private key: ${SSL_DIR}/privkey.pem"
    echo "  - Certificate: ${SSL_DIR}/fullchain.pem"
    echo "  - Validity: 365 days"
    echo "  - CN: ${DOMAIN}"
    echo "  - SAN: DNS:${DOMAIN}, IP:${SERVER_IP:-127.0.0.1}"
    
    # Set appropriate permissions
    chmod 600 ${SSL_DIR}/privkey.pem
    chmod 644 ${SSL_DIR}/fullchain.pem
    
    echo "Certificate permissions set."
else
    echo "ERROR: Failed to generate SSL certificate"
    exit 1
fi 