## Backup and DR plan for all the DevOps tools on EKS

- When dealing with disaster recovery (DR) for critical tools such as Jenkins, Nexus, and SonarQube running on an EKS cluster,
- backups of configurations and persistent data is critical to avoid losing settings, configurations, and historical data during a failure. 
- Here are the key steps and best practices to safeguard the infrastructure:
- **Key DR Considerations for the DevOps Tools:**

- 1. ***Persistent Data Backup (Volumes/Databases)***:
    - For tools like Jenkins, SonarQube, and Nexus, data is usually stored in persistent volumes. 
    - It's crucial to ensure that this data is backed up regularly.

- 2. ***Cluster Configurations Backup (Manifests/Deployments)***:
    - back up Kubernetes resources such as Deployments, Services, ConfigMaps, Secrets, and Ingresses so that the environment can be restored in case of a region failure or a cluster outage.

- 3. ***Cross-Region DR Plan***:
        For ultimate redundancy, ensure your infrastructure is spread across regions to avoid an entire region outage affecting your DevOps pipeline.

### Recommended DR Strategy & Backup for EKS-Based DevOps Tools
- 1. Persistent Volumes Backup:

- Use AWS EBS Snapshots if using EBS-backed persistent volumes. 
- automate the process with scheduled snapshots using AWS Lambda or tools like `Velero` (discussed below).

- For each persistent volume (e.g., /var/jenkins_home for Jenkins), create EBS snapshots regularly.
- `Velero` is one of the best tools for this and works well with Kubernetes and cloud-based volumes (EBS, GCP, Azure Disks). It can also back up PVs along with Kubernetes objects.

- 2. Namespace Backup (Including Deployments/Configs/Secrets):

- For Kubernetes resources (like your deployments, config maps, secrets, etc.), use `Velero`, which is a tool specifically designed for `Kubernetes cluster backups`.

### Velero allows to:

- Backup entire namespaces, including resources like deployments, secrets, and services.
- Schedule regular backups.
- Restore the namespace to a new cluster or region if a failure occurs.

### Install Velero on EKS:

- Velero consists of two parts:

- `Velero CLI`: Installed on your local machine (e.g., your Mac).
- `Velero Server`: Installed inside your EKS cluster as a set of pods and Kubernetes resources (deployments, CRDs). It runs in your worker nodes (not on the EKS master/control plane since that is managed by AWS).
- Like `kubectl` reads the `kubeconfig` and finds the info about the EKS or K8s. similarly `Velero` uses the same config file to connect with the right EKS cluster

- install `Velero` and configure it with the AWS credentials to take regular backups.
- Just like we have `kubectl` installed on mac to interact with the EKS cluster,
- we also need the `Velero CLI` installed on mac to interact with the Velero `server component` in the Kubernetes cluster.

- Add Velero CLI on Local - `brew install velero`

# Install Velero on the EKS cluster

```
velero install \
--provider aws \
--plugins velero/velero-plugin-for-aws:v1.2.0 \
--bucket <backup-bucket-name> \
--backup-location-config region=<your-aws-region>,s3ForcePathStyle="true",s3Url=https://s3.<region>.amazonaws.com \
--snapshot-location-config region=<your-aws-region> \
--use-volume-snapshots=true \
--secret-file=<path-to-credentials-aws>
```

- Remember - `velero` is installed on the worker nodes, not on control plane
- It is installed as a container like other containers

- Back Up the Namespace: `velero backup create devops-tools-backup --include-namespaces devops-tools`
- Restore the Namespace: `velero restore create --from-backup devops-tools-backup`

### 3. Automated Backup Schedule:
- automate backups using cronjobs with Velero to create regular backups of the namespace and PVs.
- AWS Lambda can also be set up to trigger EBS snapshots or trigger Velero backups.

### 4. Cross-Region Replication & DR:

- `EBS Snapshot Copy`: 
- Use AWS to copy snapshots to another region.  
- automate this process using AWS Lambda functions or AWS Data Lifecycle Manager (DLM).

- `Velero Cross-Region Restore`: 
- In case of a regional failure, restore the Velero backup in a different region by deploying it on a new EKS cluster.

### Best Practices for DR & Backup in an EKS Setup:

- Use Managed Services for Key Data:
    - For critical data stores like PostgreSQL, MySQL, or MongoDB, consider using managed versions (like RDS) which handle cross-region replication automatically.

- Periodic Testing of Backup & Restore:
    - Regularly test backup and restore procedures. 
    - Ensure that backups work as expected and that restores can be done efficiently and quickly.

- Version Control for Kubernetes Manifests:
    - Store Kubernetes manifests (YAML files for deployments, services, ingress) in Git so that the entire infrastructure configuration can be easily redeployed if necessary.

- Monitor for Early Detection of Issues:
    - Use monitoring tools like Prometheus and Grafana to detect failures or performance issues in your EKS cluster early. 
    - Ensure they monitor backup jobs and alert in case of failures.

- Consider CloudFormation or Terraform:
    - For recreating the entire infrastructure, consider using infrastructure-as-code tools like CloudFormation or Terraform to ensure the EKS cluster and related resources can be redeployed automatically.

- <img width="670" alt="Backup-Tools-EKS" src="https://github.com/user-attachments/assets/29685d9e-872d-4ea6-ae34-a019a7a96cec">


## What happens if the EKS cluster fails, the Velero also impacted
- Velero backups are stored outside the cluster, typically in an S3 bucket (or another cloud storage provider like GCP or Azure Blob Storage). This means that even if the cluster is lost, the backups are safe because they are stored in a separate location.

- In case the cluster is lost, that can be restored by:
    - Creating a new EKS cluster.
    - Installing Velero on the new cluster.
    - Restoring the backups from the S3 bucket to the new cluster using the Velero CLI.


