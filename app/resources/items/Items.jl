module Items

import SearchLight: AbstractModel, DbId
import Base: @kwdef

export Item

@kwdef mutable struct Item <: AbstractModel
  id::DbId = DbId()
end

end
