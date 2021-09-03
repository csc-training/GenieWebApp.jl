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


## Generating a New MCV Application
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

The package manager mode should change to `GenieWebApp` as below.

```julia-repl
(GenieWebApp) pkg>
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

We can access the local web server via [`http://localhost:8000/`](http://localhost:8000/). We are finished exploring our application, we can shut down the server.

```julia-repl
julia> down()
```


## Configuring the Database
Our Genie application stores its database configurations to `db/` directory. We can configure SQLite for `dev`, `prod`, and `test` environments to in `db/connection.yml` file by setting the `adapter` variable to `SQLite`. Additionally, we set the database location to `data/database.sqlite`.

```yaml
<env>:
  adapter: SQLite
  database: data/database.sqlite
```

If they don't exist, we need to set up database tables by adding the script below to global configurations in `config/env/global.jl`.

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

### Model
`Items.jl` contains the database models. Inside `Items.jl`, we have created `Item` model, a mapping between objects in the database and Julia structs.

### Controller
`ItemsController.jl` contains functions for handling requests by the users.

### Validator
`ItemsValidator.jl` handles database validation.

### Views
The `views` directory.

```plaintext
app/resources/items/views/
├── item.jl.html
└── item_list.jl.html
```

### Database Migration
```plaintext
db/migrations/
└── <id>_create_table_items.jl
```


## Defining Routes
We define routes in the `routes.jl` file, mapped to the static files in `public/` and dynamic resources in `app/resources/`. When a server is running, it requests a route that invokes the corresponding handler function in the resources and returns a response based on its output.
