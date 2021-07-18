# Genie Web Application with SQL Database
## Introduction
[Julia language](https://julialang.org/) is a relatively new, general-purpose programming language designed to address challenges in technical computing such as the *expression problem* and the *two-language problem*. It addresses the expression problem using multiple-dispatch as a paradigm that enables highly expressive syntax and composable code and the two-language problem using just-in-time compilation to create high-performance code. For these reasons, the Julia language is gaining popularity in scientific computing and data analysis because it offers significant improvements in performance and composability. That is, how existing code and libraries work with one another.

Traditionally, scientific computing programs run without user interaction as batch jobs on computer clusters and supercomputers such as [CSC Puhti or Mahti](https://docs.csc.fi/computing/overview/). However, modern scientific computing and data analytics increasingly requires user interaction. For example, an analytics application may receive data from multiple sources over the internet, process the data, perform analysis, store results, and offer them to end-users on demand via an API. We can expose the analytics application over the internet as an on-demand service by wrapping it inside a web application or microservice, containerizing it, and deploying it into a cloud platform. Given the advantages of the Julia language, it would be natural to develop the analytics application and the web application or microservice around the application in Julia.

In this repository, we explore how to build a Julia web application using the [**Genie framework**](https://genieframework.com/), create a [**Docker**](https://www.docker.com/) container for the application, and deploy it on [**CSC Rahti**](https://rahti.csc.fi/), a container cloud operated by [CSC](https://www.csc.fi/en/), the Science Center for IT in Finland. We have structured the sections in the following way:

1. **Develop a web application**: We begin by explaining how to create a web application with Genie, a full-stack Model-View-Controller (MVC) web framework similar to Ruby-on-Rails and Django. Then, we explore how the MVC web application operates and create a [REST API](https://restfulapi.net/). For a more general overview of best practices of developing web applications, we recommend [The Twelve-Factor App](https://12factor.net/) guidelines. As a side note, it is also possible to develop Julia [microservices](https://www.youtube.com/watch?v=uLhXgt_gKJc) without using a framework if you need more control over your application.

2. **Containerize the application**: Next, we explain how to create a Docker container for the application and build and run a container image. Modern cloud architecture revolves around containers and container orchestration. We recommend reading the articles on [Demystifying Containers](https://github.com/saschagrunert/demystifying-containers) to understand how containers work in Linux.

3. **Deploy the containerized application to a cloud platform**: Then, we can deploy the container image on the cloud. We demonstrate how to deploy the application and set up persistent storage with OpenShift on CSC Rahti.

We assume basic knowledge of Linux, Git, Julia language, and SQL databases. We recommend that you try to run and deploy the web application using the instructions below.


## 1. Developing a Genie Web Application
### Installing Julia Language
We should begin by installing [Julia language](https://julialang.org/) from their website and add the julia binary to the path. On the project directory, we can open the Julia REPL with `julia` command.

### Creating MCV Application
We can create a new Genie Model-View-Controller (MCV) application using Genie's generator. The structure for this application is generated as follows:

```julia
using Genie; Genie.newapp_mvc("WebAppDB")
```

The generator creates file structure, configurations and adds database support. We use the [SQLite](https://www.sqlite.org/index.html) database for development, testing, and production.

### Running the Application Locally
We should `instantiate` the web application to install it locally with Julia's built-in package manager when running it for the first time.

```julia
using Pkg; Pkg.instantiate()
```

Then, we can `activate` the web application.

```julia
using Pkg; Pkg.activate(".")
```

Next, let's import Genie and use the `loadapp` function for developing and running the application.

```julia
using Genie; Genie.loadapp(".")
```

Now, we can use the `up` function to run a local web server.

```julia
up()
```

The local webserver should be running on [http://localhost:8000/](http://localhost:8000/), and we can open it in the browser.

### Adding Items Resource and Routing
We can create new resources using the `new_resource` function. We will create a resource named `Items`.

```julia
Genie.new_resource("Items")
```

The function generates three files for the `Items` resource to [`app/resources/items/`](./app/resources/items) directory:

1. `Items.jl` contains the database models,
2. `ItemsController.jl` contains functions for handling requests by the users, and
3. `ItemsValidator.jl` handles database validation.

Inside `Items.jl`, we have created `Item` model, a mapping between objects in the database and Julia structs.

```julia
import SearchLight: AbstractModel, DbId
import Base: @kwdef

@kwdef mutable struct Item <: AbstractModel
  id::DbId = DbId()
  a::String = ""
  b::Int = 0
end
```

We define routes in the [`routes.jl`](./routes.jl) file, which are mapped to the static files in [`public`](./public) and dynamic resources in [`app/resources`](./app/resources). When a server is running, making a request on a route invokes the corresponding handler function in the resources and returns a response based on its output.

### Database Configurations
Genie stores database configurations to [`db/`](./db) directory. For example, we can add configuration for SQLite on `dev` environment to [`connection.yml`](./db/connection.yml) file as follows:

```yaml
dev:
  adapter: SQLite
  database: data/database.sqlite
  host:
  username:
  password:
  port:
  config:
```

We can set up database tables if they don't exist with the following script.

```julia
using SearchLight
using SearchLightSQLite

# Connect to database
SearchLight.Configuration.load() |> SearchLight.connect
try
    # Run migrations if they don't exist
    SearchLight.Migrations.create_migrations_table()
    SearchLight.Migrations.last_up()
catch
    nothing
end
```

We have added it to the global configurations, [`config/env/global.jl`](./config/env/global.jl).

### Testing Requests with HTTP.jl
We can make requests to the server by accessing URLs in the browser or by sending requests to the server via the HTTP.jl library on the Julia REPL.

```julia
using HTTP
domain = "http://localhost:8000"
```

The `domain` variable should point to the domain where we host our application, such as localhost or server, once we deploy the application.

#### Views
By sending a GET request to the `/items` the server returns the HTML that shows the Items page.

```julia
HTTP.request("GET", "$domain/items")
```

```
HTTP/1.1 200 OK
Content-Type: text/html; charset=utf-8
Server: Genie/1.0.0/Julia/1.6.1
Transfer-Encoding: chunked

<!DOCTYPE html><html lang="en"><head><meta charset="utf-8" /><title>Genie :: The Highly Productive Julia Web Framework</title></head><body><h1>Items</h1><h2>Add Item</h2><form method="POST" enctype="multipart/form-data" action="/items"><input name="a" value placeholder="String" type="text" /><input name="b" value placeholder="Int" type="text" /><input value="Submit" type="submit" /></form><h2>All Items</h2><ul><li>item.a: asd, item.b: 1</li><li>item.a: Hello World, item.b: 2</li></ul></body></html>
```

We can also POST forms programmatically.

```julia
HTTP.request("POST", "$domain/items",
    [],
    HTTP.Form(Dict("a"=>"Hello World", "b"=>"1")))
```

```
HTTP/1.1 200 OK
Content-Type: multipart
Server: Genie/1.18.1/Julia/1.6.1
Transfer-Encoding: chunked

...
```

#### API
We have also implemented a JSON-based REST API on the application on the path `/api/items`. REST APIs are intended purely for programmatic use and access to the application.

If we send a GET request to the `/api/items` path, we receive a JSON object as a response.

```julia
HTTP.request("GET", "$domain/api/items")
```

```
HTTP/1.1 200 OK
Content-Type: application/json; charset=utf-8
Server: Genie/1.0.0/Julia/1.6.1
Transfer-Encoding: chunked

[{"id":{"value":1},"a":"asd","b":1}]
```

We can also send a JSON-formatted POST request to the `/api/items`, which will be parsed into a Julia dictionary by the application.

```julia
HTTP.request("POST", "$domain/api/items",
    [("Content-Type", "application/json")],
    """{"a":"Hello World", "b":"1"}""")
```

```
HTTP/1.1 200 OK
Content-Type: application/json; charset=utf-8
Server: Genie/1.18.1/Julia/1.6.1
Transfer-Encoding: chunked
```


## 2. Creating a Docker Container
### Creating a Dockerfile
[`Dockerfile`](./Dockerfile) defines how Docker builds a container image. We should also create a [`.dockerignore`](./.dockerignore) file which instructs Docker to ignore certain files such as automatically-generated files or version control (Git) files from the Docker image.

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


## 3. Deploying a Container Image on CSC Rahti
> These instructions are written for Rahti with **OKD3**. The instructions need to be updated once **OKD4** is released.

### Creating a CSC Project
We should create a new project on [**My CSC**](https://my.csc.fi) and [apply for access to Rahti](https://docs.csc.fi/cloud/rahti/access/).

### Pushing the Docker Image to Rahti Container Registry
To push the Docker image to [**Rahti Container Registry**](https://registry-console.rahti.csc.fi/), we should log in and create a new project. Then, you can log in on the command line using the token provided by the web client.

```bash
sudo docker login -p <token> -u unused docker-registry.rahti.csc.fi
```

Next, we should tag the locally built Docker image. Substitute `<name>` and `<tag>` with the same values as for the Docker image and `<project>` with the name of your Rahti project.

```bash
sudo docker tag <name>:<tag> docker-registry.rahti.csc.fi/<project>/<name>:<tag>
```

Now, we can push the image to the Rahti Container Registry.

```bash
sudo docker push docker-registry.rahti.csc.fi/<project>/<name>:<tag>
```

After we have uploaded the image, we are ready to deploy it.

### Deploying the Container Image from Rahti Console
After uploading a container image, we can log in to [**Rahti Web User Interface**](https://rahti.csc.fi:8443/) and deploy the image from the Rahti Container Registry by selecting `Deploy Image`. Then, we should create a new route by selecting `Create Route`, giving the route name, and selecting `Secure Route` to enforce a secure connection via HTTPS. Our application should now be available under the address `https://route-project.rahtiapp.fi`.

### Setting Up Persistent Storage from Rahti Console
We can set up [persistent storage](https://docs.csc.fi/cloud/rahti/storage/persistent/) to `data` directory inside the application from [**Rahti Web User Interface**](https://rahti.csc.fi:8443/) as follows:

1. Select a project from *My Projects* or create a new project.
2. Select *Storage* and then *Create Storage* with the following parameters:
    - *Storage class*: `glusterfs-storage`
    - *Name*: `genie-data`
    - *Access Mode*: `Shared Access (RWX)`
3. Then select *Applications* > *Deployments*, then your Genie application deployment. The from *Actions* menu, select *Add Storage* with the following parameters:
    - *Storage*: `genie-data`
    - *Mount path*: `/home/genie/app/data`

Application on Docker container is mounted to `/home/genie/app/`.
