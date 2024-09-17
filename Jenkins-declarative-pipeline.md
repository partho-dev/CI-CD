## The mighty declarative pipeline
- It has few blocks and combining each block in a file written with certain guidelines is called Jenkins file

### Few commonly used blocks are
* `pipeline`: Defines the entire pipeline.
* `agent`: Specifies where the pipeline or stage will run.
* `stages`: Contains multiple stages (e.g., Build, Test, Deploy).
* `stage`: Represents a specific phase in the pipeline.
* `steps`: Actual actions or commands to be executed.
* `post`: Actions that run after a stage or the pipeline completes.
* `environment`: Defines environment variables.
* `options`: Controls behavior (e.g., timeouts, retries).
* `when`: Defines conditions to run a stage.
* `input`: Allows manual approval before proceeding.
* `parallel`: Runs multiple tasks in parallel.
* `triggers`: Specifies automatic build triggers.
* `tools`: Specifies required tools.
* `parameters`: Allows user input for pipeline execution.
* `libraries`: Loads shared libraries.
* `script`: Allows for custom Groovy scripting.

- 1. ***Pipleline block ***
```
pipeline {
    agent any
    stages {
        // Stages and steps go here
    }
}
```

- 2. ***Agent Block ***
    - `any`: Runs on any available agent.
    - `none`: No default agent; typically used when each stage specifies its own agent.
    - `label`: Runs on a node with a specific label.
    - `docker`: Runs inside a Docker container.
```
pipeline {
    agent any
}
```
or 
```
pipeline {
    agent {
        docker {
            image 'node:14-alpine'
            label 'my-docker-agent'
        }
    }
}

```

- 3.*** stages Block***
```
pipeline {
    stages {
        stage('Build') {
            steps {
                echo 'Building the application...'
            }
        }
        stage('Test') {
            steps {
                echo 'Testing the application...'
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploying the application...'
            }
        }
    }
}
```

- 4. ***stage Block***
```
stage('Build') {
    steps {
        echo 'Building...'
    }
}


```

- 5. ***steps Block***

- Defines the actual tasks or actions that the pipeline will execute within a stage. 
- These are typically shell commands or script execution. 
- The `steps block is mandatory` within a stage.

```
steps {
    echo 'Compiling code...'
    sh 'mvn clean install'
}
```

**Common steps:**

- `echo`: Prints messages to the console output.
- `sh`: Executes shell commands (on Linux/Mac agents).
- `bat`: Executes batch commands (on Windows agents).
- `script`: Allows using Groovy scripting inside declarative pipelines.

6. ***post Block***

- Defines actions to be taken after the pipeline or a stage finishes. 
- This block is useful for cleanup or notifications. 
- You can specify actions based on the build result (e.g., success, failure).

```
post {
    always {
        echo 'Cleaning up...'
    }
    success {
        echo 'Build succeeded!'
    }
    failure {
        echo 'Build failed.'
    }
}
```

7. ***environment Block***

- Defines `environment variables` that can be used throughout the pipeline. 
- These variables can be global (available to all stages) or local (specific to a stage).
```
environment {
    APP_ENV = 'staging'
    DOCKER_REGISTRY = 'my-docker-registry'
}
```

- access these variables within the pipeline using `${env.VARIABLE_NAME}`.

8. ***options Block***

- Specifies various options to control the behavior of the pipeline. 
- These include timeouts, retry policies, and build discarding policies.

```
options {
    timeout(time: 10, unit: 'MINUTES')
    buildDiscarder(logRotator(numToKeepStr: '5'))
}
```

9. ***when Block***

- Defines conditions to control whether a stage should run. 
- You can base conditions on branch names, environment variables, or the pipeline result.

```
stage('Deploy') {
    when {
        branch 'master'
    }
    steps {
        echo 'Deploying to production...'
    }
}
```

- **Common conditions:**
- `branch`: Runs the stage only on a specific Git branch.
- `expression`: Runs the stage if a given expression evaluates to true.
- `environment`: Runs the stage if an environment variable matches a value.

10. ***input Block***

- Allows for manual approval or input before proceeding to the next stage. 
- Useful for processes where human intervention is required (e.g., approvals for production deployments).

```
stage('Deploy') {
    input {
        message 'Approve Deployment to Production?'
        ok 'Deploy'
    }
    steps {
        echo 'Deploying to production...'
    }
}
```

