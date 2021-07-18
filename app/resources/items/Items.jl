module Items

import SearchLight: AbstractModel, DbId
import Base: @kwdef

using StructTypes

export Item

StructTypes.StructType(::Type{DbId}) = StructTypes.Struct()

@kwdef mutable struct Item <: AbstractModel
  id::DbId = DbId()
  a::String = ""
  b::Int = 0
end

Base.convert(::Type{Int}, s::String) = parse(Int, s)

StructTypes.StructType(::Type{Item}) = StructTypes.Struct()

end
