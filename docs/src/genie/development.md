# Building an MVC Application
## Introduction
This page explores how to build an MCV application from scratch with Genie framework similar to [csc-training/GenieWebApp.jl](https://github.com/csc-training/GenieWebApp.jl). Of course, you can clone the ready-made application and play with it. However, we recommend building your application from scratch and mimicking individual elements from the ready-made application to learn how web applications operate, which will help you to understand cloud computing better.


## Installing the Julia Language
We should begin by installing [**Julia language**](https://julialang.org/) from their website and add the julia binary to the path. Then, on the project directory, we can open the Julia REPL with `julia` command. The Julia REPL has four different modes:

1) The Julia mode `julia>` for executing Julia code.
2) The package manager mode `pkg>` for executing package manager commands. We can activate it by pressing the right square bracket key `]`.
3) The help mode `help?>` for printing help and documentation. We can activate it by pressing the question mark key `?`.
4) The shell mode `shell>` for executing shell commands. We can activate it by pressing the semicolon key `;`.

We can press backspace to exit back to Julia mode. In this tutorial, we use the Julia and package manager modes.

## Code Editor for Julia
As a code editor, we recommend using [Julia for Visual Studio Code](https://www.julia-vscode.org/). First, we need to add the path to our Julia executable to the JSON settings, which we can open with the command `Open Settings JSON`. You need to replace the path below with your path.

```json
{
  // ... other settings ...
  "julia.executablePath": "~/bin/julia-1.6.1/bin/julia",
}
```


## Installing Genie Package
Next, we can install Genie using Julia's built-in package manager.

```julia-repl
(@v1.6) pkg> add Genie
```


## Generating a New MVC Application
We can create a new Genie Model-View-Controller (MCV) application using Genie's generator.

```julia-repl
julia> using Genie
julia> Genie.newapp_mvc("GenieWebApp"; autostart=false)
```

Choose `1` for the database options to use the SQLite database for development, testing, and production. Then, the generator creates file structure, configurations and adds database support. Additionally, it is a convention to name Julia packages with `.jl` extension. So let's add the `.jl` extension to the `GenieWebApp` directory.

```julia-repl
julia> mv("GenieWebApp", "GenieWebApp.jl")
```

Now, our Genie application has a directory structure as below.

```plaintext
GenieWebApp.jl
├── app
├── bin
├── bootstrap.jl
├── config
├── db
├── Manifest.toml
├── Project.toml
├── public
├── routes.jl
├── src
└── test
```

Finally, let's change our working directory to the application directory.

```julia-repl
julia> cd("GenieWebApp.jl")
```

Next, let's configure our database connection.


## Configuring Database Connection
Our Genie application stores its database configurations to `db/` directory. There, we can configure SQLite for development, production, and test environments by opening the `db/connection.yml` file and setting the `adapter` and `database` variables as below.

```yaml
dev:
  adapter: SQLite
  database: data/dev.sqlite
  # ...

prod:
  adapter: SQLite
  database: data/prod.sqlite
  # ...

test:
  adapter: SQLite
  database: data/test.sqlite
  # ...
```

If the database file doesn't exist, Genie will create it automatically when we start a server.


## Setting Global Configurations
Configurations executed in all environments are called global configurations stored in the `config/env/global.jl` file. In global configurations, we should include automatically creating secrets file as below.

```julia
using Genie
Genie.Generator.write_secrets_file()
```

Also, we should include automatically configuring database migrations. That is, setting up database tables if they don't exist as below.

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

We are now ready to start developing our application.


## Running the Application
We should instantiate the web application to install it locally with Julia's built-in package manager when running it for the first time. Instantiation will create the `Manifest.toml` file.

```julia-repl
(@v1.6) pkg> instantiate
```

Then, we need to activate the web application so that we can run and develop it.

```julia-repl
(@v1.6) pkg> activate .
```

The package manager mode should change the environment to `GenieWebApp`. We can execute the status command to see the packages installed in the current environment.

```julia-repl
(GenieWebApp) pkg> status
```

```
     Project GenieWebApp v0.1.0
      Status `~/scratch/GenieWebApp.jl/Project.toml`
  [c43c736e] Genie v3.0.0
  [6d011eab] Inflector v1.0.1
  [e6f89c97] LoggingExtras v0.4.7
  [739be429] MbedTLS v1.0.3
  [340e8cb6] SearchLight v1.0.2
  [21a827c4] SearchLightSQLite v1.0.0
  [ade2ca70] Dates
  [56ddb016] Logging
```

Next, let's load our Genie application for developing and running it.

```julia-repl
julia> using Genie
julia> Genie.loadapp(".")
```

Now, we can run a local web server on port `8000`.

```julia-repl
julia> up(8000)
```

We can access the local web server via [`http://localhost:8000/`](http://localhost:8000/). Finally, when we have finished exploring our application, we can shut down the server.

```julia-repl
julia> down()
```


## Supporting JSON
As of version 2.0.0, the Genie framework uses [JSON3.jl](https://github.com/quinnj/JSON3.jl) package for supporting JSON. It requires the [StructTypes.jl](https://github.com/JuliaData/StructTypes.jl) package to map Julia structures and JSON format. Currently, we need to install it manually.

```julia-repl
(GenieWebApp) pkg> add StructTypes
```

We can also verify the version of the installed package.

```julia-repl
(GenieWebApp) pkg> status StructTypes
```

```plaintext
     Project GenieWebApp v0.1.0
      Status `~/scratch/GenieWebApp.jl/Project.toml`
  [856f2bd8] StructTypes v1.7.3
```


## Adding a New Resource
We can create new resources using a Genie generator. For example, we can create a resource named `Items`.

```julia-repl
julia> Genie.newresource("Items")
```

The function generates a directory structure as follows.

```plaintext
app/resources/items/
├── ItemsController.jl
├── Items.jl
├── ItemsValidator.jl
└── views
```

Additionally, it also creates a database migration.

```plaintext
db/migrations/
└── <id>_create_table_items.jl
```

`Items.jl` contains the database models. Inside `Items.jl`, we have created an `Item` model, a mapping between objects in the database and Julia structs. We should write an appropriate migration for the `Item` model to `<id>_create_table_items.jl`.

`ItemsController.jl` contains functions for handling requests by the users. We should create the related view template files to the `views` directory. For example, we might have the following view templates.

```plaintext
app/resources/items/views/
├── item.jl.html
└── item_list.jl.html
```

`ItemsValidator.jl` handles database validation.


## Defining Routes
Routes map requests to static resources in `public/` or controllers that trigger dynamic resources, for example, `ItemsController.jl`. We can define routes in the `routes.jl` file. When a server is running, it requests a route that invokes the corresponding handler function in the resources and returns a response based on its output. After defining routes, our basic application setup is complete.
