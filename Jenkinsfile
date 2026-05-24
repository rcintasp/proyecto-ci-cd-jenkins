pipeline {
    agent any

    parameters {
        string(
            name: 'IMAGE_VERSION',
            defaultValue: 'latest',
            description: 'Versión de las imágenes Docker a construir y publicar'
        )
        string(
            name: 'DEPLOY_ENV',
            defaultValue: 'staging',
            description: 'Entorno de despliegue para el job posterior'
        )
        string(
            name: 'RUN_DEPLOY',
            defaultValue: 'false',
            description: 'Valor true para disparar el job de despliegue'
        )
    }

    environment {
        DOCKERHUB_USER = 'raulcintas'
        IMAGE_NAME = 'raulcintas/app-ci-cintaspaniagua'
        REPORT_FILE = 'reports/test-report.txt'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Static Analysis') {
            steps {
                sh '''
                    php -l src/functions.php
                    php -l src/index.php
                    php -l tests/test.php
                '''
            }
        }

        stage('Unit Tests') {
            steps {
                sh '''
                    mkdir -p reports
                    set +e
                    php tests/test.php > "${REPORT_FILE}" 2>&1
                    status=$?
                    echo "TEST_EXIT_CODE=$status" >> "${REPORT_FILE}"
                    exit $status
                '''
            }
        }

        stage('Generate Report') {
            steps {
                sh '''
                    echo "=== Reporte de pruebas ==="
                    cat "${REPORT_FILE}"
                '''
                archiveArtifacts artifacts: 'reports/test-report.txt', fingerprint: true
            }
        }

        stage('Build Docker PHP82') {
            steps {
                sh """
                    docker build -f Dockerfile.php82 -t ${IMAGE_NAME}:${IMAGE_VERSION}-php82 .
                """
            }
        }

        stage('Build Docker PHP83') {
            steps {
                sh """
                    docker build -f Dockerfile.php83 -t ${IMAGE_NAME}:${IMAGE_VERSION}-php83 .
                """
            }
        }

        stage('Docker Hub Login') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKERHUB_USER', passwordVariable: 'DOCKERHUB_PASS')]) {
                    sh '''
                        echo "$DOCKERHUB_PASS" | docker login -u "$DOCKERHUB_USER" --password-stdin
                    '''
                }
            }
        }

        stage('Push Images') {
            steps {
                sh """
                    docker push ${IMAGE_NAME}:${IMAGE_VERSION}-php82
                    docker push ${IMAGE_NAME}:${IMAGE_VERSION}-php83
                """
            }
        }

        stage('Trigger Deploy Job') {
            when {
                expression {
                    return params.RUN_DEPLOY.toBoolean()
                }
            }
            steps {
                build job: 'deploy-cintaspaniagua', parameters: [
                    string(name: 'IMAGE_VERSION', value: params.IMAGE_VERSION),
                    string(name: 'DEPLOY_ENV', value: params.DEPLOY_ENV)
                ]
            }
        }
    }
}
