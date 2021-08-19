# Deploying the Application to a Virtual Machine
## Finding Domain Name
We can find out the default hostname of our virtual machine using the `host` command on the public IP address.

```bash
host $FLOATING_IP
```

```
15.253.214.128.in-addr.arpa domain name pointer vm3814.kaj.pouta.csc.fi.
```

We can also configure our own domain name by pointing DNS records to the virtual machine IP address. You read more about [DNS services in cPouta](https://docs.csc.fi/cloud/pouta/additional-services/#dns-services-in-cpouta) in the docs.


## Connecting to the Virtual Machine
Now, we can [connect to our virtual machine](https://docs.csc.fi/cloud/pouta/connecting-to-vm/) using SSH with our SSH key.

```bash
ssh ubuntu@$FLOATING_IP -i ~/.ssh/$KEY_NAME.pem
```


## Attaching the Persistent Volume
Let's begin by creating a file system on the persistent volume.

```bash
sudo mkfs.xfs /dev/vdb
```

Now can mount the persistent volume. Let's define a variable for the mount location, then create a directory to the mount location and finally mount the persistent volume to the mount location.

```bash
VOLUME=/media/volume
sudo mkdir -p $VOLUME
sudo mount /dev/vdb $VOLUME
```

We also need to change the ownership of the volume to the cloud user for reading and writing data.

```bash
sudo chown $USER:$USER $VOLUME
```


## Installing the Julia Language
Once we have connected to the virtual machine via SSH, we need to install Julia language and our Genie web application using the command line. So let's begin by installing the Julia language.

```bash
# Set URL for downloading Julia binaries
JULIA_URL="https://julialang-s3.julialang.org/bin/linux/x64/1.6/julia-1.6.2-linux-x86_64.tar.gz"

# Set name for the downloaded archive
JULIA_ARCHIVE="$HOME/julia.tar.gz"

# Download the Julia language binaries
curl -o $JULIA_ARCHIVE $JULIA_URL

# Uncompress (-z) and extract (-z) files (-f) from archive
tar -x -z -f $JULIA_ARCHIVE

# Remove the archive file after extraction
rm $JULIA_ARCHIVE

# Add symbolic link of Julia executable to /usr/bin so its found on the PATH
sudo ln -s "$HOME/julia-1.6.2/bin/julia" "/usr/bin/julia"
```


## Installing the Genie Application
Next, we can install our Genie web application from GitHub.

```bash
GH_USER="csc-training"
GH_REPO="GenieWebApp.jl"

# Define application directory
export GENIE_APP="$HOME/$GH_REPO"

# Clone the Genie application from the GitHub repository to HOME directory
git clone "https://github.com/$GH_USER/$GH_REPO.git" $GENIE_APP

# Change directory to GenieWebApp.jl
cd $GENIE_APP

# Install GenieWebApp.jl as Julia package
julia -e "using Pkg; Pkg.activate(\".\"); Pkg.instantiate(); Pkg.precompile(); "

# Setup Genie environment variables
export GENIE_ENV="prod"
export EARLYBIND="true"

# Give execution privileges to `bin/server` script
chmod +x ./bin/server
```

We should also link the `data` and `log` directories inside the Genie application to the persistent volume with symbolic links.

```bash
sudo mkdir -p $VOLUME/data
sudo ln -s $VOLUME/data $GENIE_APP/data
```

```bash
sudo mkdir -p $VOLUME/log
sudo ln -s $VOLUME/log $GENIE_APP/log
```


## Running the Genie Application
Next, we need to create a new [Linux Screen](https://linuxize.com/post/how-to-use-linux-screen/) for running the web server as a background process.

```bash
screen -S genie
```

Then, let's change our working directory to the Genie application directory.

```bash
cd $GENIE_APP
```

We will use a reverse proxy (Nginx) to serve static files and route dynamic content to Genie server. For this reason, modify configuration settings in the production environment in `config/env/prod.jl` such that the Genie server does not handle static files.

```julia
const config = Settings(
  server_port                     = 8000,
  server_host                     = "0.0.0.0",
  log_level                       = Logging.Error,
  log_to_file                     = true,
  # set to false when using reverse proxy
  server_handle_static_files      = false
)
```

On the new screen, let's execute the`./bin/server` script to start a server.

```bash
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

On the Nano editor, add the following Nginx configurations:

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
  location ~ ^(error-*.html|favicon.ico|robots.txt) {
    root /home/ubuntu/GenieWebApp.jl/public;
  }
  # Serve dynamic content via Genie
  location / {
      proxy_pass http://localhost:8000/;
  }
}
```

Next, we enable the configuration by creating a symbolic link for the configuration file to enable the sites directory.

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

The web application should be available via HTTP.


## Enabling HTTPS with Certbot
We can set up HTTPS for Nginx on Ubuntu 20.04 using [Certbot](https://certbot.eff.org/lets-encrypt/ubuntufocal-nginx). Before installing Certbot, we need to ensure that we have the latest version of the Snap package manager which comes preinstalled on Ubuntu 20.04.

```bash
sudo snap install core; sudo snap refresh core
```

We can install Certbot via Snap in classic mode.

```bash
sudo snap install --classic certbot
```

Next, we make `certbot` command available in the command line by creating a symbolic link of the `certbot` executable to `/usr/bin`.

```bash
sudo ln -s /snap/bin/certbot /usr/bin/certbot
```

Now, we can use Certbot to retrieve a certificate and edit our Nginx configuration, turning on HTTPS access in a single step.

```bash
sudo certbot --nginx
```

The web application should now be available via HTTPS.
