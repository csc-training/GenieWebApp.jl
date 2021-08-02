# Deploying to Container Cloud using OpenShift
!!! info
    These instructions are written for Rahti with **OKD3**. The instructions need to be updated once **OKD4** is released.

## Pushing the Docker Image to Container Registry
We should log in to [**Rahti Container Registry**](https://registry-console.rahti.csc.fi/), create a new project, and push the Docker image. Then, we can log in on the command line using the token provided by the web client.

```bash
sudo docker login -p <token> -u unused docker-registry.rahti.csc.fi
```

Next, we should tag the locally built Docker image. Substitute `<name>` and `<tag>` with the same values as for the Docker image and `<project>` with the name of your Rahti project.

```bash
sudo docker tag <name>:<tag> docker-registry.rahti.csc.fi/<project>/<name>:<tag>
```

Now, we can push the image to the Rahti Container Registry.

```bash
sudo docker push docker-registry.rahti.csc.fi/<project>/<name>:<tag>
```

After we have uploaded the image, we are ready to deploy it.

## Deploying the Container Image
After uploading a container image, we can log in to [**Rahti Web User Interface**](https://rahti.csc.fi:8443/) and deploy the image from the Rahti Container Registry by selecting `Deploy Image`. Then, we should create a new route by selecting `Create Route`, giving the route name, and selecting `Secure Route` to enforce a secure connection via HTTPS. Our application should now be available under the address `https://route-project.rahtiapp.fi`.

## Setting Up Persistent Storage
We can set up [persistent storage](https://docs.csc.fi/cloud/rahti/storage/persistent/) to `data` directory inside the application from [**Rahti Web User Interface**](https://rahti.csc.fi:8443/) as follows:

1. Select a project from *My Projects* or create a new project.
2. Select *Storage* and then *Create Storage* with the following parameters:
    - *Storage class*: `glusterfs-storage`
    - *Name*: `genie-data`
    - *Access Mode*: `Shared Access (RWX)`
3. Then select *Applications* > *Deployments*, then your Genie application deployment. The from *Actions* menu, select *Add Storage* with the following parameters:
    - *Storage*: `genie-data`
    - *Mount path*: `/home/genie/app/data`

Application on Docker container is mounted to `/home/genie/app/`.
