using Serialization: serialize, deserialize


"""
curry(f, x)
Returns a curried `f` by passing `x` as first argument.
"""
curry(f, x) = (xs...) -> f(x, xs...)


"""
    pack(data)

Utility function to serialize `data`.
"""
function pack(data)::Vector{UInt8}
    buffer = IOBuffer()
    serialize(buffer, data)
    return take!(buffer)
end


"""
    unpack(bytes)

Utility function to deserialize `bytes`.
"""
function unpack(bytes::Vector{UInt8})
    return IOBuffer(bytes) |> deserialize
end
