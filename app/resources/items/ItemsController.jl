module ItemsController

using Genie.Requests
using Genie.Renderer
using Genie.Renderer.Html
using Genie.Renderer.Json
using SearchLight
using Items

export items


# --- Views ---

function items(::Val{:view}, ::Val{:GET})
    html(:items, :myitems, items = all(Item))
end

function items(::Val{:view}, ::Val{:POST})
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

function items(::Val{:api}, ::Val{:GET})
    json(all(Item))
end

function items(::Val{:api}, ::Val{:POST})
    d = jsonpayload()
    @show d
    try
        item = Item(a=d["a"], b=d["b"])
        save(item)
        return json(""; status=200)
    catch
        return json(""; status=400)
    end
end

end
