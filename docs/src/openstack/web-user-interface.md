# Setting up a Virtual Machine via Web User Interface
## Login
Once we have access to Pouta, we should log in to the [**Pouta Web User Interface**](https://pouta.csc.fi). Then, we can follow the instructions on [launching a virtual machine in the cPouta web interface](https://docs.csc.fi/cloud/pouta/launch-vm-from-web-gui/).


## Configuring SSH Keys
We can create SSH keys in the web interface by navigating to *Compute*, then *Key Pairs* and selecting *Create Key Pair*. Next, give the key pair name denoted by the variable `KEY_NAME` and save the downloaded `$KEY_NAME.pem` file to your home directory. Then, on the command line, move to the home directory, create `.ssh` directory with read, write and execute privileges for the user if it doesn't exist, and move your key file into it.

```bash
mkdir -p ~/.ssh
chmod 700 ~/.ssh
```

```bash
mv $KEY_NAME.pem ~/.ssh
```

Next, protect the key with a password.

```bash
ssh-keygen -p -f ~/.ssh/$KEY_NAME.pem
```

Then, change the key to read-only.

```bash
chmod 400 ~/.ssh/$KEY_NAME.pem
```


## Creating a Virtual Machine
We will use a virtual machine with the *Ubuntu 20.04* operating system. We can launch a virtual machine by navigating to *Compute*, then *Instances*, and select *Launch Instance*. Set the following parameters:

- In the *Details* tab:
  - *Availability Zone*: `nova`
  - *Instance Name*: `genie`
  - *Flavor*: `standard.tiny`
  - *Number of Instances*: `1`
  - *Instance Boot Source*: `Boot from image`
  - *Image Name*: `Ubuntu-20.04`
- In *Access & Security* tab:
  - *Key Pair*: `$KEY_NAME`
  - *Security Groups*: `default`

Finally, press *Launch*.


## Configuring Security Groups
We can manage internet access to our virtual machine by defining security groups and associating them with the virtual machine. We can set up firewalls and security groups by navigating to *Network*, then *Security Groups*.

### Creating SSH Group
Let's create a new security group by selecting *Create Security Group* and name it `SSH`. Then, select *Manage Rules* for the group and *Add Rule* with the following parameters:

- *Rule*: `Custom TCP Rule`
- *Direction*: `Ingress`
- *Open Port*: `Port`
- *Port*: `22` (Default port for SSH connections.)
- *Remote*: `CIDR`
- *CIDR*: `<ip-address>/32`

Substitute `<ip-address>` with your IP address which you can find out from [ifconfig.me](https://ifconfig.me/). The number after the slash `/` is the CIDR Prefix. You can learn more about the [CIDR subnet mask notation](https://docs.netgate.com/pfsense/en/latest/network/cidr.html) from the Netgate documentation.

### Creating HTTP Group
Next, let's create a security group named `HTTP` and add a rule with parameters.

- *Rule*: `Custom TCP Rule`
- *Direction*: `Ingress`
- *Open Port*: `Port`
- *Port*: `80` (Default port for HTTP connections.)
- *Remote*: `CIDR`
- *CIDR*: `0.0.0.0/0`

### Creating HTTPS Group
Finally, let's create `HTTPS` security group and add the rule with parameters:

- *Rule*: `Custom TCP Rule`
- *Direction*: `Ingress`
- *Open Port*: `Port`
- *Port*: `443` (Default port for HTTPS connections.)
- *Remote*: `CIDR`
- *CIDR*: `0.0.0.0/0`

### Adding Groups to Virtual Machine
We can add security groups to a virtual machine by navigating to the *Compute* menu, then *Instances*, and in selecting *Edit Security Groups* from the menu next to *Create Snapshot*. We should add the `SSH`, `HTTP`, and `HTTPS` groups to our virtual machine. By including the `SSH` security group, we can connect to our virtual machine via SSH. Furthermore, by including `HTTP` and `HTTPS` security groups, we allow traffic from the internet to the web server and application deployed on the virtual machine.


## Configuring a Floating IP
Associating the virtual machine with a floating IP, that is, a public IP, allows users to connect to it with the methods we have set on the security groups. To create and associate a public IP, navigate to the menu next to *Create Snapshot* and select *Associate Floating IP*. Then, on the *IP Address* field, click the *plus* sign to allocate a new floating IP. Once allocated, select the created floating IP and press *Associate*. We denote the value of the floating IP as `FLOATING_IP`.


## Configuring Persistent Storage
We can also [persistent storage](https://docs.csc.fi/cloud/pouta/persistent-volumes/) to the virtual machine by navigating to *Volumes*, then *Volumes*, and selecting *Create Volume* with the following parameters:

- *Volume Name*: `genie`
- *Volume Source*: `No source, Empty volume`
- *Type*: `Standard`
- *Size*: `1 GiB`
- *Availability Zone*: `nova`

From the menu next to *Edit Volume*, select *Manage Attachments* and then attach the volume to the `genie` virtual machine.
