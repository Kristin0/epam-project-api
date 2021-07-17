pipeline {
    agent none
    environment { AWS_ACCESS_KEYS = credentials('ssh-aws-keys') } 
    
    stages {
        
        stage ('Build and Package'){
            agent { label 'ec2-aws' }
            tools {
                maven 'maven-3.8.1'
                jdk 'openjdk13'
            }
      
      
             stages {
                stage('Git checkout') {
                    steps {
                        git branch: 'main', credentialsId: 'github-token', url: 'https://github.com/Kristin0/api-gateway.git'
                    }
                }
                stage('Build artifact'){
                    steps {
                        sh 'mvn versions:set -DnewVersion=${BUILD_NUMBER}'
                        sh 'mvn clean package'
                    }
                }
                stage('Package to repo'){
                    steps{
                        configFileProvider([configFile(fileId: '913b3dcf-49e8-47a7-a026-3e42bf2ee783', targetLocation: 'settings.xml', variable: 'MVN_SETTINGS')]) {
                          sh 'mvn -s $MVN_SETTINGS deploy'
                        }   
                        
                    }
                }
            }
        }
        
     
        stage('Deployin from Terraform and Ansible'){
            agent { label 'ec2-aws' }
            tools {
                terraform 'terraform'
                jdk 'openjdk13'
            }
            
            
            
            stages {
                stage('Git checkout') {
                    steps {
                        git branch: 'main', credentialsId: 'github-token', url: 'https://github.com/Kristin0/epam-project-api.git'
                    }
                }
                stage('Terraform'){
                    steps{
                        withCredentials([string(credentialsId: 'token_only', variable: 'TOKEN')]) {
                        sh "wget https://Kristin0:$TOKEN@maven.pkg.github.com/Kristin0/api-gateway/ru/mudigal/api-gateway/${BUILD_NUMBER}/api-gateway-${BUILD_NUMBER}.jar -O artifact.jar"
                        }
                        sh 'terraform init'
                        sh 'terraform apply --auto-approve'
                    }
                }
                stage('Ansible'){
                    steps{
                        ansiblePlaybook colorized: true, credentialsId: 'a4l.pem', disableHostKeyChecking: true, installation: 'ansible', inventory: 'inventory_aws_ec2.yml', playbook: 'main.yml', vaultCredentialsId: '4ae90820-7767-4e1a-a163-eae6326a2150'
                    }
                }
                
                
            }
        
        }
    }
}
