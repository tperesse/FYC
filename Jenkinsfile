node {
    // Variables
    String credentialsId = 'awsCredentials'
    
    // Credential AWS
    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: credentialsId, accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {

    if (env.BRANCH_NAME == 'master') {
        stage('checkout') {
            cleanWs()
            checkout scm
        }

        // Run terraform init
        stage('init') {
                sh 'terraform init'
        }

        // Run terraform plan
        stage('plan') {
                sh 'terraform plan'
            }
        }
    }

        // // Run terraform apply
        // stage('apply') {
        //     withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: credentialsId, accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']])
        //     sh 'terraform apply -auto-approve'
        // }

        // // Run terraform show
        // stage('show') {
        //     withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: credentialsId, accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']])
        //     sh 'terraform show'
        // }
}