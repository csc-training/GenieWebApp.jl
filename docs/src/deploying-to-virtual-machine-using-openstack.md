# Deploying to Virtual Machine using OpenStack
## Setting up and Connecting to a Virtual Machine
Once we have access to Pouta, we should log in to the [**Pouta Web User Interface**](https://pouta.csc.fi). Then, we can follow the instructions on [launching a virtual machine in the cPouta web interface](https://docs.csc.fi/cloud/pouta/launch-vm-from-web-gui/).

### Setting up SSH Keys
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

### Configuring Security Groups
We can manage internet access to our virtual machine by defining security groups and associating them with the virtual machine. We can set up firewalls and security groups by navigating to *Network*, then *Security Groups*. Let's create a new security group by selecting *Create Security Group* and name it `SSH`. Then, select *Manage Rules* for the group and *Add Rule* with the following parameters:

- *Rule*: `Custom TCP Rule`
- *Direction*: `Ingress`
- *Open Port*: `Port`
- *Port*: `22` (Default for SSH connections.)
- *Remote*: `CIDR`
- *CIDR*: `<ip-address>/24` (Substitute `<ip-address>` with your IP address which you can find out from [myipaddress.com](http://www.myipaddress.com/).)

Next, let's create a security group named `HTTP` and add a rule with parameters.

- *Rule*: `Custom TCP Rule`
- *Direction*: `Ingress`
- *Open Port*: `Port`
- *Port*: `80` (Default for HTTP connections.)
- *Remote*: `CIDR`
- *CIDR*: `0.0.0.0/0`

Finally, let's create `HTTPS` security group and add the rule with parameters:

- *Rule*: `Custom TCP Rule`
- *Direction*: `Ingress`
- *Open Port*: `Port`
- *Port*: `443` (Default for HTTPS connections.)
- *Remote*: `CIDR`
- *CIDR*: `0.0.0.0/0`

### Launching a Virtual Machine
We will use a virtual machine with the *Ubuntu 20.04* operating system. We can launch a virtual machine by navigating to *Compute*, then *Instances*, and select *Launch Instance*. Set the following parameters and press *Launch*:

- In the *Details* tab:
  - *Availability Zone*: `nova`
  - *Instance Name*: `genie`
  - *Flavor*: `standard.tiny`
  - *Number of Instances*: `1`
  - *Instance Boot Source*: `Boot from image`
  - *Image Name*: `Ubuntu-20.04`
- In *Access & Security* tab:
  - *Key Pair*: `<keyname>`
  - *Security Groups*: `SSH`, `HTTP`, `HTTPS`

By including the `SSH` security group we can connect to our virtual machine via SSH. Furthermore, by including `HTTP` and `HTTPS` security groups we allow traffic from the internet to the web server and application deployed on the virtual machine.

### Adding a Public IP
Associating the virtual machine with a public IP allows users to connect to it with the methods we have set on the security groups. To create and associate a public IP, navigate to the menu next to *Create Snapshot* and select *Associate Floating IP*. Then, on the *IP Address* field, click the *plus* sign to allocate a new floating IP. Once allocated, select the created floating IP and press *Associate*. We denote the value of the floating IP as `<public-ip>`.

### Adding Persistent Storage
We can also [persistent storage](https://docs.csc.fi/cloud/pouta/persistent-volumes/) to the virtual machine by navigating to *Volumes*, then *Volumes*, and selecting *Create Volume* with the following parameters:

- *Volume Name*: `genie`
- *Volume Source*: `No source, Empty volume`
- *Type*: `Standard`
- *Size*: `1 GiB`
- *Availability Zone*: `nova`

From the menu next to *Edit Volume*, select *Manage Attachments* and then attach the volume to the `genie` virtual machine.

### Domain Name
We can find out the default hostname of our virtual machine using the `host` command on the public IP address.

```bash
host <public-ip>
```

```
15.253.214.128.in-addr.arpa domain name pointer vm3814.kaj.pouta.csc.fi.
```

We can also configure our own domain name by pointing DNS records to the virtual machine IP address. You read more about [DNS services in cPouta](https://docs.csc.fi/cloud/pouta/additional-services/#dns-services-in-cpouta) in the docs.

### Connecting to the Virtual Machine
Now, we can [connect to our virtual machine](https://docs.csc.fi/cloud/pouta/connecting-to-vm/) using SSH with our SSH key.

```bash
ssh ubuntu@<public-ip> -i ~/.ssh/<keyname>.pem
```


## Installing Julia Language
Once we have connected to the virtual machine via SSH, we need to install Julia language and our Genie web application using the command line. So let's begin by installing the Julia language.

```bash
# Set URL for downloading Julia binaries
JULIA_URL="https://julialang-s3.julialang.org/bin/linux/x64/1.6/julia-1.6.2-linux-x86_64.tar.gz"

# Set name for the downloaded archive
JULIA_ARCHIVE="${HOME}/julia.tar.gz"

# Download the Julia language binaries
curl -o ${JULIA_ARCHIVE} ${JULIA_URL}

# Uncompress (-z) and extract (-z) files (-f) from archive
tar -x -z -f ${JULIA_ARCHIVE}

# Remove the archive file after extraction
rm ${JULIA_ARCHIVE}

# Add symbolic link of Julia executable to /usr/bin so its found on the PATH
sudo ln -s "${HOME}/julia-1.6.2/bin/julia" "/usr/bin/julia"

# Add Julia executable to the PATH in `.bashrc`
# echo 'export PATH="${PATH}:${HOME}/julia-1.6.2/bin"' >> .bashrc

# Add Julia executable to the PATH
# export PATH="${PATH}:${HOME}/julia-1.6.2/bin"
```


## Installing Genie Web Application
Next, we can install our Genie web application from GitHub.

```bash
GH_USER="jaantollander"
GH_REPO="GenieWebApp.jl"

# Clone the Genie application from the GitHub repository to HOME directory
git clone "https://github.com/${GH_USER}/${GH_REPO}.git" ${HOME}/${GH_REPO}

# Define application directory
export GENIE_APP="${HOME}/${GH_REPO}"

# Change directory to GenieWebApp.jl
cd ${GENIE_APP}

# Install GenieWebApp.jl as Julia package
julia -e "using Pkg; Pkg.activate(\".\"); Pkg.instantiate(); Pkg.precompile(); "

# Setup Genie environment variables
export GENIE_ENV="prod"
export EARLYBIND="true"

# Give execution privileges to `bin/server` script
chmod +x ./bin/server
```

Next, we need to create a new [Linux Screen](https://linuxize.com/post/how-to-use-linux-screen/) for running the web server as a background process.

```bash
screen -S genie
```

In `config/env/prod.jl`, set `server_handle_static_files: false`.

On the new screen, let's execute the`./bin/server` script to start a server.

```bash
cd ${GENIE_APP}
./bin/server
```

We can exit the screen by holding `Ctrl` and pressing `a` and then `d` key. We can retach the screen again by using the `screen -r genie` command if we need to.


## Installing and Configuring Nginx Server
We can install [Nginx](https://www.nginx.com/) on Ubuntu using the Advanced Package Tool (APT).

```bash
sudo apt-get update --yes
sudo apt-get install nginx --yes
sudo systemctl start nginx
sudo systemctl enable nginx
```

Next, we need to configure Nginx for our Genie application by creating a configuration file to the available sites directory. We can create the file using the `nano` editor.

```bash
sudo nano /etc/nginx/sites-available/genie
```

On the nano editor, add the following Nginx configurations:

```bash
server {
  listen 80;
  listen [::]:80;
  # Use default hostname or custom domain name.
  # `host <public-ip>`
  server_name  vm3814.kaj.pouta.csc.fi;
  root         /home/ubuntu/GenieWebApp.jl/public;
  index        welcome.html;
  # Serve static content via Nginx
  location ~ ^/(css|img|js)/genie {
    root /home/ubuntu/GenieWebApp.jl/public;
  }
  # Serve dynamic content via Genie
  location / {
      proxy_pass http://localhost:8000/;
  }
}
```

Next, we enable the configuration by creating a symbolic link for the configuration file to enable sites directory.

```bash
sudo ln -s /etc/nginx/sites-available/genie /etc/nginx/sites-enabled/genie
```

We should also remove the default site from enabled sites.

```bash
sudo rm -f /etc/nginx/sites-enabled/default
```

Now, we can restart Nginx to make the configuration effective.

```bash
sudo systemctl restart nginx
```

The web application should be available at `http://<public-ip>`.


## Enable HTTPS with Certbot
We can set up HTTPS using [Certbot](https://certbot.eff.org/lets-encrypt/ubuntufocal-nginx) for Nginx on Ubuntu 20.04.

```bash
sudo snap install core; sudo snap refresh core
```

```bash
sudo snap install --classic certbot
```

```bash
sudo ln -s /snap/bin/certbot /usr/bin/certbot
```

```bash
sudo certbot --nginx
```
