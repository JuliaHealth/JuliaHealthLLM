module Pgvector
    convert(v::AbstractVector{T}) where T<:Real = string("[", join(v, ","), "]")
end