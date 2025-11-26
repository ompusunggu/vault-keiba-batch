pipeline {
    agent {
        docker {
            image 'ubuntu:latest'
            args '-u root:root'
        }
    }

    environment {
        VAULT_ADDR = credentials('vault-addr')
        VAULT_TOKEN = credentials('vault-token')
    }

    triggers {
        pollSCM('H/5 * * * *')  // Poll SCM every 5 minutes
    }

    stages {
        stage('Checkout') {
            steps {
                echo '=== Checking out repository ==='
                checkout scm
            }
        }

        stage('Install Dependencies') {
            steps {
                echo '=== Installing dependencies ==='
                sh '''
                    apt-get update
                    apt-get install -y jq wget gnupg lsb-release curl ca-certificates apt-transport-https

                    # Install yq
                    wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
                    chmod +x /usr/local/bin/yq
                '''
            }
        }

        stage('Install Vault CLI') {
            steps {
                echo '=== Installing Vault CLI ==='
                sh '''
                    # Use curl instead of wget for better SSL handling
                    curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

                    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list

                    apt-get update
                    apt-get install -y vault
                '''
            }
        }

        stage('Verify Vault Connection') {
            steps {
                echo '=== Verifying Vault connectivity ==='
                sh '''
                    export VAULT_ADDR=${VAULT_ADDR}
                    export VAULT_TOKEN=${VAULT_TOKEN}
                    vault status
                '''
            }
        }

        stage('Sync Secrets to Vault') {
            steps {
                echo '=== Syncing secrets to Vault ==='
                sh '''
                    export VAULT_ADDR=${VAULT_ADDR}
                    export VAULT_TOKEN=${VAULT_TOKEN}

                    # Make script executable
                    chmod +x setup-secrets.sh

                    # Run setup script
                    ./setup-secrets.sh

                    echo "✓ Secrets synced successfully!"
                '''
            }
        }
    }

    post {
        success {
            echo '✓ Pipeline completed successfully!'
        }
        failure {
            echo '⚠️ Failed to sync secrets to Vault'
            echo 'Please check the Jenkins logs for details'
        }
        always {
            cleanWs()
        }
    }
}
