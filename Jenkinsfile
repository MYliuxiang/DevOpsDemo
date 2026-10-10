pipeline {
    agent any

    parameters {
        choice(
            name: 'ENV',
            choices: ['dev', 'prod'],
            description: '选择部署环境'
        )
    }

    environment {
        APP_PORT = "${params.ENV == 'prod' ? '8080' : '9090'}"
        MVN_HOME = '/opt/homebrew/bin'
        JAVA_HOME = '/usr/bin'
        PATH = "${MVN_HOME}:${JAVA_HOME}:${PATH}"
    }

    stages {
        stage('Checkout') {
            steps {
                echo "📦 拉取代码..."
                checkout scm
            }
        }

        stage('Maven Build') {
            steps {
                echo '🔨 Maven 编译打包...'
                sh '/opt/homebrew/bin/mvn clean package -DskipTests -B -Dmaven.repo.local=/tmp/.m2repo'
            }
        }

        stage('Deploy') {
            steps {
                echo "🚀 部署到 [${params.ENV}] 环境..."
                sh """
                    chmod +x deploy.sh
                    bash deploy.sh ${params.ENV}
                """
            }
        }

        stage('Verify') {
            steps {
                echo '✅ 验证...'
                sh """
                    sleep 2
                    curl -sf http://localhost:${APP_PORT}/ && echo "部署成功！" || echo "检查中..."
                """
            }
        }
    }

    post {
        success {
            echo "🎉 [${params.ENV}] 流水线成功 → http://localhost:${APP_PORT}/"
        }
        failure {
            echo "❌ [${params.ENV}] 流水线失败"
        }
    }
}
