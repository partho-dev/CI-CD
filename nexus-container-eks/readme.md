## What to do

- create name space - `kubectl create namespace nexus-dev`
- apply the deployment file - `kubectl apply deployment.yaml -n nexus-dev`
- Provided the PVC to pint to the cluster storage to store the Nexus config files
- But for Repo, use S3 as blob storage

---
- How to set S3 as blob for repo

- Configure an S3 Blob Store in Nexus:
    - Step 1: Access Nexus Repository Manager UI
            Log in to your Nexus instance as an administrator.
    - Step 2: Create an S3 Bucket
            Create an S3 bucket in AWS that will be used to store Nexus data.
    - Step 3: Configure the Blob Store
            In the Nexus UI, navigate to "Administration" > "Repository" > "Blob Stores".
            Click on "Create Blob Store" and select "S3" as the type.
            Provide the necessary details, such as the S3 bucket name, region, and AWS credentials.
    - Step 4: Use the S3 Blob Store for Repositories
            Once the S3 Blob Store is configured, you can create new repositories or migrate existing ones to use this blob store.
- Backup 
    - Periodic Snapshots: If you're still using EBS volumes for certain parts of your Nexus setup, consider taking regular EBS snapshots.
    - S3 Versioning: Enable versioning on your S3 bucket to protect against accidental deletions or overwrites.
    - Cross-Region Replication: For disaster recovery, enable cross-region replication of your S3 data to another region. 
