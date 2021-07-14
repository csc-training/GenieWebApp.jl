# Genie Web Application with SQL Database
## Overview
The code in this repository demonstrates the three step for running a Julia web application on container cloud.

1. First step is to create a web application. We create a web application with [**Genie.jl**](https://genieframework.com/), a full-stack MVC web framework similar to Ruby-on-Rails and Django, and use it to demonstrate the common features of web applications.

2. The second step is to create a container for the application and build a container image. We show how to create [**Docker**](https://www.docker.com/) containers for them.

3. Third step is to deploy a container image on cloud. We demonstrate how to deploy the application with OpenShift on [**CSC Rahti**](https://rahti.csc.fi/) container cloud. [CSC](https://www.csc.fi/en/) is the Science Center for IT in Finland. OpenShift is a Kubernetes distribution, hence we should be able to deploy the application on other Kubernetes-based clouds as well.

4. Fourth step is to setup persistent storage for the application.

The best way to understand how web applications and their deployment on the cloud works is to develop and deploy one yourself. We assume basic knowledge of Linux, Git, Julia language and SQL databases.

We believe that there will be a growing interest in running Julia programs on the cloud. Julia language is popular among scientists due to its high performance and expressive syntax. Scientists often run their programs as batch jobs on computer clusters such as [CSC Puhti or Mahti](https://docs.csc.fi/computing/overview/). However, modern scientific computing and data science may require event-driven computing, such as processing data streams from sensors or performing on-demand computations like image manipulation. Therefore, the program has to continuously serve multiple simultaneous users in different geographic locations by processing inputs, performing computations, and producing outputs. We can solve this problem by developing a web application with a REST API for interacting with it.

We can expose the web application to the internet by deploying it on a cloud platform. Modern cloud architecture revolves around containers and container orchestration. We recommend reading the articles on [Demystifying Containers](https://github.com/saschagrunert/demystifying-containers) to understand how containers work in Linux. Additionally, deploying the software on the cloud allows us to offer the *software as a service*, a popular business model where users can pay for access to the software.


## Developing a Genie Web Application
### Creating an Application
We can create a new Genie MCV application using Genie's generator as follows.

```julia
using Genie
Genie.newapp_mvc("WebAppDB")
```

The generator creates file structure, configurations and adds database support. We have chosen to use SQLite database.

### Running the Application Locally
We should install [Julia language](https://julialang.org/) from their website and add the julia binary to the path. On the project directory, we can open the Julia REPL with `julia` command. Then, we can activate the web application with Julia package manager.

```julia
using Pkg; Pkg.activate(".")
```

Next, let's import Genie and use the `loadapp` function with `autostart` option true to run a local web server.

```julia
using Genie; Genie.loadapp(; autostart=true)
```

The local web server should be running on [http://localhost:8000/](http://localhost:8000/) and we can open it in the browser.

### Adding Items Resource
We also have created the `Items` resource using a generator.

```julia
Genie.new_resource("Items")
```

The items are created to [`app/resources/items/`](./app/resources/items) directory.

- `Items.jl`
- `ItemsController.jl`
- `ItemsValidator.jl`

```julia
import SearchLight: AbstractModel, DbId
import Base: @kwdef

@kwdef mutable struct Item <: AbstractModel
  id::DbId = DbId()
  a::String = ""
  b::Int = 0
end
```

TODO: Migrations

### Database Configurations
The generator adds `SearchLight` and `SearchLightSQLite` to dependencies.

Genie stores database configurations to [`db/`](./db) directory. The [`connection.yml`](./db/connection.yml) file stores configurations such as the adapter and database location. For example, `SQLite` and `data/database.sqlite` in this application.

We can setup database tables if they don't exist with the following script.

```julia
using SearchLight
using SearchLightSQLite

SearchLight.Configuration.load() |> SearchLight.connect
try
    SearchLight.Migrations.create_migrations_table()
    SearchLight.Migrations.last_up()
catch
    nothing
end
```

We have added it to the global configurations, [`config/env/global.jl`](./config/env/global.jl).

### Routing and Accessing Resources
We define routes in the [`routes.jl`](./routes.jl) file, which are mapped to the static files in [`public`](./public) and dynamic resources in [`app/resources`](./app/resources). When a server is running, making a request on a route invokes corresponding handler function in the resources and returns a response based on its output.

We can make requests to the server by accessing URLs in the browser or by sending requests to the server via the HTTP.jl library on the Julia REPL.

```julia
using HTTP
domain = "http://localhost:8000"
```

The `domain` variable should point to the domain where we host our application such as localhost or server once we deploy the application.

#### Views
By sending a GET request to the `/items` the server return the HTML that shows the Items page.

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

We can also POST items forms programatically.

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

#### REST API
We have also implemented a JSON-based REST API on the application on the path `/api/items`. REST APIs are intended purely for programmatic use and access to the application.

If we send a GET request to the `/api/items` path we receive a JSON object as a response.

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

We can also send a JSON-formatted POST request to the `/api/items` which will be parsed into a Julia dictionary by the application.

```julia
HTTP.request("POST", "$domain/api/items",
    [("Content-Type", "application/json")],
    """{"a":"Hello World","b":"1"}""")
```

```
HTTP/1.1 200 OK
Content-Type: application/json; charset=utf-8
Server: Genie/1.18.1/Julia/1.6.1
Transfer-Encoding: chunked
```


## Creating a Docker Container
### Creating a Dockerfile
[`Dockerfile`](./Dockerfile) defines how Docker builds a container image. We should also create a [`.dockerignore`](./.dockerignore) file which instructs Docker to ignore certain files such as automatically generated files or version control (Git) files from the Docker image.

### Building a Docker Image Locally
We should begin by [installing Docker](https://docs.docker.com/get-docker/). Then, we can build a Docker image locally using the `build` command. The option `-t` defines the name and tag for the image. We can substitute the `<name>` with name such as `genie` and `<tag>` with `dev`.

```bash
sudo docker build -t <name>:<tag> .
```

After building the image, we can run it locally with the `run` command. The option `-p` publishes the container port `8000` to host post `8000` in this order.

```bash
sudo docker run -it -p 8000:8000 --rm <name>:<tag>
```

The local web server should be running on [http://localhost:8000/](http://localhost:8000/) and we can open it in the browser.


## Deploying a Container Image on CSC Rahti
### Creating a CSC Project
We should create a new project on [**My CSC**](https://my.csc.fi) and [apply for access to Rahti](https://docs.csc.fi/cloud/rahti/access/).

### Pushing the Docker Image to Rahti Container Registry
To push the Docker image to [**Rahti Container Registry**](https://registry-console.rahti.csc.fi/), we should log in and create a new project. Then, can log in on the command-line using the token provided by the web client.

```bash
sudo docker login -p <token> -u unused docker-registry.rahti.csc.fi
```

Next, we should tag the locally built Docker image. Substitute `<name>` and `<tag>` with same values as for the Docker image, and `<project>` with the name of your Rahti project.

```bash
sudo docker tag <name>:<tag> docker-registry.rahti.csc.fi/<project>/<name>:<tag>
```

Now, we can push the image to the Rahti Container Registry.

```bash
sudo docker push docker-registry.rahti.csc.fi/<project>/<name>:<tag>
```

After we have uploaded the image, we are ready to deploy it.

### Deploying the Container Image from Rahti Console
After uploading a container image, we can log in to [**Rahti Web User Interface**](https://rahti.csc.fi:8443/) and deploy the image from the Rahti Container Registry by selecting `Deploy Image`. Then, we should create a new route by selecting `Create Route`, giving the route name and selecting `Secure Route` to enforce secure connection via HTTPS. Our application should now be available under the address `https://route-project.rahtiapp.fi`.

### Setting Up Persistent Storage from Rahti Console
We can set up [persistent storage](https://docs.csc.fi/cloud/rahti/storage/persistent/) to `data` directory inside the application from [**Rahti Web User Interface**](https://rahti.csc.fi:8443/) as follows:

1. Select a project from *My Projects* or create a new project.
2. Select *Storage* and then *Create Storage* with the following parameters:
    - *Storage class*: `glusterfs-storage`
    - *Name*: `genie-data`
    - *Access Mode*: `Shared Access (RWX)`
3. Then select *Applications* > *Deployments*, then your Genie application deployment. The from *Actions* menu, select *Add Storage* with following parameters:
    - *Storage*: `genie-data`
    - *Mount path*: `/home/genie/app/data`

Application on Docker container is mounted to `/home/genie/app/`.
