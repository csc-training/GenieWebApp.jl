# Via Command Line Interface
We can deploy our application via the OpenShift Command Line Interface (CLI).


## Installing
We should begin by installing the OpenShift command line interface.


## Login
Let's login to OpenShift using the token obtained from the web interface.

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
We can expose the application to the internet by creating a route.

```bash
oc create route edge --service=$APP --hostname="$APP.rahtiapp.fi"
```

Application should now be available in `https://$APP.rahtiapp.fi`.


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
