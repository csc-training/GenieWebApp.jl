# Deploying the Application via Command Line Interface in Rahti2

We can deploy our application via the OpenShift Command Line Interface (CLI).

## Installing the Client

Follow these steps to install the OpenShift CLI on a Linux system:

### Step 1: Download the CLI Tool

1. Navigate to the [OpenShift Container Platform downloads page](https://access.redhat.com/downloads/content) on the Red Hat Customer Portal.
2. In the Version drop-down menu, select the version that corresponds to your OpenShift Container Platform.
3. Find the "OpenShift v4.X Linux Client" entry and click "Download Now". Save the file to your computer.

### Step 2: Unpack the Archive

Unpack the downloaded file using the following command in your terminal:

```bash
tar xvzf <file>
```

Replace `<file>` with the name of the downloaded file.

### Step 3: Add `oc` to Your PATH

1. Move the `oc` binary to a directory that is included in your system's PATH environment variable.
2. To check your current PATH, use:

   ```bash
   echo $PATH
   ```

### Step 4: Verify the Installation

After installing, you can access the OpenShift CLI using the `oc` command. Verify the installation by executing:

```bash
oc --help
```

## Login

Let's login to OpenShift using the token obtained from the [Web User Interface](https://landing.2.rahti.csc.fi/). We recommend to keep the web user interface open if you want to see visually how your deployment is progressing.

```bash
oc login  --server=https://api.2.rahti.csc.fi:6443 --token=<hidden>
```

## Creating a Project

We denote the user defined parameters using variables.

```bash
PROJECT="app"
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

We can show an overview of our current project.

```bash
oc status
```

## Deploying the Application

Create new application using the the configuration `genieapp.yaml` file.

```bash
oc apply -f genieapp.yaml
```

## Troubleshooting

If,during the deployment process, encounter an error similar to the following:

```
Precompiling project...
Killed
error: build error: error building at STEP "RUN julia -e "...compile(); "": error while running runtime: exit status 137
```

To resolve this issue, increase the memory allocation for your deployment to at least 2Gi. Here's how you can do this in the `genieapp.yaml` file.

Modify the memory allocation liek this:

```yaml
resources:
limits:
  memory: 2Gi
```

Apply the changes and deploy your application again using the updated configuration.
