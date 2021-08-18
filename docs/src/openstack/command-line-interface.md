# Setting up a Virtual Machine via Command Line Interface
## Installing the Client
We can install the OpenStack client using Python. Let's install the [Miniconda](https://docs.conda.io/en/latest/miniconda.html) package manager which includes Python.

```bash
python --version
```

```
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

```
openstack 5.5.0
```


## Configuring API Access
Download [RC file](https://pouta.csc.fi/dashboard/project/api_access/openrc/) using the Web User Interface. Then, activate the script.

```bash
source <project-name>-openrc.sh
```


## Creating SSH Keys
```bash
KEY_NAME="openstack-key"
```

```bash
mkdir -p ~/.ssh
chmod 700 ~/.ssh
```

```bash
openstack keypair create $KEY_NAME > ~/.ssh/$KEY_NAME.pem
```

```bash
ssh-keygen -p -f ~/.ssh/$KEY_NAME.pem
```

```bash
chmod 400 ~/.ssh/$KEY_NAME.pem
```


## Creating a Virtual Machine
```bash
openstack image list -f yaml
```

```bash
openstack flavor list -f yaml
```

```bash
SERVER_NAME="genie"
```

```bash
openstack server create $SERVER_NAME \
    --image="Ubuntu-20.04" \
    --flavor="standard.tiny" \
    --key-name=$KEY_NAME
```

```bash
openstack server list -f yaml
```


## Creating a Floating IP
```bash
openstack floating ip create public -f yaml
```

```yaml
created_at: '2021-08-18T08:22:13Z'
# ...
floating_ip_address: 128.214.252.233
floating_network_id: 26f9344a-2e81-4ef5-a018-7d20cff891ee
id: 826e990f-220f-4c2c-b41a-c5205b314267
name: 128.214.252.233
# ...
```

```bash
openstack floating ip list -f yaml
```

```yaml
- Fixed IP Address: null
  Floating IP Address: 128.214.252.233
  Floating Network: 26f9344a-2e81-4ef5-a018-7d20cff891ee
  ID: 826e990f-220f-4c2c-b41a-c5205b314267
  Port: null
  Project: 418d555e93d04a1688f305ee19d41e56
```

```bash
FLOATING_IP="x.x.x.x"
```


## Adding Floating IP
```bash
openstack server add floating ip $SERVER_NAME $FLOATING_IP
```


## Creating Security Groups
### SSH
```bash
SSH_GROUP="SSH"
```

```bash
openstack security group create $SSH_GROUP
```

```bash
REMOTE_IP=`curl ifconfig.me`
```

```bash
openstack security group rule create $SSH_GROUP \
    --proto="tcp" \
    --remote-ip="$REMOTE_IP/32" \
    --dst-port="22"
```

### HTTP
```bash
HTTP_GROUP="HTTP"
```

```bash
openstack security group create $HTTP_GROUP
```

```bash
openstack security group rule create $HTTP_GROUP \
    --proto="tcp" \
    --remote-ip="0.0.0.0/0" \
    --dst-port="80"
```

### HTTPS
```bash
HTTPS_GROUP="HTTPS"
```

```bash
openstack security group create $HTTPS_GROUP
```

```bash
openstack security group rule create $HTTPS_GROUP \
    --proto="tcp" \
    --remote-ip="0.0.0.0/0" \
    --dst-port="443"
```


## Adding Security Groups
```bash
openstack server add security group $SERVER_NAME $SSH_GROUP
openstack server add security group $SERVER_NAME $HTTP_GROUP
openstack server add security group $SERVER_NAME $HTTPS_GROUP
```


## Adding Persistent Storage
```bash
VOLUME_NAME="genie-volume"
```

```bash
openstack volume create $VOLUME_NAME \
    --description="genie volume" \
    --size=1
```

```bash
openstack server add volume $SERVER_NAME $VOLUME_NAME
```


## Connecting to the Virtual Machine
```bash
ssh ubuntu@$FLOATING_IP -i ~/.ssh/$KEY_NAME.pem
```


## Deleting a Server
```bash
openstack server delete $SERVER_NAME
```


## Deleting a Floating IP
```bash
openstack floating ip delete $FLOATING_IP
```


## Deleting Persistent Storage
```bash
openstack server remove volume $SERVER_NAME $VOLUME_NAME
```
