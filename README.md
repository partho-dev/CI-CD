# CI-CD

# Continous Integration & Continuous Delivery or Deployment 

[] Jenkins would be used for CI/CD
[] For GitOps - Deployment of containers on K8S we will use Jenkins for only `CI` part and we will use K8S Custom Controller for `CD` part

* Jenkins need a seperate server to be installed, so we would use AWS `Ec2` to install Jenkins and other plugins which would perform differet stages in the `CI` 
* For Jenkins agent we will try to use Docker or the same server of Jenkins to perform some stages

