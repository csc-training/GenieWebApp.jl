module ItemsController

using Genie.Requests
using Genie.Renderer.Html
using Genie.Renderer.Json
using SearchLight
using Items

"""Show all items."""
function items_show()
    html(:items, :myitems, items = all(Item))
end

"""Show HTML form."""
function items_form()
    html(:items, :itemsform)
end

function items_form_payload()
    postpayload()
end

## --- API ---

"""Get all items as JSON."""
function items_api()
    json(:items, :myitems, items = all(Item))
end

"""Add new item through JSON payload."""
function items_api_payload()
    jsonpayload()
end

end
