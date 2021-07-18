using Genie.Router
using Genie.Requests
using ItemsController: items

route("/") do
  serve_static_file("welcome.html")
end

route("/items", () -> items(Val(:view), Val(:GET)); method = GET, named = :get_items)
route("/items", () -> items(Val(:view), Val(:POST)); method = POST, named = :post_items)

route("/items/:id", () -> items(Val(:view), Val(:GET), payload(:id)); method = GET, named = :get_items_id)
route("/items/:id", () -> items(Val(:view), Val(:POST), payload(:id)); method = POST, named = :post_items_id)

route("/api/items", () -> items(Val(:api), Val(:GET)); method = GET, named = :get_api_items)
route("/api/items", () -> items(Val(:api), Val(:POST)); method = POST, named = :post_api_items)
