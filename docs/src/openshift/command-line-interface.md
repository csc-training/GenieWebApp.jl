# Via Command Line Interface
Install OpenShift command line interface.

We denote user defined parameter using variables.

```bash
PROJECT=<project-name>
APP=<app-name>
```

```bash
oc login https://rahti.csc.fi:8443 --token=<hidden>
oc new-project $PROJECT
oc project $PROJECT
oc new-app https://github.com/jaantollander/GenieWebApp.jl --name=$APP
oc expose svc/$APP --hostname=$APP.rahtiapp.fi
oc start-build $APP
oc status
oc delete all -l app=$APP
```
