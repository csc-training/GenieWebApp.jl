# Testing the Application
## HTTP Basics
As an introduction to HTTP, we recommend reading the [HTTP section of Mozilla Developer Network (MDN)](https://developer.mozilla.org/en-US/docs/Web/HTTP) documentation. Especially, about the structure of HTTP messages, request methods and response status codes.

Let's start a Genie server on port `8000` for our application.

```julia-repl
pkg> activate .
julia> using Genie
julia> Genie.loadapp()
julia> up(8000)
```

We can create requests to the server by accessing URLs in the browser. Alternatively, we can send requests directly to the server using the [HTTP.jl](https://github.com/JuliaWeb/HTTP.jl) library.

```julia-repl
julia> using HTTP
julia> base = "http://localhost:8000"
```

The `base` variable should point to the base URL where we host our application, such as localhost or server where have deployed the application.


## HTML Views
### Listing All Items
By sending a GET request to the `/items` the server returns the HTML that shows the Items page.

```julia-repl
julia> HTTP.request("GET", "$(base)/items")
```

```
HTTP.Messages.Response:
"""
HTTP/1.1 200 OK
Content-Type: text/html; charset=utf-8
Server: Genie/Julia/1.6.1
Transfer-Encoding: chunked

<!DOCTYPE html>..."""
```

### Adding New Items
!!! warning
    Currently, posting forms programmatically does not work for an unknown reason.

We can also POST forms programmatically.

```julia-repl
julia> form = HTTP.Form(Dict("a"=>"Hello World", "b"=>"1"))
julia> HTTP.request("POST", "$(base)/items", [], form)
```


## JSON API
We have also implemented a JSON-based API on the application on the path `/api/items`. The API is intended for programmatic use and access to the application. We will use the [JSON3](https://github.com/quinnj/JSON3.jl) library for encoding Julia data structures into JSON payloads.

```julia-repl
julia> using JSON3
```

Internally, a Genie application maps posted JSON objects to defined Julia data structures.

### Retrieving All Items
We can request all items from the API.

```julia-repl
julia> HTTP.request("GET", "$(base)/api/items")
```

We receive an HTTP response with `application/json` content type in the header and a JSON object in the body.

```
HTTP.Messages.Response:
"""
HTTP/1.1 200 OK
Content-Type: application/json; charset=utf-8
Server: Genie/Julia/1.6.1
Transfer-Encoding: chunked

[{"id":{"value":1},"a":"Hello World","b":1}]"""
```

### Adding New Items
We can also add new item by sending a JSON-formatted payload to the API.

```julia-repl
julia> payload = JSON3.write(Dict(:a=>"Hello World", :b=>1))
julia> HTTP.request("POST", "$(base)/api/items",
           [("Content-Type", "application/json")], payload)
```

```
HTTP.Messages.Response:
"""
HTTP/1.1 201 Created
Content-Type: application/json; charset=utf-8
Server: Genie/Julia/1.6.1
Transfer-Encoding: chunked

"Created""""
```

### Retrieving a Specific Item
We can query a specific item using the API.

```julia-repl
julia> HTTP.request("GET", "$(base)/api/items/1")
```

```
HTTP.Messages.Response:
"""
HTTP/1.1 200 OK
Content-Type: application/json; charset=utf-8
Server: Genie/Julia/1.6.1
Transfer-Encoding: chunked

{"id":{"value":1},"a":"Hello World","b":1}"""
```

### Updating a Specific Item
We can also update a specific item using the API.

```julia-repl
julia> payload = JSON3.write(Dict(:a=>"Hello World Again", :b=>2))
julia> HTTP.request("PUT", "$(base)/api/items/1",
           [("Content-Type", "application/json")], payload)
```

```
HTTP.Messages.Response:
"""
HTTP/1.1 200 OK
Content-Type: application/json; charset=utf-8
Server: Genie/Julia/1.6.1
Transfer-Encoding: chunked

"""""
```

### Removing Specific Item
Finally, we can remove a specific item using the API.

```julia-repl
julia> HTTP.request("DELETE", "$(base)/api/items/1")
```

```
HTTP.Messages.Response:
"""
HTTP/1.1 200 OK
Content-Type: application/json; charset=utf-8
Server: Genie/Julia/1.6.1
Transfer-Encoding: chunked

"Deleted""""
```


## Unit Tests
We can run the unit tests from the package mode in Julia REPL.

```julia-repl
(@v1.6) pkg> activate .
(GenieWebApp) pkg> test
```

The `test` command will execute `test/runtests.jl` script, which sets the Genie environment to `test`, creates a temporary database, loads the application, and runs a server. The unit tests send HTTP requests to the server and check for correct status codes.
