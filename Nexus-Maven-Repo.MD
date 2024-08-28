## lets understand why do we need Maven and what is this Maven?

- When we install `Node.js`, by default it installs its tool like `npm`, 
- But, for Java when we install `Java(JDK)`, it does not install its tool Maven(`mvn`) by default, 
- & so we need to manually install that seperately.

- Developer develops the code in JAVA and that code is called source code
- But, we can not deploy that code into our web server like Tomcat 
- That source code developr provided needs to be compiled and to compile that source code, we need a tool (Programme) and one of those tools is called `Apache Maven `

### WHat the tool does?
- The build tools does series of activities which produces an output and that output is used in the web server like tomcat
- The Build process involves `compiling` `Linking` & `Package` the code into an executable format (.JAR)

### Lets do some comparison with `npm` to understand the `maven` better

- For any `Javascript` applications, we use `npm` and it reads the `package.json` and downloads all dependancies from the repo `https://registry.npmjs.org/`

- Similarly, for `Java` applications, instead of using `npm` tool, we use `mvn` tool
- and instead of reading the depndancies from `package.json`, mvn reads from `POM.XML` file
- and instead of downloading packages from `https://registry.npmjs.org/` mvn downloads from `https://mvnrepository.com/` or `https://repo.maven.apache.org/`

- Here is a list of programing language and its tool needed to build
- <img width="711" alt="Nexus" src="https://github.com/user-attachments/assets/48e7e101-9cf9-496d-b513-16aa49939d61">


### Java build process and what tools are used for these phases
- compilation : gcc compiler
- Code Review : sonarqube
- Test Cases : junit
- Test Case Reports : Sure-fire
- Code Coverage : Cobertura
- Package - application.war 

### Install Maven on Ubuntu
- Make sure Java in installed - 
- Download : `wget https://dlcdn.apache.org/maven/maven-3/3.9.9/binaries/apache-maven-3.9.9-bin.tar.gz`
- extract : `tar -xvfz apache-maven-3.9.9-bin.tar.gz`
- Move the maven to `/opt` (Recommended) - `sudo mv apache-maven-3.9.9 /opt/maven`
- Set Up Environment Variables: Add Maven to PATH by editing the `/etc/profile.d/maven.sh` file Or `~/.bashrc`
    - `sudo vi /etc/profile.d/maven.sh`

        ```
        export M2_HOME=/opt/maven
        export PATH=${M2_HOME}/bin:${PATH}

        ```
    - Load the environment variables: `source /etc/profile.d/maven.sh`
    - Verify the Maven installation: `mvn -version`

### On the Nexus, create maven proxy repo 
- Create a proxy repo on Maven with public repo as the `https://repo1.maven.org/maven2/`
- This repo is to download the packages and store on Nexus for internal development use
- Proxy Repo (example only) : `http://3.16.26.143:8081/repository/mvn-proxy-repo/`

- Then create another mvn repo for Hosted (For the developers to push the Jar file)
    - Under `Version Policy` - Select Either `Release`(for deployment ready) or `snapshot`(still under development)
- Hosted Repo (Example only) : `http://3.16.26.143:8081/repository/mvn-hosted-release-repo/`


- 

### List of maven commands to build a code (maven build lifecycle)
- 1. `mvn compile` - it generates a new folder `target/classes` inside classes folder, which will includes the compiled code (`.class` files)
- 2. `mvn test` - It generates `target/surefire-reports` folder which will contain test reports
- 3. `mvn package` - It creates the file `target/application.war` file
    - This file gets copied to webserver like Tomcat server
- 4. `mvn deploy` - Deployes the artifacts to nexus based on the URL provided into pom.xml


### Now, the artifacts are created on our Maven server (Ex:Jenkins during Automation)
- Once the JAR or WAR is created on Maven server
- We need to push that to Nexus, but how the Maven server knows the location of Nexus
- For that, we have to update the `pom.xml` file and update the Nexus repo inside `distributionManagement` block
```
<distributionManagement>
    <repository>
        <id>...</id>   # maven-releases
        <url>...</url> # nexus_Hosted_Release_Repo_url:8081 -> Browse -> maven-releases -> Copy the URL 
    </repository>
    <snapshotRepository>
        <id>...</id>    # maven-snapshots
        <url>...</url>  # nexus_Hosted_snapshot_Repo_url:8081 -> Browse -> maven-snapshots -> Copy the URL 
    </snapshotRepository>
</distributionManagement> 
```
- But, to `upload` (`mvn deploy`) the artifacts to Nexus, we would need to be authenticated, so the developer(for manual) or Jenkins (for Automated) who uploads the artifacts to Nexus, 

```
 <servers>
    <server>
      <id>maven-releases</id>
      <username>nexus_user_name</username>
      <password>nexus_password</password>
    </server>

     <server>
      <id>maven-snapshots</id>
      <username>nexus_user_name</username>
      <password>nexus_password</password>
    </server>
  </servers>

```

- For release deploy type, the same version of code/artifacts can not be deployed, unless we manually change the release version on `pom.xml`

- Now, when the other team, like frontend team or backend team wants to use this latest artifacts, they have to get that from nexus, but for that there should be anothe repo created called `group-repo` [aggregate for both prxoy and hosted repo]
- While creating the group repo, under members repo, we need to add both proxy & hosted repo
- Example of Group Repo - `http://3.16.26.143:8081/repository/mvn-group-repo/`
- In that case, the other developer who needs that artifacts, they have to update theor local system `settings.xml` file
- and update the `mirros` block with `group repo` url