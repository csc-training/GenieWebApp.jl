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
    d = postpayload()
    @show d
    try
        item = Item(a=d[:a], b=d[:b])
        save(item)
        return html("Succesful 200")
    catch
        return html("Error 400")
    end
end

## --- API ---

"""Get all items as JSON."""
function items_api()
    items = Dict("items" => all(Item))
    json(items)
end

"""Add new item through JSON payload."""
function items_api_payload()
    d = jsonpayload()
    @show d
    try
        item = Item(a=d["a"], b=d["b"])
        save(item)
        return html("Succesful 200")
    catch
        return html("Error 400")
    end
end

end
