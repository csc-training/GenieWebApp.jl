# Via Command Line Interface
We can deploy our application via the OpenShift Command Line Interface (CLI).

## Installing
We should begin by downloading the [OpenShift 3.11 origin](https://github.com/openshift/origin/releases/tag/v3.11.0) and extract the archived file to `$HOME/bin` directory. Then, we should add the directory to the `$PATH` variable. In Linux, we can append the following line to our `.bashrc` file.

```bash
export PATH="$HOME/bin/openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit/:$PATH"
```

Now, we can test that your installation works by calling the help command.

```bash
oc --help
```

The [OpenShift 3.11 documentation](https://docs.openshift.com/container-platform/3.11/welcome/index.html) explains how to use OpenShift with different commands.


## Login
Let's login to OpenShift using the token obtained from the web user interface. We recommend to keep the web user interface open if you want to see visually how your deployment is progressing.

```bash
oc login "https://rahti.csc.fi:8443" --token=<hidden>
```

Check OpenShift and Kubernetes versions.

```bash
oc version
```

```
oc v3.11.0+0cbc58b
kubernetes v1.11.0+d4cacc0
features: Basic-Auth GSSAPI Kerberos SPNEGO

Server https://rahti.csc.fi:8443
openshift v3.11.0+7876dd5-361
kubernetes v1.11.0+d4cacc0
```


## Creating a Project
We denote the user defined parameters using variables.

```bash
PROJECT="app"
APP="genie"
REPO="https://github.com/csc-training/GenieWebApp.jl"
```

We can create a new project.

```bash
oc new-project $PROJECT
```

If a project already exists, we can change to existing project instead.

```bash
oc project $PROJECT
```

We can list existing projects

```bash
oc projects
```

```
You have one project on this server: "app".

Using project "app" on server "https://rahti.csc.fi:8443".
```

We can show an overview of our current project.

```bash
oc status
```

```
In project app on server https://rahti.csc.fi:8443

You have no services, deployment configs, or build configs.
Run 'oc new-app' to create an application.
```


## Deploying the Application
Create new application, build the Docker container for the repository and deploy it to OpenShift

```bash
oc new-app $REPO --name=$APP
```


## Creating a Secure Route
We can expose the application to the internet by creating a *Route*.

```bash
oc create route edge \
    --insecure-policy="Redirect" \
    --service=$APP \
    --hostname="$APP.rahtiapp.fi"
```

Application should now be available in `https://$APP.rahtiapp.fi`.


## Adding Persistent Storage
We can create a persistent storage and mount it to the application with a *Persistent Volume Claim (PVC)*.

```bash
oc set volume dc/$APP \
    --add \
    --name="volume-1" \
    --type="PersistentVolumeClaim" \
    --claim-name="genie-volume" \
    --claim-mode="ReadWriteMany" \
    --claim-size="1G" \
    --mount-path="/home/genie/app/data"
```


## Rebuilding Application
If we update our application and want to propagate the changes to the server, can start a new build.

```bash
oc start-build $APP
```


## Deleting Application
After we are done with our application we can delete it.

```bash
oc delete all -l app=$APP
```
