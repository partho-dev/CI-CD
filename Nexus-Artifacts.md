## What is an Artifacts
- Artifacts are the output of any software build process, for example `.exe` file is an artifacts
- When we create a docker image using docker build command, it creates a docker image as an output and this is an artifacts
- Basically an Artifacts can be anything, including Docker images, text files, or Helm charts. 
- There are other examples as well, for JAVA based software the artifacts are WAR files, reports, log files, zip, tar etc
- So, to store all these artifacts we need a repository and one of those repositories is `Nexus`
- `Nexus` is one of the products of a company called `sonatype`

- Here is a list of programing language and its tool needed to build
- <img width="711" alt="Nexus" src="https://github.com/user-attachments/assets/48e7e101-9cf9-496d-b513-16aa49939d61">

### Why do we need a repository, we can directly push the artifacts to our deployment server
- Ok, so, we need to understand, deployment is a different process and that comes under `CD`
- & the Creating the artifacts is coming under `CI`
- During CI, the pipeline creates the artifacts and stores in some remote repo like Nexus 
- & during the CD process, the artifacts gets pulled from repo and get applied into the Deployment
- Everytime we push the artifacts into Nexus, it gets versioned and its easier to rollback to older version, rather rebuilding a new artifacts using old source commitments.
- If we use any public repositories like `Dockerhub`, `npm`, `apt-get`, `yum` we dont have any control on the access, but the `Private` repo like `Nexus` has granular control on user level and on policy level as well
-  So, we have to configure the Nexus to be a single point of truth for all the repositories an organisation needs to protect their IP.
- To have controll on the Private repository like Nexus, we need something called `Repository Manager` which ensures
    - Configure users, provide RBAC to controll the access control 
    - It helps to store or retrieve any build artifacts
    - It helps to create different types of Repositories (`3 types` - `Proxy Repo`, `Hosted Repi`, `Group Repo` )
    - Repository Manager helps proxy any remote repositories & caches its content locally for further use by the internal orgs
    - Maintains a repo for its own internal artifacts

### What are the different types of Repositories Nexus has

- ![Nexus-Repo](https://github.com/user-attachments/assets/894a8326-56c7-4b26-8cba-7e62dba7163b)

- Nexus Repository Manager has three types of repositories: 
    - `Proxy repositories`: Acts as a cache for public repositories like Dockerhub for Docker images.
        - The public repo url `https://hub.docker.com/` should be whitelisted in the proxy server

    - `Hosted repositories`: Store buld artifacts on Nexus, accessible only to the user with SSO, or Ldap or users from orgs. Not from outside world.
        - Nexus repository manager provides `Maven` with two types of hosted repositories
            - `maven-releases` & `maven-snapshots`

    - `Group repositories`: Combines multiple hosted and proxy repositories into a single logical group,providing a unified view for clients.

### What we can do with Nexus Repository and its facts
- `Creation`: Create hosted, proxy, or group repositories.
- `Configuration`: Set policies for retention, cleanup, and indexing.
- `Security`: Control access to repositories and manage permissions.

- Artifact Formats:
    - `Support`: Nexus supports various artifact formats, including Maven, npm, Docker, and more.
    - `Configuration`: Configure specific settings for each format.

- Security:
    - `Authentication`: Configure authentication mechanisms like LDAP, Active Directory, or internal users.
    - `Authorization`: Define roles and permissions for different users.
    - `Encryption`: Protect sensitive data like passwords and credentials.

    - There are two types of user we can create on Nexus 
        - 1. Anonymous user  - They get only access to the repo contents (`GET - Read only` ), but they are restricted on other actions like create, delete, upload etc
        - 2. Regular user - Each `user` can have different `Roles` with different `Previleges`
    - There are some default `previleges` available for Nexus see the lists here https://help.sonatype.com/en/privileges.html
    - Generally `Jenkins` integrations are pretty common, where we want the Jenkins to upload the artifacts into Nexus, so we have to create a user `Jenkins` and assign a role with previlege as `create & read` - but not `delete`


- Best Practices
    - `Regular Cleanup`: Regularly clean up old or unused artifacts to optimize storage.
    - `Security Audits`: Conduct regular security audits to identify and address vulnerabilities.
    - `Performance Optimization`: Monitor performance and optimize settings as needed.
    - `Version Control`: Use version control for Nexus configuration to track changes and facilitate rollback.
    - `Backup and Recovery`: Implement a robust backup and recovery plan to protect your repository data.

- Promotion of repository
    - When we build an artifacts, that build does not get used in the production deployment
    - First it stores itself into staging repository
    - The tests are performed on the staging repo and if it passes all the tests, vulnerability tests,
    - The artifacts gets `promoted` into production repository to be used by prod deployment

