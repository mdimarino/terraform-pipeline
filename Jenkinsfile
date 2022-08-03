pipeline {

    agent {
        docker {
            image 'hashicorp/terraform:1.2.6'
            args  '--entrypoint="" -u root'
        }
    }

    options {
        ansiColor('xterm')
    }

    parameters {
        choice(
            choices: ['plan' , 'apply' , 'show', 'plan-destroy' , 'destroy'],
            description: 'Ação do Terraform a ser executada',
            name: 'action')

        string(name: 'AWS_ACCOUNT_ID', defaultValue: "123456789012", description: 'O ID da conta na AWS')
        string(name: 'AWS_REGION', defaultValue: "us-east-1", description: 'A região que será usada' )
        string(name: 'IAC_DIR', defaultValue: "dummy", description: 'Caminho dentro do diretório iac/ do repositório')
    }

    stages {

        stage('clone') {
            steps {
                cleanWs()
                git branch: 'main', url: 'https://github.com/mdimarino/terraform-pipeline.git'
            }
        }

        stage('init') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: "acg-aws-credential", accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                    dir('iac/${IAC_DIR}') {
                        sh 'terraform version'
                        sh 'terraform init -backend-config="bucket=${AWS_ACCOUNT_ID}-${AWS_REGION}-terraform-remote-backend-state" -backend-config="key=${IAC_DIR}/terraform.tfstate" -backend-config="region=${AWS_REGION}" -backend-config="dynamodb_table=${AWS_ACCOUNT_ID}-${AWS_REGION}-terraform-remote-backend-state"'
                    }
                }
            }
        }
        
        stage('validate') {
            when {
                expression { params.action == 'plan' || params.action == 'apply' || params.action == 'destroy' }
            }
            steps {
                dir('iac/${IAC_DIR}') {
                    sh 'terraform validate'
                }
            }
        }
        
        stage('plan') {
            when {
                expression { params.action == 'plan' }
            }
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: "acg-aws-credential", accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                    dir('iac/${IAC_DIR}') {
                        sh 'terraform plan'
                    }
                }
            }
        }
        
        stage('apply') {
            when {
                expression { params.action == 'apply' }
            }
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: "acg-aws-credential", accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                    dir('iac/${IAC_DIR}') {
                        sh 'terraform plan -out=plan'
                        sh 'terraform apply -auto-approve plan'
                    }
                }
            }
        }
        
        stage('show') {
            when {
                expression { params.action == 'show' }
            }
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: "acg-aws-credential", accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                    dir('iac/${IAC_DIR}') {
                        sh 'terraform show'
                    }
                }
            }
        }
        
        stage('plan-destroy') {
            when {
                expression { params.action == 'plan-destroy' }
            }
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: "acg-aws-credential", accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                    dir('iac/${IAC_DIR}') {
                        sh 'terraform plan -destroy'
                    }
                }
            }
        }
        
        stage('destroy') {
            when {
                expression { params.action == 'destroy' }
            }
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: "acg-aws-credential", accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                    dir('iac/${IAC_DIR}') {
                        sh 'terraform destroy -auto-approve'
                    }
                }
            }
        }
    }
}
