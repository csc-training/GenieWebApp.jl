# Creating an MVC Application
## Installing the Julia Language
We should begin by installing [**Julia language**](https://julialang.org/) from their website and add the julia binary to the path. Then, on the project directory, we can open the Julia REPL with `julia` command. The Julia REPL has four different modes:

1) The Julia mode `julia>` for executing Julia code.
2) The package manager mode `pkg>` for executing package manager commands. We can activate it by pressing the right square bracket key `]`.
3) The help mode `help?>` for printing help and documentation. We can activate it by pressing the question mark key `?`.
4) The shell mode `shell>` for executing shell commands. We can activate it by pressing the semicolon key `;`.

We can press backspace to exit back to Julia mode. In this tutorial, we use the Julia and package manager modes.


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

If the database file doesn't exist, Genie will create it automatically when we start a server. We are now ready to start developing our application.


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

`ItemsController.jl` contains functions for handling requests by the users. We should create the related view files to the `views` directory.

```plaintext
app/resources/items/views/
├── item.jl.html
└── item_list.jl.html
```

`ItemsValidator.jl` handles database validation.


## Defining Routes
We define routes in the `routes.jl` file, mapped to the static files in `public/` and dynamic resources in `app/resources/`. When a server is running, it requests a route that invokes the corresponding handler function in the resources and returns a response based on its output.


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

Now, our basic application setup is complete.
