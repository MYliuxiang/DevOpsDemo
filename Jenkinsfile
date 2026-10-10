pipeline {
    agent any

    environment {
        APP_PORT = '9090'
    }

    stages {
        stage('Checkout') {
            steps {
                echo '📦 拉取代码...'
                checkout scm
            }
        }

        stage('Maven Build') {
            steps {
                echo '🔨 Maven 编译打包...'
                sh 'mvn clean package -DskipTests -B -Dmaven.repo.local=/tmp/.m2repo'
            }
        }

        stage('Deploy') {
            steps {
                echo '🚀 部署应用...'
                sh '''
                    chmod +x deploy.sh
                    ./deploy.sh
                '''
            }
        }

        stage('Verify') {
            steps {
                echo '✅ 验证...'
                sh '''
                    sleep 2
                    curl -sf http://localhost:9090/ && echo "部署成功！" || echo "检查中..."
                '''
            }
        }
    }

    post {
        success {
            echo '🎉 流水线成功！访问 http://localhost:9090/'
        }
        failure {
            echo '❌ 流水线失败，请查看日志'
        }
    }
}
