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
        return html("Bad Request"; status=400)
    end
    redirect(:get_items)
end

function items(::Val{:view}, ::Val{:GET}, id)
    item = findone(Item; id = id)
    if isnothing(item)
        html("Not Found"; status = 404)
    else
        html(:items, :item; item = item, status = 200)
    end
end

function items(::Val{:view}, ::Val{:POST}, id)
    d = postpayload()
    @show d
    item = findone(Item; id = id)
    if isnothing(item)
        return html("Not Found", status = 404)
    else
        if haskey(d, :delete)
            delete(item)
        else
            try
                item.a = d[:a]
                item.b = d[:b]
                save(item)
            catch
                return html("Bad Request"; status=400)
            end
        end
        redirect(:get_items)
    end
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
        return json("Created"; status=201)
    catch
        return json("Bad Request"; status=400)
    end
end

function items(::Val{:api}, ::Val{:GET}, id)
    item = findone(Item; id = id)
    if isnothing(item)
        return json("Not Found"; status=404)
    else
        return json(item; status=200)
    end
end

function items(::Val{:api}, ::Val{:PUT}, id)
    d = jsonpayload()
    @show d
    item = findone(Item; id = id)
    if isnothing(item)
        return json("Not Found"; status=404)
    else
        try
            item.a = d["a"]
            item.b = d["b"]
            save(item)
            return json(""; status=200)
        catch
            return json("Bad Request"; status=400)
        end
    end
end

function items(::Val{:api}, ::Val{:DELETE}, id)
    item = findone(Item; id = id)
    if isnothing(item)
        return json("Not Found"; status=404)
    else
        delete(item)
        return json("Deleted"; status=200)
    end
end


end
