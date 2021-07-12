using Genie.Router
using ItemsController

route("/") do
  serve_static_file("welcome.html")
end

route("/items", ItemsController.items_get; method = GET)
route("/items", ItemsController.items_post; method = POST)
# route("/items/", ItemsController.items_delete; method = DELETE)

route("/api/items", ItemsController.items_api_get; method = GET)
route("/api/items", ItemsController.items_api_post; method = POST)
# route("/api/items", ItemsController.[...]; method = DELETE)
