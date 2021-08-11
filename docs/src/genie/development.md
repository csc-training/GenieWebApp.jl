# Developing the Application
## Installing Julia Language
We should begin by installing [Julia language](https://julialang.org/) from their website and add the julia binary to the path. On the project directory, we can open the Julia REPL with `julia` command.


## Creating MCV Application
We can create a new Genie Model-View-Controller (MCV) application using Genie's generator. The structure for this application is generated as follows:

```julia
using Genie; Genie.newapp_mvc("GenieWebApp")
```

The generator creates file structure, configurations and adds database support. We use the SQLite database for development, testing, and production.


## Running the Application Locally
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

Now, we can use the `up` function to run a local web server on port `8000`.

```julia
up(8000)
```

The local webserver should be running on [http://localhost:8000/](http://localhost:8000/), and we can open it in the browser.


## Adding Resources and Routing
We can create new resources using the `new_resource` function. We will create a resource named `Items`.

```julia
Genie.new_resource("Items")
```

The function generates three files for the `Items` resource to `app/resources/items/` directory:

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

We define routes in the `routes.jl` file, which are mapped to the static files in `public/` and dynamic resources in `app/resources/`. When a server is running, making a request on a route invokes the corresponding handler function in the resources and returns a response based on its output.


## Configuring a Database
Genie stores database configurations to `db/` directory. For example, we can add configuration for SQLite on `dev` environment to `db/connection.yml` file as follows:

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

We have added it to the global configurations, `config/env/global.jl`.