11. ***parallel Block***

- Defines parallel execution of multiple stages or tasks. 
- This is useful for running different test suites or builds concurrently.

```
stage('Test') {
    parallel {
        stage('Unit Tests') {
            steps {
                sh 'npm run test:unit'
            }
        }
        stage('Integration Tests') {
            steps {
                sh 'npm run test:integration'
            }
        }
    }
}
```

12. ***triggers Block***

- Specifies conditions under which the pipeline should be automatically triggered, like polling a Git repository or setting up a cron job.

```
triggers {
    pollSCM('H/5 * * * *')  // Poll the source control every 5 minutes
}
```

13. ***tools Block***

- Specifies the tools (like JDK, Maven, NodeJS) that should be available for use in the pipeline. 
- Jenkins will automatically install these tools if not already installed.

```
tools {
    maven 'Maven 3.6.3'
    jdk 'JDK 11'
}
```

14. ***parameters Block***

- Defines parameters that allow users to pass inputs to the pipeline when triggering a build. 
- use string parameters, boolean flags, choices, etc.

```
parameters {
    string(name: 'BRANCH_NAME', defaultValue: 'master', description: 'Which branch to build')
    booleanParam(name: 'RUN_TESTS', defaultValue: true, description: 'Run unit tests')
}
```

15. ***libraries Block***

- If you have shared libraries in Jenkins, this block allows you to load and use them in your pipeline.

```
@Library('my-shared-library') _
```

16. ***script Block***

- Allows the use of full Groovy scripting inside a declarative pipeline. 
- Useful for more advanced logic that cannot be easily expressed with declarative syntax.
```
script {
    def buildStatus = currentBuild.currentResult
    if (buildStatus == 'SUCCESS') {
        echo 'Build succeeded!'
    } else {
        echo 'Build failed!'
    }
}
```

`==================================================================================`

## What Can Be Done Inside the script Block?

- Inside the script block, you have access to Groovy's full programming power, 
- Jenkins' scripted pipeline features, and various utilities for performing complex operations.

### Here’s a list of commonly used actions inside the script block:

1. **Running Shell Commands (sh)**

- Use sh to run shell commands inside the pipeline. 
- This is commonly used to execute build commands, test scripts, and other tasks.
```
    script {
        sh 'npm install'
        sh 'npm run build'
    }
```

2. **Conditional Logic (if/else)**

- Groovy allows for regular if/else statements, which are commonly used in pipelines to handle conditions based on the environment, build status, etc.
```
    script {
        if (env.BRANCH_NAME == 'main') {
            sh 'npm run deploy'
        } else {
            sh 'npm run test'
        }
    }
```

3. **Defining Variables (def)**

- As mentioned, you can define variables to store data for later use.
```
    script {
        def appName = 'my-app'
        sh "echo Building ${appName}"
    }
```

4. **Looping (for, while)**

- You can loop through data such as lists or ranges using Groovy’s for and while loops.
```
    script {
        for (int i = 0; i < 5; i++) {
            sh "echo Iteration ${i}"
        }
    }
```

5. **Handling Exceptions (try/catch)**

- Exception handling is important for catching errors and preventing pipeline failure.
```
    script {
        try {
            sh 'npm run risky-command'
        } catch (Exception e) {
            echo "Command failed: ${e.message}"
        }
    }
```

6. **Docker Operations (docker methods)**

- Jenkins pipelines have built-in Docker capabilities, 
- so you can use methods like `docker.build()`, `docker.image()`, `docker.withRegistry()`, and more.
```
    script {
        def app = docker.build("my-app:${env.BUILD_ID}")
        docker.withRegistry('https://registry.example.com', 'my-credentials-id') {
            app.push('latest')
            app.push("${env.BUILD_ID}")
        }
    }
```

7. **File Operations (e.g., readFile, writeFile)**

- You can read from and write to files within the workspace.
```
    script {
        def version = readFile('version.txt').trim()
        writeFile file: 'output.txt', text: "Version is ${version}"
    }
```

8. **Working with Environment Variables (env)**

- Jenkins exposes environment variables that you can access and manipulate.
```
    script {
        def buildNumber = env.BUILD_ID
        echo "The current build number is ${buildNumber}"
    }
```

9. **Custom Groovy Functions**

