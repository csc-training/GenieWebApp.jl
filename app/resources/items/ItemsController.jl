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
    html(:items, :item_list; items = all(Item))
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

function items(::Val{:view}, ::Val{:GET}, id)
    item = findone(Item; id = id)
    if isnothing(item)
        html(""; status = 400)
    else
        html(:items, :item; item = item)
    end
end

function items(::Val{:view}, ::Val{:POST}, id)
    html("")
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

function items(::Val{:api}, ::Val{:GET}, id)
    json(""; status=200)
end

function items(::Val{:api}, ::Val{:PUT}, id)
    json(""; status=200)
end

function items(::Val{:api}, ::Val{:DELETE}, id)
    json(""; status=200)
end


end
