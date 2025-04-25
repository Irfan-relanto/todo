pipeline {
    agent any

    environment {
        GIT_REPO = 'https://github.com/Irfan-relanto/todo.git'  // Set your Git repo URL
        BRANCH = 'main'  // Set the branch to clone (e.g., 'main' or 'master')
        TARGET_DIR = 'images'  // Specify the directory where the repo will be cloned
        DOCKER_IMAGE_NAME = 'todoapp9999'  // Docker image name (can be customized)
        DOCKER_TAG = 'latest'  // Tag for the Docker image
        NEW_DOCKER_TAG = 'us-central1-docker.pkg.dev/my-gke-456113/todoapp9/todoapp9999:latest'  // New tag for the Docker image
        GCR_REGION = 'us-central1'  // GCR region
    }

    stages {
        // Stage 1: Clone the Git repository
        stage('Clone Repository') {
            steps {
                script {
                    // Create the target directory if it doesn't exist
                    sh 'mkdir -p ${TARGET_DIR}'
                    
                    // Clone the repository into the specified directory
                    dir("${TARGET_DIR}") {
                        git branch: "${BRANCH}", url: "${GIT_REPO}"
                    }
                }
            }
        }

        // Stage 2: Build Docker Image
        stage('Build Docker Image') {
            steps {
                script {
                    // Change directory to where the Dockerfile exists
                    dir("${TARGET_DIR}") {
                        // Build the Docker image using the Dockerfile in the directory
                        sh "docker build -t ${DOCKER_IMAGE_NAME}:${DOCKER_TAG} ."
                    }
                }
            }
        }

        // Stage 3: Tag Docker Image
        stage('Tag Docker Image') {
            steps {
                script {
                    // Tag the Docker image with the new tag
                    sh "docker tag ${DOCKER_IMAGE_NAME}:${DOCKER_TAG} ${NEW_DOCKER_TAG}"
                }
            }
        }

        // Stage 4: Authenticate Docker with Google Cloud
        stage('Authenticate with GCR') {
            steps {
                script {
                    // Authenticate Docker to use GCR
                    sh 'gcloud auth configure-docker us-central1-docker.pkg.dev'
                }
            }
        }

        // Stage 5: Push Docker Image to GCR
        stage('Push Docker Image to GCR') {
            steps {
                script {
                    // Push the tagged image to the Google Container Registry
                    sh "docker push ${NEW_DOCKER_TAG}"
                }
            }
        }

        // Stage 6: Run Docker Container
    }

    post {
        always {
            echo "Pipeline completed!"
        }

        success {
            echo "Pipeline completed successfully!"
        }

        failure {
            echo "Pipeline failed. Please check the logs."
        }
    }
}
