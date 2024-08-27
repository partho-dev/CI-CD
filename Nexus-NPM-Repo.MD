### How to know on my local laptop if I am using public or private npm repo
- Go to the npm project cd express_js_project
- type `npm config get registry` - `https://registry.npmjs.org/` # This is public Repo
- To update that to use private repo - `npm config set registry=https://private_repo_URL`
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

- Step 5: Configure NPM to Use Nexus Repository on the Developer Laptop
    - If this is not done, the developer laptop will go to internet https://registry.npmjs.org/ and download the packages

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

    - For example the developer wants to install `express` package from Nexus group repo
    - `npm install express --registry http://3.16.26.143:8081/repository/npm-all/`

    - For any private package - `npm install my_private_package --registry http://3.16.26.143:8081/repository/npm-all/`

    - But, instead of using the regitsry name on every package installation, we can set the config as explained on `Step -5`

    - Verify the Installation: 
        - Make sure all dependencies are correctly installed. 
        - They should be pulled from Nexus if available.

- Run the Express.js Application: `npm start`


## How to disable annonymous user access to Nexus and download nom packages
- Go to Nexus - under settings, click `"Annonymous Access"`
- Disable the access
- Now, the npm install express from the Nexus would fail 
- Create a user (npm-user/password) to download the npm, and give it a privilege as `npm-read-role`
- Encode the creds in base 64 - `echo -n "npm-user:password" | base64`
- This will give the token - `bnBtLXVzZXI6cGFzc3dvcmQ=`
- On the Developer laptop, set this user who has permission to download the packages
    - `npm config set _auth="bnBtLXVzZXI6cGFzc3dvcmQ="`
- verify that on `.npmrc` file - `cat ~/.npmrc`
- try to install a package, if this gives any error related to `_auth` variable, just change the variable name from `vi .nmrc`


### Step no - 7: Why do we need private package.
- One of the main purposes to have a private repo is to host the custom packages that are created within the organization and used for the organisations.
- Example, we have `express`, `cors` and they are public packages
- Sometime, we need to have our own private packages which solves some specific problem

### Lets take an example of creating a private npm package named `my-private-package`
- Create a folder & a name of package is the name of the folder
```
mkdir my-private-package
cd my-private-package
```
- Initialise the project in that folder - `npm init`
- Add all the files and logic in the code
- Example one file is `index.js` and it would have other controller files etc
```
// index.js
module.exports = function() {
    console.log('Hello from my private package!')
}

```
- This would update the package.json like this 
```
{
  "name": "my-private-package",
  "version": "1.0.0",
  "main": "index.js",
  "author": "Partho",
  "license": "MIT"
}

```
- Now this developer will push his private pacjage to the nexus for the other developers
```
- npm set registry http://<your-nexus-ip>:8081/repository/npm-repo/
- npm login --registry=http://<your-nexus-ip>:8081/repository/npm-repo/
- npm publish --registry=http://<your-nexus-ip>:8081/repository/npm-repo/
```

- Another Developr is using this private package 
- `npm install my-private-package --registry=http://<your-nexus-ip>:8081/repository/npm-repo/`
```
const myPrivatePackage = require('my-private-package');
myPrivatePackage();

```
- This will log Hello from my private package! to the console.



### Million Dollar Question
- We are not allowing the developers to download package from public npm.org, but we are directing them
- to download the package from Nexus repo
- But, behind the scene, the nexus downloads all the packages and stores on its storage
- Which the developers download
- Then whats the purpose & benifit

### Benefits of Redirecting NPM Requests Through Nexus

- Control and Governance:
        Security: approve packages before they are available to the developers. This prevents unauthorized or malicious packages from being used.
        Licensing Compliance: enforce to use the package which compy with orgs standard

- Caching:
        Speed: Once a package is downloaded by Nexus, subsequent requests from any developer in your organization will be served by Nexus, reducing download times and bandwidth usage. So saves cost of internet usage as most of the orgs uses private network.
        Offline Access: If the public NPM registry is down or temporarily unavailable, developers can still access cached packages from Nexus.

- Consistency:
        Version Control: Nexus can store specific versions of packages, ensuring that all developers use the same versions, which is critical for consistent builds and deployments.

- Audit and Monitoring:
        Tracking: Nexus provides logs and reports on package usage, which can be valuable for auditing and understanding dependency usage within your organization.