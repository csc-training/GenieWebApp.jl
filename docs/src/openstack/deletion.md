# Deleting the Application and Virtual Machine
We can delete our application once we no longer need it.

## Command Line Interface
First, we need to connect to the virtual machine, stop the Genie application and Nginx, and then unmount the persistent storage volume.

```bash
sudo umount /dev/vdb
```

Then, let's disconnect from the virtual machine. Now, we can detach the persistent storage from the virtual machine.

```bash
openstack server remove volume $SERVER_NAME $VOLUME_NAME
```

Next, we can remove the virtual machine.

```bash
openstack server delete $SERVER_NAME
```

Finally, we can remove the floating IP.

```bash
openstack floating ip delete $FLOATING_IP
```

Additionally, we can remove the persistent storage. Removing the persistent storage will destroy the database and logs.

```bash
openstack volume delete $VOLUME_NAME
```

Now, we have deleted the application and virtual machine.
