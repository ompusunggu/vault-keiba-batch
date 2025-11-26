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
                script {
                    withCredentials([string(credentialsId: 'vault-addr', variable: 'VAULT_ADDR'),
                                                     string(credentialsId: 'vault-token', variable: 'VAULT_TOKEN')]) {

                        echo '=== Verifying Vault connectivity ==='
                        sh '''
                            echo "Connecting to Vault at: $VAULT_ADDR"
                            vault status
                        '''
                    }
                }
            }
        }

        stage('Sync Secrets to Vault') {
            steps {

                withCredentials([string(credentialsId: 'vault-addr', variable: 'VAULT_ADDR'),
                                 string(credentialsId: 'vault-token', variable: 'VAULT_TOKEN')]) {

                                        echo '=== Syncing secrets to Vault ==='
                                                        sh '''

                                                            # Make script executable
                                                            chmod +x setup-secrets.sh

                                                            # Run setup script
                                                            ./setup-secrets.sh

                                                            echo "✓ Secrets synced successfully!"
                                                        '''
                                    }

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
