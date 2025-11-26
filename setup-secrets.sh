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

# Path in Vault where secrets will be stored
VAULT_PATH="secret/data/keiba-batch"

echo "Vault Address: $VAULT_ADDR"
echo "Vault Path: $VAULT_PATH"

# Parse and sync database secrets
echo "Syncing database secrets..."
DB_USERNAME=$(jq -r '.["keiba-batch"].database.username' secrets.json)
DB_PASSWORD=$(jq -r '.["keiba-batch"].database.password' secrets.json)
DB_URL=$(jq -r '.["keiba-batch"].database.url' secrets.json)
DB_DRIVER=$(jq -r '.["keiba-batch"].database.driver' secrets.json)

vault kv put ${VAULT_PATH}/database \
    username="$DB_USERNAME" \
    password="$DB_PASSWORD" \
    url="$DB_URL" \
    driver="$DB_DRIVER"

echo "✓ Database secrets synced"

# Parse and sync API secrets
echo "Syncing API secrets..."
API_KEY=$(jq -r '.["keiba-batch"].api.apiKey' secrets.json)
API_SECRET=$(jq -r '.["keiba-batch"].api.apiSecret' secrets.json)
API_ENDPOINT=$(jq -r '.["keiba-batch"].api.endpoint' secrets.json)

vault kv put ${VAULT_PATH}/api \
    apiKey="$API_KEY" \
    apiSecret="$API_SECRET" \
    endpoint="$API_ENDPOINT"

echo "✓ API secrets synced"

# Parse and sync config
echo "Syncing configuration..."
ENVIRONMENT=$(jq -r '.["keiba-batch"].config.environment' secrets.json)
LOG_LEVEL=$(jq -r '.["keiba-batch"].config.logLevel' secrets.json)
BATCH_SIZE=$(jq -r '.["keiba-batch"].config.batchSize' secrets.json)
CRON_EXPRESSION=$(jq -r '.["keiba-batch"].config.cronExpression' secrets.json)

vault kv put ${VAULT_PATH}/config \
    environment="$ENVIRONMENT" \
    logLevel="$LOG_LEVEL" \
    batchSize="$BATCH_SIZE" \
    cronExpression="$CRON_EXPRESSION"

echo "✓ Configuration synced"

# Parse and sync service secrets
echo "Syncing Consul secrets..."
CONSUL_TOKEN=$(jq -r '.["keiba-batch"].services.consul.token' secrets.json)
CONSUL_HOST=$(jq -r '.["keiba-batch"].services.consul.host' secrets.json)
CONSUL_PORT=$(jq -r '.["keiba-batch"].services.consul.port' secrets.json)

vault kv put ${VAULT_PATH}/consul \
    token="$CONSUL_TOKEN" \
    host="$CONSUL_HOST" \
    port="$CONSUL_PORT"

echo "✓ Consul secrets synced"

echo "Syncing Redis secrets..."
REDIS_PASSWORD=$(jq -r '.["keiba-batch"].services.redis.password' secrets.json)
REDIS_HOST=$(jq -r '.["keiba-batch"].services.redis.host' secrets.json)
REDIS_PORT=$(jq -r '.["keiba-batch"].services.redis.port' secrets.json)

vault kv put ${VAULT_PATH}/redis \
    password="$REDIS_PASSWORD" \
    host="$REDIS_HOST" \
    port="$REDIS_PORT"

echo "✓ Redis secrets synced"

echo "Syncing RabbitMQ secrets..."
RABBITMQ_USERNAME=$(jq -r '.["keiba-batch"].services.rabbitmq.username' secrets.json)
RABBITMQ_PASSWORD=$(jq -r '.["keiba-batch"].services.rabbitmq.password' secrets.json)
RABBITMQ_HOST=$(jq -r '.["keiba-batch"].services.rabbitmq.host' secrets.json)
RABBITMQ_PORT=$(jq -r '.["keiba-batch"].services.rabbitmq.port' secrets.json)

vault kv put ${VAULT_PATH}/rabbitmq \
    username="$RABBITMQ_USERNAME" \
    password="$RABBITMQ_PASSWORD" \
    host="$RABBITMQ_HOST" \
    port="$RABBITMQ_PORT"

echo "✓ RabbitMQ secrets synced"

echo "=== All secrets synced successfully to Vault ==="
