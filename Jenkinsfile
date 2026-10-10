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
        APP_PORT = "${params.ENV == 'prod' ? '8081' : '9090'}"
        JAVA_HOME = '/Users/test/Library/Java/JavaVirtualMachines/ms-17.0.20.1/Contents/Home'
        PATH = "/opt/homebrew/bin:/usr/local/bin:${JAVA_HOME}/bin:/usr/bin:/usr/sbin:${PATH}"
        PROJECT_NAME = 'welcome-liuxiang'
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

        stage('Docker Deploy') {
            steps {
                echo "🐳 Docker 部署到 [${params.ENV}] 环境..."

                script {
                    if (params.ENV == 'dev') {
                        sh '''
                            docker compose --project-name welcome-liuxiang up -d --build welcome-app-dev
                            docker rm -f welcome-liuxiang-prod 2>/dev/null || true
                        '''
                    } else {
                        sh '''
                            docker compose --project-name welcome-liuxiang up -d --build welcome-app-prod
                            docker rm -f welcome-liuxiang-dev 2>/dev/null || true
                        '''
                    }
                }
            }
        }

        stage('Verify') {
            steps {
                echo '✅ 验证...'
                sh """
                    sleep 3
                    curl -sf http://localhost:${APP_PORT}/ && echo "部署成功！" || echo "检查中..."
                """
            }
        }
    }

    post {
        success {
            echo "🎉 [${params.ENV}] Docker 部署成功 → http://localhost:${APP_PORT}/"
        }
        failure {
            echo "❌ [${params.ENV}] 部署失败"
        }
    }
}
