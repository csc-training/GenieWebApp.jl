# Deploying to Virtual Machine using OpenStack
### Setting up and Connecting to a Virtual Machine
Once we have access to Pouta, we should log in to the [**Pouta Web User Interface**](https://pouta.csc.fi). Then, we can follow the instructions on [launching a virtual machine in the cPouta web interface](https://docs.csc.fi/cloud/pouta/launch-vm-from-web-gui/).

#### Setting up SSH Keys
We can create SSH keys in the web interface by navigating to *Compute*, then *Key Pairs* and selecting *Create Key Pair*. Next, give the key pair name `<keyname>` and save the downloaded `<keyname>.pem` file to your home directory. Then, on the command line, move to the home directory, create `.ssh` directory with write privileges if it doesn't exist, and move your key file into it.

```bash
cd ~
mkdir -p .ssh
chmod 700 .ssh
mv <keyname>.pem .ssh
```

Next, protect the key with a password and make it read-only.

```bash
ssh-keygen -p -f .ssh/<keyname>.pem
chmod 400 .ssh/<keyname>.pem
```

#### Security Groups
We can set up firewalls and security groups by navigating to *Network*, then *Security Groups*. Let's create a new security group by selecting *Create Security Group* and naming it `SSH`. Then, select *Manage Rules* for the `SSH` group and then *Add Rule* with the following parameters:

- Rule: `Custom TCP Rule`
- Direction: `Ingress`
- Open Port: `Port Range`
- From Port: `22`
- To Port: `22`
- Remote: `CIDR`
- CIDR: `<ip-address>/24`. Substitute `<ip-address>` with your IP address which you can find out from [myipaddress.com](http://www.myipaddress.com/).

Next, we need to allow traffic from the internet to our web application. Let's create a security group named `Internet` and add a rule with the following parameters.

- Rule: `Custom TCP Rule`
- Direction: `Ingress`
- Open Port: `Port Range`
- From Port: `8000`
- To Port: `8000`
- Remote: `CIDR`
- CIDR: `0.0.0.0/0`

#### Launching a Virtual Machine
To launch a virtual machine with the *Ubuntu 20.04* operating system, let's navigate to *Compute*, then *Instances*, and select *Launch Instance*.

In the *Details* tab

- Availability Zone: `nova`
- Instance Name: `genie`
- Flavor: `standard.tiny`
- Number of Instances: `1`
- Instance Boot Source: `Boot from image`
- Image Name: `Ubuntu-20.04`

In *Access & Security* tab

- Key Pair: `<keyname>`
- Security Groups: `SSH`, `Internet`

#### Adding a Public IP
Associating the virtual machine with a public IP allows users to connect to it with the methods we have set on the security groups. To create and associate a public IP, navigate to the menu next to *Create Snapshot* and select *Associate Floating IP*. Then, on the *IP Address* field, click the *plus* sign to allocate a new floating IP. Once allocated, select the created floating IP and press *Associate*. We denote the value of the floating IP as `<public-ip>`.

#### Adding Persistent Storage
We can also [persistent storage](https://docs.csc.fi/cloud/pouta/persistent-volumes/) to the virtual machine by navigating to *Volumes*, then *Volumes*, and selecting *Create Volume* with the following parameters:

- Volume Name: `genie`
- Volume Source: `No source, Empty volume`
- Type: `Standard`
- Size: `1 GiB`
- Availability Zone: `nova`

From the menu next to *Edit Volume*, select *Manage Attachments* and then attach the volume to the `genie` virtual machine.

#### Connecting to the Virtual Machine
Now, we can [connect to our virtual machine](https://docs.csc.fi/cloud/pouta/connecting-to-vm/) using SSH.

```bash
ssh ubuntu@<public-ip> -i ~/.ssh/<keyname>.pem
```

### Installing the Genie Web Application
Once we have connected to the virtual machine via SSH, we need to install Julia language and our Genie web application using the command line. So let's begin by installing the Julia language.

```bash
# Change directory to home directory
cd ~

# Set URL for downloading Julia binaries
JULIA_URL="https://julialang-s3.julialang.org/bin/linux/x64/1.6/julia-1.6.2-linux-x86_64.tar.gz"

# Set name for the downloaded archive
JULIA_ARCHIVE="julia.tar.gz"

# Download the Julia language binaries
curl -o ${JULIA_ARCHIVE} ${JULIA_URL}

# Uncompress (-z) and extract (-z) files (-f) from archive
tar -x -z -f ${JULIA_ARCHIVE}

# Remove the archive file after extraction
rm ${JULIA_ARCHIVE}

# Add Julia executable to the PATH in `.bashrc`
echo 'export PATH="${PATH}:${HOME}/julia-1.6.2/bin"' >> .bashrc

# Add Julia executable to the PATH
export PATH="${PATH}:${HOME}/julia-1.6.2/bin"
```

Next, we can install our Genie web application from GitHub.

```bash
# Clone the Genie application from the GitHub repository
git clone "https://github.com/jaantollander/GenieWebApp.jl.git"

# Change directory to GenieWebApp.jl
cd "GenieWebApp.jl"

# Install GenieWebApp.jl as Julia package
julia -e "using Pkg; Pkg.activate(\".\"); Pkg.instantiate(); Pkg.precompile(); "

# Setup Genie environment variables
export GENIE_ENV="prod"
export HOST="0.0.0.0"
export PORT="8000"
export EARLYBIND="true"

# Give execution privileges to `bin/server` script
chmod +x bin/server
```

Next, we need to create a new [Linux Screen](https://linuxize.com/post/how-to-use-linux-screen/) for running the web server as a background process.

```bash
screen -S genie
```

On the new screen, let's execute the`./bin/server` script to start a server.

```bash
bin/server
```

We can exit the screen by holding `Ctrl` and pressing `a` and then `d` key. We can retach the screen again by using the `screen -r genie` command if we need to.

The web application should now be available at `http://<public-ip>:8000`.
