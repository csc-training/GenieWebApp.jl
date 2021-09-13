# Creating a Container for the Application
## Installing a Container Manager
We can use either [Docker](https://www.docker.com/) or [Podman](https://podman.io/) for managing containers. Both of them use OCI compliant containers, and their CLIs are compatible with each other. We should begin by [installing Docker](https://docs.docker.com/get-docker/) or [installing Podman](https://podman.io/getting-started/installation) by following the instructions on their website. We recommend using Podman instead of Docker due to its daemon-less design and ability to run rootless mode. You can read more in the article [Transitioning from Docker to Podman](https://developers.redhat.com/blog/2020/11/19/transitioning-from-docker-to-podman).


## Ignoring Files from the Container
The container image needs to ignore files that it does not need to function, such as local project files, automatically-generated files, or version control files from the container image. We can ignore files by creating a `.dockerignore` file, which works for Genie applications. Docker's documentation is a great [reference for Dockerfiles](https://docs.docker.com/engine/reference/builder/).

```plaintext
## Julia Project
README.md
Manifest.toml
test
docs

## Genie
config/secrets.jl
data
log

## Git
.git
.gitignore
.gitattributes
*.gitkeep
.github
```


## Creating the Container File
We also need to create a configuration for the container image. Below, we explain how to create a `Dockerfile` to define how container engine builds a container image. We will start by using a [Julia container image](https://hub.docker.com/_/julia) as the base image.

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


## Building and Running the Container
If you are using Docker, use the `docker` command as below. If you are using Podman, you should substitute `docker` with `podman`. Now, we can build a container image locally using the `build` command. The option `-t` defines the name and tag for the image in the format `<name>:<tag>`.

```bash
sudo docker build -t genie:latest .
```

After building the image, we can run it locally with the `run` command. The option `-p` publishes the container port `8000` to host post `8000` in format `<container-port>:<host-port>`.

```bash
sudo docker run -it -p 8000:8000 --rm genie:latest
```

The local web server should be running on [http://localhost:8000/](http://localhost:8000/), and we can open it in the browser.
