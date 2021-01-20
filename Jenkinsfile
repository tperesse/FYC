node {
    // Variables
    String credentialsId = 'awsCredentials'
    
    // Credential AWS
    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: credentialsId, accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
        stage('checkout') {
            cleanWs()
            checkout scm
        }

        // Run terraform init
        stage('init') {
            sh 'ls'
            sh 'terraform init'
        }

        // Run terraform plan
        stage('plan') {
            sh 'terraform plan'
        }
    }
}