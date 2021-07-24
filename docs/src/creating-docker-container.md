# Creating a Docker Container
### Creating a Dockerfile
`Dockerfile` defines how Docker builds a container image. We should also create a `.dockerignore` file which instructs Docker to ignore certain files such as automatically-generated files or version control (Git) files from the Docker image.

We use `julia:1.6-buster` as the base image.

```Dockerfile
FROM julia:1.6-buster
```

Then, we create `genie` user inside the container.

```Dockerfile
RUN useradd --create-home --shell /bin/bash genie
```

Next, we create `app` directory inside the `/home/genie` directory, copy the application files into it while ignoring files specified in `.dockerignore`, and change our working directory to it.

```Dockerfile
RUN mkdir /home/genie/app
COPY . /home/genie/app
WORKDIR /home/genie/app
```

Next, we give read, write and execution permissions and change ownership to the `genie` user with `root` group for the specified files. OpenShift requires permissions for the `root` group.

```Dockerfile
RUN chgrp root /home/genie
RUN chown genie:root -R *
RUN chmod -R g+rw /home/genie/app
RUN chmod g+rwX bin/server
RUN chmod -R g+rwX /usr/local/julia
```

Now, we change the user to `genie` with `root` group.

```Dockerfile
USER genie:root
```

We specify environment variables for the Genie application with the `ENV` directive.

```Dockerfile
ENV JULIA_DEPOT_PATH "/home/genie/.julia"
ENV GENIE_ENV "prod"
ENV HOST "0.0.0.0"
ENV PORT "8000"
ENV EARLYBIND "true"
```

Now, we can install the application as a Julia package inside the container.

```Dockerfile
RUN julia -e "using Pkg; Pkg.activate(\".\"); Pkg.instantiate(); Pkg.precompile(); "
```

We can remove the Julia registries afterward to reduce the container size.

```Dockerfile
RUN rm -rf /genie/.julia/registries
```

We also need to give the `root` group execution permissions for files inside the `.julia` directory.

```Dockerfile
RUN chmod -R -f g+rwX \
    /home/genie/.julia/packages \
    /home/genie/.julia/artifacts \
    /home/genie/.julia/compiled \
    /home/genie/.julia/logs
```

We will expose the container to networking using port `8000` via TCP.

```Dockerfile
EXPOSE 8000/tcp
```

Finally, we set the container to execute the `bin/server` script to start the webserver when we run the container.

```Dockerfile
CMD ["bin/server"]
```

### Building a Docker Image Locally
We should begin by [installing Docker](https://docs.docker.com/get-docker/). Then, we can build a Docker image locally using the `build` command. The option `-t` defines the name and tag for the image. We can substitute the `<name>` with a name such as `genie` and `<tag>` with `dev`.

```bash
sudo docker build -t <name>:<tag> .
```

After building the image, we can run it locally with the `run` command. The option `-p` publishes the container port `8000` to host post `8000` in this order.

```bash
sudo docker run -it -p 8000:8000 --rm <name>:<tag>
```

The local webserver should be running on [http://localhost:8000/](http://localhost:8000/), and we can open it in the browser.
