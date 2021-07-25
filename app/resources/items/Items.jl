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

StructTypes.StructType(::Type{Item}) = StructTypes.Mutable()

end
