# Genie Web Application with SQLite Database
In this demo, we extend the [genie-webapp](https://github.com/jaantollander/genie-webapp) Genie.jl application with SQLite database.

## Creating MVC application with SQLite Database
We have generated the MVC application using the Genie generator.

```julia
using Genie
Genie.newapp_mvc("WebAppDB")
```

The generator adds `SearchLight` and `SearchLightSQLite` to dependencies.

Genie stores database configurations to [`db/`](./db) directory. The [`connection.yml`](./db/connection.yml) file stores configurations such as the adapter and database location. For example, `SQLite` and `data/database.sqlite` in this application.


## Items Resource
We also have created the `Items` resource using a generator.

```julia
Genie.new_resource("Items")
```

The items are created to [`app/resources/items/`](./app/resources/items) directory.

TODO: `Items.jl`

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


## Configurations
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


## Setting Up Persistent Storage to Rahti
We can set up [persistent storage](https://docs.csc.fi/cloud/rahti/storage/persistent/) to `data` directory inside the application from [**Rahti Web User Interface**](https://rahti.csc.fi:8443/) as follows:

1. *Select Project*
2. *Storage* > *Create Storage*
    - *Storage class*: `glusterfs-storage`
    - *Name*: `genie-data`
    - *Access Mode*: `Shared Access (RWX)`
3. *Application* > *Pods*
    1. *Select Pod*
    2. *Actions* > *Add Storage*
    3. *Mount path*: `/home/genie/app/data`

Application on Docker container is mounted to `/home/genie/app/`.
