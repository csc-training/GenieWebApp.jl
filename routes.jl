using Genie.Router
using ItemsController

route("/") do
  serve_static_file("welcome.html")
end

route("/items", () -> items(Val(:view), Val(:GET)); method = GET, named = :items_get)
route("/items", () -> items(Val(:view), Val(:POST)); method = POST)

route("/api/items", () -> items(Val(:api), Val(:GET)); method = GET)
route("/api/items", () -> items(Val(:api), Val(:POST)); method = POST)
