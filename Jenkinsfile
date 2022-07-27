pipeline {

    agent {
        docker {
            image 'hashicorp/terraform:1.2.5'
            args  '--entrypoint="" -u root'
        }
    }

    environment {
        AWS_DEFAULT_REGION="us-east-1"
    }

    parameters {
        choice(
            choices: ['plan' , 'apply' , 'show', 'plan-destroy' , 'destroy'],
            description: 'Ação do Terraform a ser executada',
            name: 'action')

        string(defaultValue: "default", description: 'Which AWS Account (Boto profile) do you want to target?', name: 'AWS_PROFILE')
        string(defaultValue: "iac/terraform-remote-backend-state-us-east-1", description: 'Caminho dentro do diretório iac/', name: 'IAC_PATH')
    }

    stages {

        stage('clone') {
            steps {
                git branch: 'main', url: 'https://github.com/mdimarino/terraform-pipeline.git'
            }
        }

        stage('init') {
            steps {
                withCredentials([aws(credentialsId: 'acg-aws-credential', accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    dir('iac/terraform-remote-backend-state-us-east-1') {
                        sh 'terraform version'
                        sh 'terraform init -no-color'
                    }
                }
            }
        }
        
        stage('validate') {
            when {
                expression { params.action == 'plan' || params.action == 'apply' || params.action == 'destroy' }
            }
            steps {
                
                withCredentials([aws(credentialsId: 'acg-aws-credential', accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    dir('iac/terraform-remote-backend-state-us-east-1') {
                        sh 'terraform validate -no-color'
                    }
                }
            }
        }
        
        stage('plan') {
            when {
                expression { params.action == 'plan' }
            }
            steps {
                withCredentials([aws(credentialsId: 'acg-aws-credential', accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    dir('iac/terraform-remote-backend-state-us-east-1') {
                        sh 'terraform plan -no-color'
                    }
                }
            }
        }
        
        stage('apply') {
            when {
                expression { params.action == 'apply' }
            }
            steps {
                echo 'terraform plan -out=plan -var aws_profile=${AWS_PROFILE}'
                echo 'terraform apply -auto-approve -no-color plan'
            }
        }
        
        stage('show') {
            when {
                expression { params.action == 'show' }
            }
            steps {
                echo 'terraform show -no-color'
            }
        }
        
        stage('plan-destroy') {
            when {
                expression { params.action == 'plan-destroy' }
            }
            steps {
                echo 'terraform plan -destroy -no-color'
            }
        }
        
        stage('destroy') {
            when {
                expression { params.action == 'destroy' }
            }
            steps {
                echo 'terraform destroy -auto-approve -no-color'
            }
        }
    }
}
