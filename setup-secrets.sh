#!/bin/bash

set -e  # Exit on error

echo "=== Starting Vault Secret Sync ==="

# Check if secrets.json exists
if [ ! -f "secrets.json" ]; then
    echo "Error: secrets.json not found"
    exit 1
fi

# Validate required environment variables
if [ -z "$VAULT_ADDR" ]; then
    echo "Error: VAULT_ADDR environment variable not set"
    exit 1
fi

if [ -z "$VAULT_TOKEN" ]; then
    echo "Error: VAULT_TOKEN environment variable not set"
    exit 1
fi

# Path in Vault where secrets will be stored as JSON
VAULT_PATH="secret/keiba-batch/secrets.json"

echo "Vault Address: $VAULT_ADDR"
echo "Vault Path: $VAULT_PATH"

# Read the entire secrets.json content and store it directly
echo "Reading secrets.json..."
echo "Syncing entire secrets.json to Vault..."

# Use jq to properly format and store the JSON structure
# This extracts the keiba-batch object and stores it as the value
vault kv put ${VAULT_PATH} - < secrets.json

echo "✓ Secrets synced successfully to Vault at: ${VAULT_PATH}"
echo ""
echo "To retrieve the secrets, use:"
echo "  vault kv get -format=json ${VAULT_PATH}"
echo ""
echo "=== All secrets synced successfully to Vault ==="
