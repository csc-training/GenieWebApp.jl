module ItemsController

using Genie.Requests
using Genie.Renderer
using Genie.Renderer.Html
using Genie.Renderer.Json
using SearchLight
using Items


# --- Views ---

function items_get()
    html(:items, :myitems, items = all(Item))
end

function items_post()
    d = postpayload()
    @show d
    try
        item = Item(a=d[:a], b=d[:b])
        save(item)
    catch
        return html(""; status=400)
    end
    redirect(:items_get)
end


# --- API ---

"""Get all items as JSON."""
function items_api_get()
    json(all(Item))
end

"""Add new item through JSON payload."""
function items_api_post()
    d = jsonpayload()
    @show d
    try
        item = Item(a=d["a"], b=d["b"])
        save(item)
        return html(""; status=200)
    catch
        return html(""; status=400)
    end
end

end
