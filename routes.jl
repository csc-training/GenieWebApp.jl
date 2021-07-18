using Genie.Router
using Genie.Requests
using ItemsController

route("/") do
  serve_static_file("welcome.html")
end

route("/items", () -> items(Val(:view), Val(:GET)); method = GET, named = :items_get)
route("/items", () -> items(Val(:view), Val(:POST)); method = POST)

route("/items/:id", () -> items(Val(:view), Val(:GET), payload(:id)); method = GET)
route("/items/:id", () -> items(Val(:view), Val(:POST), payload(:id)); method = POST)

route("/api/items", () -> items(Val(:api), Val(:GET)); method = GET)
route("/api/items", () -> items(Val(:api), Val(:POST)); method = POST)