- You can define and call custom functions within the script block.
```
    script {
        def sayHello(name) {
            echo "Hello, ${name}!"
        }
        sayHello('Partho')
    }
```

10. **Git Operations**

- You can perform Git operations inside the script block.
```
    script {
        def gitCommit = sh(returnStdout: true, script: 'git rev-parse HEAD').trim()
        echo "Current Git Commit: ${gitCommit}"
    }
```

11. **Build, Archive, and Test**

- You can invoke other Jenkins features like archiving artifacts, junit reports, etc.
```
    script {
        archiveArtifacts artifacts: '**/target/*.jar'
        junit '**/target/surefire-reports/*.xml'
    }
```

12. **Parallel Execution**

- You can trigger multiple tasks in parallel.
```
    script {
        parallel firstTask: {
            echo "Running first task"
        }, secondTask: {
            echo "Running second task"
        }
    }
```

### Common Patterns in Industry:

- `Docker-Based Pipelines`: Using docker.build(), docker.withRegistry(), and docker.image() to build and push Docker images, especially for microservices.

- `Automated Tests`: Running unit tests, integration tests, and end-to-end tests within the script block using sh to call the appropriate test commands.

- `Conditional Deployments`: Only deploying applications if certain conditions are met, such as deploying only when code is merged into the main branch.

- `Exception Handling`: Ensuring the pipeline doesn't fail immediately if an error occurs by using try/catch.


`==================================================================`

## What is Parameterization in Jenkins?

- Parameterization in Jenkins refers to the ability to pass values dynamically into Jenkins pipeline. 
- It allows to customize the behavior of Jenkins jobs based on input provided at the time of job execution. - This makes  pipelines flexible, reusable, and easier to maintain across different environments, projects, or scenarios.

- By defining parameters, you can avoid hardcoding values like `environment names`, `image tags`, or other important variables, enabling the same Jenkins pipeline to be used for multiple environments (e.g., dev, staging, production) or different configurations (e.g., different applications).

### Common Use Cases for Parameterization

1. **Environment-Specific Configurations**

- `Use Case`: 
- multiple environments like development, staging, and production. 
- With parameterization, specify which environment the pipeline should target.

- Example: In a Terraform deployment pipeline, you can pass the target environment as a parameter, so the pipeline knows whether to apply the Terraform scripts to dev, stage, or prod environments.

2. **Dynamic Versioning/Tags**

    Use Case: When building Docker images or deploying an application, you may want to specify the image tag/version dynamically at runtime.
    Example: You can pass a Docker image version (v1.0.0, v1.0.1) or Git branch name (main, feature-xyz) as a parameter to deploy different versions of the application.

3. Control Build and Deployment Behavior

    Use Case: Sometimes you might want to control whether certain steps (like tests, deployments, etc.) should be executed.
    Example: You could have a parameter RUN_TESTS that allows the user to decide whether or not to run unit tests in the pipeline. This is useful for optimizing build times.

4. Terraform Resource Selection

    Use Case: In an infrastructure pipeline, you can parameterize which part of the infrastructure to create, update, or destroy.
    Example: For a Terraform deployment pipeline, you could pass parameters like action (apply, plan, or destroy) or region (us-east-1, eu-west-1) to specify where and what should be done in the pipeline.

5. Feature Toggles for Application Deployment

    Use Case: You can enable or disable certain features or components of your application during the deployment process.
    Example: A feature flag can be passed as a parameter to enable or disable experimental features in your application during a deployment to different environments.

How to Use Parameters in Jenkins?

Jenkins supports different types of parameters. The most commonly used ones are:

    String Parameter: Allows users to input text.
    Choice Parameter: Presents a list of options to select from.
    Boolean Parameter: A simple checkbox (true/false).
    Credentials Parameter: Allows selection of stored credentials.
    File Parameter: Lets users upload files to the job.

These parameters can be defined either in the Jenkins UI or directly in the Jenkinsfile.
Parameterizing a Jenkins Pipeline

Here’s how you can define and use parameters in a Jenkinsfile:

groovy

