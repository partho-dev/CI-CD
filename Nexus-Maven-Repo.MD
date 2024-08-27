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

### List of maven commands to build a code (maven build lifecycle)
- 1. `mvn compile` - it generates a new folder `target/classes` inside classes folder, which will includes the compiled code (`.class` files)
- 2. `mvn test` - It generates `target/surefire-reports` folder which will contain test reports
- 3. `mvn package` - It creates the file `target/application.war` file
    - This file gets copied to webserver like Tomcat server