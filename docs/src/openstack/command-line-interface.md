# Via Command Line Interface
## Installing
```bash
openstack --version
```

```
openstack 5.5.0
```

```bash
openstack --help
```

```
usage: openstack [--version] [-v | -q] [--log-file LOG_FILE] [-h] [--debug]
                 [--os-cloud <cloud-config-name>]
                 [--os-region-name <auth-region-name>]
...
```


## Creating a Key Pair
```bash
KEY_NAME="openstack-key"
```

```bash
openstack keypair create $KEY_NAME > "$KEY_NAME.pem"
```


## Creating a Server
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
openstack floating ip create public
```

```bash
openstack floating ip list -f yaml
```

```bash
FLOATING_IP="x.x.x.x"
```


## Adding Floating IP to a Server
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
IP_ADDRESS="x.x.x.x"
```

```bash
openstack security group rule create $SSH_GROUP \
    --proto="tcp" \
    --remote-ip=$IP_ADDRESS \
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
    --remote-ip="0.0.0.0" \
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
    --remote-ip="0.0.0.0" \
    --dst-port="443"
```


## Adding Security Groups to a Server
```bash
openstack server add security group $SERVER_NAME $SSH_GROUP
openstack server add security group $SERVER_NAME $HTTP_GROUP
openstack server add security group $SERVER_NAME $HTTPS_GROUP
```


## Deleting a Server
```bash
openstack server delete $SERVER_NAME
```


## Deleting a Floating IP
```bash
openstack floating ip delete $FLOATING_IP
```