pipeline {
    agent any
    parameters {
        string(name: 'ENV', defaultValue: 'dev', description: 'Environment to deploy (dev, staging, prod)')
        choice(name: 'ACTION', choices: ['apply', 'plan', 'destroy'], description: 'Terraform action to perform')
        string(name: 'IMAGE_TAG', defaultValue: 'latest', description: 'Docker image tag')
        booleanParam(name: 'RUN_TESTS', defaultValue: true, description: 'Run unit tests')
    }
    stages {
        stage('Terraform Init') {
            steps {
                script {
                    echo "Initializing Terraform for environment: ${params.ENV}"
                    sh "terraform init -backend-config=${params.ENV}.backend"
                }
            }
        }
        stage('Terraform Plan/Apply') {
            steps {
                script {
                    if (params.ACTION == 'apply') {
                        sh "terraform apply -var environment=${params.ENV} -auto-approve"
                    } else if (params.ACTION == 'plan') {
                        sh "terraform plan -var environment=${params.ENV}"
                    } else if (params.ACTION == 'destroy') {
                        sh "terraform destroy -var environment=${params.ENV} -auto-approve"
                    }
                }
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    echo "Building Docker image with tag: ${params.IMAGE_TAG}"
                    sh "docker build -t my-app:${params.IMAGE_TAG} ."
                }
            }
        }
        stage('Run Tests') {
            when {
                expression { params.RUN_TESTS == true }
            }
            steps {
                script {
                    echo "Running unit tests"
                    sh "npm test"
                }
            }
        }
    }
}

Explanation:

    Environment Parameter (ENV): Allows you to specify which environment (dev, staging, or prod) to run the pipeline for. This is useful in both application and infrastructure pipelines.
    Action Parameter (ACTION): Controls what Terraform action to perform (apply, plan, or destroy), so you don't need multiple pipelines for different actions.
    Image Tag Parameter (IMAGE_TAG): Dynamically controls the tag/version of the Docker image you want to build and push.
    Boolean Parameter (RUN_TESTS): Provides a toggle to either run or skip tests.

Industry Examples

    Terraform-Based Infrastructure as Code (IaC)
        When using Terraform, parameterizing your pipeline allows the same Jenkinsfile to be reused across multiple environments. You can pass ENV to target different cloud environments and ACTION to control what Terraform action to perform.
        Example: In a cloud infrastructure deployment, you might have different parameters for region, cloud provider, and resource tags. This enables you to manage infrastructure across regions and environments easily.

    Multi-Environment Application Deployment
        Many companies need to deploy applications to multiple environments (e.g., dev, staging, production). By parameterizing the environment, Jenkins can deploy the same codebase to different environments without having separate pipelines for each environment.
        Example: A CI/CD pipeline for a microservice that builds Docker images and deploys to Kubernetes clusters. The environment (dev, stage, prod) can be parameterized so that the same pipeline is used across all environments, with different configurations or versions.

    Multi-Version Docker Builds
        When deploying containerized applications, you can pass the IMAGE_TAG as a parameter, which allows Jenkins to build and push specific image versions dynamically. This is crucial when deploying multiple versions of the same application.
        Example: Tagging images with specific Git commit hashes or version numbers allows you to track deployments and perform rollbacks if necessary.

    Controlled Rollouts
        You might want to parameterize the deployment to control things like canary releases, blue-green deployments, or feature flags.
        Example: By passing a parameter such as DEPLOY_TYPE with options like canary, blue-green, or full, you can control the deployment strategy in the pipeline itself.

Using Parameters in Terraform Pipelines

In Terraform-based infrastructure deployments, parameters are extremely useful:

    Region Parameter: Pass a region to Terraform, so the pipeline can deploy resources to different cloud regions.
    Workspace Parameter: Use Terraform workspaces to manage multiple environments like dev, stage, and prod within the same codebase.

groovy

parameters {
    choice(name: 'TERRAFORM_WORKSPACE', choices: ['dev', 'stage', 'prod'], description: 'Terraform workspace to deploy')
}

stage('Terraform Workspace') {
    steps {
        script {
            sh "terraform workspace select ${params.TERRAFORM_WORKSPACE}"
        }
    }
}

Summary

Parameterizing your Jenkins pipeline provides flexibility, reusability, and scalability. You can pass values like environment names, Docker tags, Terraform actions, and feature flags dynamically at runtime. It’s commonly used in the industry for:

    Handling multi-environment deployments (dev, staging, prod)
    Dynamic application versioning
    Infrastructure as Code (Terraform) deployments
    Controlling pipeline behavior based on user input