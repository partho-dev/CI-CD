## Create a Private Nexus Repo for Docker images

- Step 1: `Create an NPM Hosted Repository`

    - Log in to Nexus.
    - Create the NPM Hosted Repository:
        - Go to Repositories > Create repository.
        - Select npm (hosted).
        - Set the Name (e.g., npm-repo).
        - Keep the other settings as default, or configure them according requirements.
        - Click Create Repository.

- Step 2: `Create an NPM Proxy Repository (Optional)`
    - This basically cache external NPM packages locally
    - generally, npm i express would go to internet(npm public repo - https://registry.npmjs.org/) and download the express package, 
    - But in the Organization, it needs to be restricted to get the package from Private Repo, which we are going to setup on Nexus (`my-company.nexus.com`)

    - Go to Repositories > Create repository.
    - Select npm (proxy).
    - Set the Name (e.g., npm-proxy).
    - In the Remote Storage field, set it to https://registry.npmjs.org/.
    - Click Create Repository.

- Step 3: Configure an NPM `Group` Repository (Optional)
    - This is an aggregate of the hosted and proxy repositories:

    - Go to Repositories > Create repository.
    - Select npm (group).
    - Set the Name (e.g., npm-all).
    - Add the npm-repo and npm-proxy to the group.
    - Click Create Repository.


### To Test Set Up NPM on a Server (Jenkins)

- Step 4: Install Node.js and NPM
```
sudo apt update
sudo apt install nodejs npm -y
```

- Step 5: Configure NPM to Use Nexus Repository

    - For the Hosted Repository:
        - `npm set registry http://3.16.26.143:8081/repository/npm-repo/`

    - For the Group Repository (if created):
        - `npm set registry http://3.16.26.143:8081/repository/npm-all/`

    - Verify the Configuration:
        -  `npm config get registry`
        - This should return the Nexus repository URL.

- Authenticate with Nexus (if needed)
    - `npm login --registry=http://3.16.26.143:8081/repository/npm-repo/`
    - Enter the Nexus username and password when prompted.

### Test with an Express.js Git Repository
- Step 6: Clone the Express.js Git Repository
    - `git clone https://github.com/partho-dev/sample-code.git`
    - `cd sample-code`

- Step 7: Publish a Private NPM Package to Nexus
    - Create a Private Package: 
    - If the `Express` project has any custom modules, it can be published to the Nexus NPM repository.

    - Add a `package.json` file if it doesn't exist:
    - npm init -y

- Publish the Package: Publish package to the Nexus repository:
    - `npm publish --registry=http://3.16.26.143:8081/repository/npm-repo/`
    - Make sire the package.json has a unique name and version.
    - Verify the Publication: 
        - Check the Nexus UI to confirm the package was published.

- Step 8: Install Dependencies Using Nexus
    - If the package.json contains dependencies(nodemon, dotenv etc), they will be fetched from the Nexus repository:

    - Install Dependencies: `npm install`
    - Verify the Installation: 
        - Make sure all dependencies are correctly installed. 
        - They should be pulled from Nexus if available.

- Run the Express.js Application: `npm start`