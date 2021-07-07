using Genie.Router
using ItemsController

route("/") do
  serve_static_file("welcome.html")
end

route("/items/show", ItemsController.items_show)
route("/items/form", ItemsController.items_form)
route("/items/form", method = POST, ItemsController.items_form_payload)

route("/api/items", ItemsController.items_api)
route("/api/items", method = POST, ItemsController.items_api_payload)
