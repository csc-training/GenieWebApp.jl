# Deploying the Application via Web User Interface
## Creating a Project
This section explores how to use the [**Rahti Web User Interface**](https://rahti.csc.fi:8443/) to deploy an application. We can log in and press *Create Project* with a unique name that we denote with `<project>`, which you should substitute with the actual name.


## Deploying the Application
We need to build a container image for the application to deploy it on OpenShift. OpenShift is capable of building container images in the cloud. To perform the build, we need to login to [**Rahti Container Registry**](https://registry-console.rahti.csc.fi/) and create an empty image stream for our application with the following parameters.

- *Name*: `genie`
- *Project*: `<project>`
- *Populate*: `Create empty image stream`

Next, we should switch to the Rahti Web User Interface and choose the project. Then, we can build the container image from the specified GitHub repository to the empty image stream on Rahti Container Registry using a build configuration.  Start by selecting *Import YAML/JSON*, then copying and pasting the YAML configuration below.

```yaml
apiVersion: v1
kind: BuildConfig
metadata:
  name: genie
spec:
  runPolicy: Serial
  source:
    git:
      uri: 'https://github.com/csc-training/GenieWebApp.jl'
  strategy:
    dockerStrategy:
      from:
        kind: ImageStreamTag
        name: 'julia:1.6-buster'
    type: Docker
  output:
    to:
      kind: ImageStreamTag
      name: 'genie:latest'
```

The OKD documentation explains the build configurations in [How Builds Work](https://docs.okd.io/3.11/dev_guide/builds/index.html). Next, we need to initiate the container image build by navigating to the *Builds* tab, selecting `genie` build, and pressing *Start Build*. Once OpenShift has completed the build, we can deploy the image by selecting *Deploy Image* from the *Add to Project* menu and then deploying an *Image Stream Tag* with the following parameters:

- *Namespace*: `<project>`
- *Image Stream*: `genie`
- *Tag*: `latest`

Now, we have the application running on OpenShift.


## Creating a Secure Route
By creating a route, we can expose the application to the internet. We can create a new route by selecting *Create Route* with the following parameters.

- *Name*: `genie`
- *Hostname*: `genie.rahtiapp.fi`
- *Path*: `/`
- *Service*: `genie`
- *Target Port*: `8000 → 8000 (TCP)`
- *Security*: `Secure route`
    - *TLS Termination*: `Edge`
    - *Insecure Traffic*: `Redirect`

By selecting `Secure Route`, we enforce a secure connection via HTTPS. Therefore, our application should now be available under the address `https://genie.rahtiapp.fi`.


## Setting Up Persistent Storage
We can set up [persistent storage](https://docs.csc.fi/cloud/rahti/storage/persistent/) to the application by selecting *Storage* and then *Create Storage* with the following parameters:

- *Storage class*: `glusterfs-storage`
- *Name*: `genie-volume`
- *Access Mode*: `Shared Access (RWX)`

Next, we select *Applications*, then *Deployments*, and finally your Genie application deployment. From the *Actions* menu, select *Add Storage* with the following parameters:

- *Storage*: `genie-volume`
- *Mount path*: `/home/genie/app/data`

Now the persistent storage is mounted inside the Genie application's `data` directory.
