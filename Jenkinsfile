pipeline {
    agent any

    parameters {
        choice(
            name: 'ENV',
            choices: ['dev', 'prod'],
            description: '选择部署环境'
        )
        choice(
            name: 'TARGET',
            choices: ['local', 'remote'],
            description: '部署到本地还是远程'
        )
        string(
            name: 'REMOTE_HOST',
            defaultValue: 'root@你的服务器IP',
            description: '远程服务器地址 (例: root@192.168.1.100)'
        )
        string(
            name: 'REMOTE_PATH',
            defaultValue: '/opt/welcome-liuxiang',
            description: '远程部署路径'
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
                echo "🐳 部署到 [${params.TARGET}] → [${params.ENV}]"

                script {
                    def serviceName = params.ENV == 'dev' ? 'welcome-app-dev' : 'welcome-app-prod'

                    if (params.TARGET == 'local') {
                        // ===== 本地部署 =====
                        sh """
                            docker compose --project-name welcome-liuxiang stop ${serviceName} 2>/dev/null || true
                            docker compose --project-name welcome-liuxiang rm -f ${serviceName} 2>/dev/null || true
                            sleep 2
                            docker compose --project-name welcome-liuxiang up -d --build ${serviceName}
                        """
                    } else {
                        // ===== 远程部署 =====
                        sh """
                            # 1. 传输 jar + Dockerfile + docker-compose.yml 到远程
                            ssh ${params.REMOTE_HOST} "mkdir -p ${params.REMOTE_PATH}"
                            scp target/demo-0.0.1-SNAPSHOT.jar ${params.REMOTE_HOST}:${params.REMOTE_PATH}/
                            scp Dockerfile ${params.REMOTE_HOST}:${params.REMOTE_PATH}/
                            scp docker-compose.yml ${params.REMOTE_HOST}:${params.REMOTE_PATH}/

                            # 2. 远程构建并启动
                            ssh ${params.REMOTE_HOST} "
                                cd ${params.REMOTE_PATH} &&
                                docker compose --project-name welcome-liuxiang stop ${serviceName} 2>/dev/null || true &&
                                docker compose --project-name welcome-liuxiang rm -f ${serviceName} 2>/dev/null || true &&
                                sleep 2 &&
                                docker compose --project-name welcome-liuxiang up -d --build ${serviceName}
                            "

                            echo "🌐 远程地址: http://${params.REMOTE_HOST#*@}:${APP_PORT}/"
                        """
                    }
                }
            }
        }

        stage('Verify') {
            steps {
                echo '✅ 验证...'
                script {
                    if (params.TARGET == 'local') {
                        sh "sleep 3 && curl -sf http://localhost:${APP_PORT}/ && echo 'OK'"
                    } else {
                        def remoteIP = params.REMOTE_HOST.split('@').last()
                        sh "ssh ${params.REMOTE_HOST} 'sleep 3 && curl -sf http://localhost:${APP_PORT}/ && echo OK'"
                    }
                }
            }
        }
    }

    post {
        success {
            script {
                if (params.TARGET == 'local') {
                    echo "🎉 [${params.ENV}] 本地部署成功 → http://localhost:${APP_PORT}/"
                } else {
                    def remoteIP = params.REMOTE_HOST.split('@').last()
                    echo "🎉 [${params.ENV}] 远程部署成功 → http://${remoteIP}:${APP_PORT}/"
                }
            }
        }
        failure {
            echo "❌ [${params.ENV}] 部署失败"
        }
    }
}
