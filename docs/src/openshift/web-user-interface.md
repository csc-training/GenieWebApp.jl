# Deploying the Container via Web User Interface
## Creating a Project
In this section, we explore how to use the [**Rahti Web User Interface**](https://rahti.csc.fi:8443/) to deploy an application. We can log in and press *Create Project* with a unique name that we denote with `<project>`, which you should substitute with the actual name.


## Deploying the Application
We should log in to [**Rahti Container Registry**](https://registry-console.rahti.csc.fi/) and create an empty image stream for the project with the following parameters.

- *Name*: `genie`
- *Project*: `<project>`
- *Populate*: `Create empty image stream`

Let's switch to Rahti Web User Interface and choose the project. Then, we can create a build configuration by selecting *Import YAML/JSON*, then copying and pasting the YAML configuration below.

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

The OKD documentation explains build configurations in [How Builds Work](https://docs.okd.io/3.11/dev_guide/builds/index.html). Next, navigate to *Builds* tab, select `genie` build, and press *Start Build*. Once the build has been completed, we can deploy the image by selecting *Deploy Image* from the *Add to Project* menu, and then deploying an *Image Stream Tag* with the following parameters:

- *Namespace*: `<project>`
- *Image Stream*: `genie`
- *Tag*: `latest`

This deploys the application container to OpenShift.


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
