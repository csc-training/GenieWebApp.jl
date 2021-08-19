# Setting up a Virtual Machine via Command Line Interface
## Setting up the OpenStack Client
We can install the OpenStack client using Python. Let's install the [Miniconda](https://docs.conda.io/en/latest/miniconda.html) package manager which includes Python.

```bash
python --version
```

```text
Python 3.9.1
```

Now, we can install the client using `pip`.

```bash
pip install python-openstackclient
```

Check your installation by calling OpenStack with version flag.

```bash
openstack --version
```

```text
openstack 5.5.0
```

Download [RC file](https://pouta.csc.fi/dashboard/project/api_access/openrc/) using the Web User Interface. Then, activate the script.

```bash
source <project-name>-openrc.sh
```

The prompt will ask your CSC username and password.


## Configuring SSH Keys
Create a new for your SSH key.

```bash
KEY_NAME="openstack-mydevice"
```

Create `.ssh` directory to your home directory with read and write privileges for the user.

```bash
mkdir -p ~/.ssh
chmod 700 ~/.ssh
```

We can list files and directories on our home directory and select `.ssh` directory using the command `ls -la ~ | grep ssh`. Output should be similar to the text below.

```text
drwx------.  2 <user> <group> 4096 Aug 18 08:17 .ssh
```

Now, we can create the key pair with OpenStack client and store it into the `.ssh` directory.

```bash
openstack keypair create $KEY_NAME > ~/.ssh/$KEY_NAME.pem
```

We should also protect the SSH key with a password.

```bash
ssh-keygen -p -f ~/.ssh/$KEY_NAME.pem
```

Finally, change the key to read-only.

```bash
chmod 400 ~/.ssh/$KEY_NAME.pem
```

We can verify the privileges of the key using the command `ls -la ~/.ssh | grep $KEY_NAME.pem`. Output should be similar to the text below.

```text
-r--------.  1 <user> <group> 1676 Aug 17 08:51 $KEY_NAME.pem
```


## Creating a Virtual Machine
To select which virtual machine we want to use, we can list the available images in YAML format as below. We use YAML format because it is easy to read and concise.

```bash
openstack image list -f yaml
```

Similarly, we can list the available flavors.

```bash
openstack flavor list -f yaml
```

Next, we should define a name for our virtual machine.

```bash
SERVER_NAME="genie"
```

Now, we will choose to create a virtual machine with *Ubuntu 20.04* image, with *standard tiny* flavor using the previously defined name and SSH key.

```bash
openstack server create $SERVER_NAME \
    --image="Ubuntu-20.04" \
    --flavor="standard.tiny" \
    --key-name=$KEY_NAME
```

We can list all of our virtual machines as below.

```bash
openstack server list -f yaml
```


## Configuring Security Groups
### Creating SSH Group
We will name the SSH group `SSH`.

```bash
SSH_GROUP="SSH"
```

Now, we can create a new security group with the name.

```bash
openstack security group create $SSH_GROUP
```

For security reasons we want that only our IP address can connect to the virtual machine with SSH. We can retrieve our IP address and bind it to a variable from the command line as follows.

```bash
REMOTE_IP=`curl https://ifconfig.me`
```

Finally, we can add a new rule to the `SSH` security group, which allows only SSH connections from our IP address to the virtual machine.

```bash
openstack security group rule create $SSH_GROUP \
    --proto="tcp" \
    --remote-ip="$REMOTE_IP/32" \
    --dst-port="22"
```

### Creating HTTP Group
We will name the HTTP group as `HTTP`.

```bash
HTTP_GROUP="HTTP"
```

Now, we can create the HTTP group.

```bash
openstack security group create $HTTP_GROUP
```

Finally, we will add a rule that allows traffic from all IPs to the port 80, the default for HTTP traffic.

```bash
openstack security group rule create $HTTP_GROUP \
    --proto="tcp" \
    --remote-ip="0.0.0.0/0" \
    --dst-port="80"
```

### Creating HTTPS Group
We will name the HTTPS group as `HTTPS`.

```bash
HTTPS_GROUP="HTTPS"
```

Now, we can create the HTTPS group.

```bash
openstack security group create $HTTPS_GROUP
```

Finally, we will add a rule that allows traffic from all IPs to the port 443, the default for HTTPS traffic.

```bash
openstack security group rule create $HTTPS_GROUP \
    --proto="tcp" \
    --remote-ip="0.0.0.0/0" \
    --dst-port="443"
```

### Adding Groups to Virtual Machine
Finally, we can add the security groups to our virtual machine.

```bash
openstack server add security group $SERVER_NAME $SSH_GROUP
openstack server add security group $SERVER_NAME $HTTP_GROUP
openstack server add security group $SERVER_NAME $HTTPS_GROUP
```


## Configuring a Floating IP
We can create a floating IP as below.

```bash
openstack floating ip create public -f yaml
```

The YAML formatted output will look similar to the text below.

```yaml
created_at: '2021-08-18T08:22:13Z'
# ...
floating_ip_address: 128.214.252.233
floating_network_id: 26f9344a-2e81-4ef5-a018-7d20cff891ee
id: 826e990f-220f-4c2c-b41a-c5205b314267
name: 128.214.252.233
# ...
```

Alternatively, we can list all of our floating IPs.

```bash
openstack floating ip list -f yaml
```

Output will look similar to the text below.

```yaml
- Fixed IP Address: null
  Floating IP Address: 128.214.252.233
  Floating Network: 26f9344a-2e81-4ef5-a018-7d20cff891ee
  ID: 826e990f-220f-4c2c-b41a-c5205b314267
  Port: null
  Project: 418d555e93d04a1688f305ee19d41e56
```

Now, we can choose the created floating IP, by copying the value from the `floating_ip_address` or `Floating IP Address` field.

```bash
FLOATING_IP="128.214.252.233"
```

Finally, let's associate the floating IP with our virtual machine.

```bash
openstack server add floating ip $SERVER_NAME $FLOATING_IP
```


## Configuring Persistent Storage
We can create a persistent storage for our virtual machine. Let's start by naming it.

```bash
VOLUME_NAME="genie-volume"
```

Now, we will create a persistent storage with size of 1 GB.

```bash
openstack volume create $VOLUME_NAME \
    --description="genie volume" \
    --size=1
```

Finally, we can attach the storage to our virtual machine.

```bash
openstack server add volume $SERVER_NAME $VOLUME_NAME
```
