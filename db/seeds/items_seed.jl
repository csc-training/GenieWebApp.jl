using SearchLight
using Items

function seed()
    items = [
        Item(a="Hello", b=1),
        Item(a="World", b=2)
    ]
    for item in items
        save(item)
    end
end
