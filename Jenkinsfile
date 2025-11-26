pipeline {
    agent {
        docker {
            image 'hashicorp/vault:latest'
            args '-u root:root --entrypoint='
        }
    }

    // Removed environment block - will use withCredentials instead

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
                echo '=== Installing minimal dependencies ==='
                sh '''
                    # Vault image uses Alpine, so use apk
                    apk add --no-cache jq bash git
                '''
            }
        }

        stage('Verify Vault Connection') {
            steps {
                echo '=== Verifying Vault connectivity ==='
                sh '''
                    # TEMPORARY: Hardcoded values for testing
                    export VAULT_ADDR="http://host.docker.internal:8200"
                    export VAULT_TOKEN="hvs.Cjl0zssqsbcUW6aL2mC09V1O"

                    echo "Connecting to Vault at: $VAULT_ADDR"
                    vault status
                '''
            }
        }

        stage('Sync Secrets to Vault') {
            steps {
                echo '=== Syncing secrets to Vault ==='
                sh '''
                    # TEMPORARY: Hardcoded values for testing
                    export VAULT_ADDR="http://host.docker.internal:8200"
                    export VAULT_TOKEN="hvs.Cjl0zssqsbcUW6aL2mC09V1O"

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
