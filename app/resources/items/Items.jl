module Items

import SearchLight: AbstractModel, DbId
import Base: @kwdef

export Item

@kwdef mutable struct Item <: AbstractModel
  id::DbId = DbId()
  a::String = ""
  b::Int = 0
end

Base.convert(::Type{Int}, s::String) = parse(Int, s)

end
