## Jenkins pipeline
- Pushing the docker image as a build to Nexus Private-repo

- In the pipeline, we are pushinh the image as `def app = docker.image("nextjs-sample:${env.BUILD_ID}")`
- So, on the nexus - we should look for the image on this directory - `nextjs-sample`

- <img width="1661" alt="Nexus-docker-img" src="https://github.com/user-attachments/assets/04a5b873-4d33-4b91-9381-4d672e19f8ea">

### Lets do a manual deployment of this image into `Minikube`

- Update the deployment file with the `nexus` image url - `image: 54.175.95.188:8092/nextjs-sample:21`
```
spec:
  containers:
    - name: nextjs-container
      image: 54.175.95.188:8092/nextjs-sample:21
      ports:
        - containerPort: 3000
```

- when we do - `kubectl apply -f deployment-nexus-private-repo.yaml`
- The K8s or minikube can not pull the image from that private repo, because k8s will fail to autheticate
- To make K8s authenticate with Nexus or dockerhub private repo, we need to inject the creds as a secret into the k8s cluster
- 
```
kubectl create secret docker-registry nexus-registry-secret \
    --docker-server=54.175.95.188:8092 \
    --docker-username=jenkins-user-on-nexus \
    --docker-password=password \
    --docker-email=youremail@example.com
```

- **Side Note** : Before applying the secret, check if the cluster is set correctly into the current context - `kubectl config get-contexts`

- Since our nexus is insecure now, (http), so we need to let the `docker` know to pull the image through insecure path
- we need to update our K8s or minikube to pull from insecure registry
- `minikube ssh`
- update this file - `/etc/docker/daemon.json` - 
- 
```
{
  "insecure-registries": ["54.175.95.188:8092"]
}
```
- Then restart the docker in K8s - `sudo systemctl restart docker`
- Exit the minikube
- Then execute the `kubectl` deployment - `kubectl apply -f deployment.yaml`
