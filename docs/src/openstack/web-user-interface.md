# Setting up a Virtual Machine via Web User Interface
In this section, we manually configure a virtual machine, connect to it and set up a server. Manual performing these steps is an excellent way to learn how virtual machines work and understand how a web application operates from one. However, we should use containers and configuration management for deploying real production applications instead of manually deploying them.

Once we have access to Pouta, we should log in to the [**Pouta Web User Interface**](https://pouta.csc.fi). Then, we can follow the instructions on [launching a virtual machine in the cPouta web interface](https://docs.csc.fi/cloud/pouta/launch-vm-from-web-gui/).


## Creating SSH Keys
We can create SSH keys in the web interface by navigating to *Compute*, then *Key Pairs* and selecting *Create Key Pair*. Next, give the key pair name denoted by the variable `KEY_NAME` and save the downloaded `$KEY_NAME.pem` file to your home directory. Then, on the command line, move to the home directory, create `.ssh` directory with write privileges if it doesn't exist, and move your key file into it.

```bash
cd ~
mkdir -p .ssh
chmod 700 .ssh
mv $KEY_NAME.pem .ssh
```

Next, protect the key with a password and make it read-only.

```bash
ssh-keygen -p -f .ssh/$KEY_NAME.pem
chmod 400 .ssh/$KEY_NAME.pem
```


## Creating Security Groups
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


## Creating a Virtual Machine
We will use a virtual machine with the *Ubuntu 20.04* operating system. We can launch a virtual machine by navigating to *Compute*, then *Instances*, and select *Launch Instance*. Set the following parameters and press *Launch*:

- In the *Details* tab:
  - *Availability Zone*: `nova`
  - *Instance Name*: `genie`
  - *Flavor*: `standard.tiny`
  - *Number of Instances*: `1`
  - *Instance Boot Source*: `Boot from image`
  - *Image Name*: `Ubuntu-20.04`
- In *Access & Security* tab:
  - *Key Pair*: `$KEY_NAME`
  - *Security Groups*: `SSH`, `HTTP`, `HTTPS`

By including the `SSH` security group, we can connect to our virtual machine via SSH. Furthermore, by including `HTTP` and `HTTPS` security groups, we allow traffic from the internet to the web server and application deployed on the virtual machine.


## Adding a Floating IP
Associating the virtual machine with a floating IP (public IP) allows users to connect to it with the methods we have set on the security groups. To create and associate a public IP, navigate to the menu next to *Create Snapshot* and select *Associate Floating IP*. Then, on the *IP Address* field, click the *plus* sign to allocate a new floating IP. Once allocated, select the created floating IP and press *Associate*. We denote the value of the floating IP as `FLOATING_IP`.


## Adding Persistent Storage
We can also [persistent storage](https://docs.csc.fi/cloud/pouta/persistent-volumes/) to the virtual machine by navigating to *Volumes*, then *Volumes*, and selecting *Create Volume* with the following parameters:

- *Volume Name*: `genie`
- *Volume Source*: `No source, Empty volume`
- *Type*: `Standard`
- *Size*: `1 GiB`
- *Availability Zone*: `nova`

From the menu next to *Edit Volume*, select *Manage Attachments* and then attach the volume to the `genie` virtual machine.


## Domain Name
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
