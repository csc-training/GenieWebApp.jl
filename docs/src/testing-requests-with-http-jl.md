# Testing Requests with HTTP.jl
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

<!DOCTYPE html><html lang="en">...</html>
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
