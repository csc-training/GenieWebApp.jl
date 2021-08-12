# Via Web User Interface
!!! info
    These instructions are written for Rahti with **OKD3**. The instructions need to be updated once **OKD4** is released.

## Pushing the Docker Image to Container Registry
We should log in to [**Rahti Container Registry**](https://registry-console.rahti.csc.fi/), create a new project, and push the Docker image.

Then, we can log in on the command line using the token provided by the web client.

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
After uploading a container image, we can log in to [**Rahti Web User Interface**](https://rahti.csc.fi:8443/) and deploy the image from the Rahti Container Registry by selecting *Deploy Image*, then *Image Stream Tag* with following parameters:

- *Namespace*: `<project>`
- *Image Stream*: `<name>`
- *Tag*: `<tag>`

Finally, press *Deploy*.


## Creating a Secure Route
By creating a route, we can expose the application to the internet. We can create a new route by selecting *Create Route* with the following parameters.

- *Name*: `genie` (Gives route a name)
- *Hostname*: `genie.rahtiapp.fi`
- *Path*: `/`
- *Service*: `genie`
- *Target Port*: `8000 → 8000 (TCP)`
- *Alternate Services*:
    - *Split traffic across multiple services*:
- *Security*: `Secure route` (by selecting `Secure Route` we enforce a secure connection via HTTPS.)
    - *TLS Termination*: `Edge`
    - *Insecure Traffic*: `Redirect`

Our application should now be available under the address [https://genie.rahtiapp.fi](https://genie.rahtiapp.fi).


## Setting Up Persistent Storage
We can set up [persistent storage](https://docs.csc.fi/cloud/rahti/storage/persistent/) to `data` directory inside the application from [**Rahti Web User Interface**](https://rahti.csc.fi:8443/) as follows:

1. Select a project from *My Projects* or create a new project.
2. Select *Storage* and then *Create Storage* with the following parameters:
    - *Storage class*: `glusterfs-storage`
    - *Name*: `genie-volume`
    - *Access Mode*: `Shared Access (RWX)`
3. Then select *Applications* > *Deployments*, then your Genie application deployment. The from *Actions* menu, select *Add Storage* with the following parameters:
    - *Storage*: `genie-volume`
    - *Mount path*: `/home/genie/app/data`

Application on Docker container is mounted to `/home/genie/app/`.
