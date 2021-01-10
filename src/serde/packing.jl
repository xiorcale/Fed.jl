using Serialization: serialize, deserialize


"""
    pack(data)

Utility function to serialize `data` into a byte array.
"""
function pack(data)::Vector{UInt8}
    buffer = IOBuffer()
    serialize(buffer, data)
    return take!(buffer)
end


"""
    unpack(bytes)

Utility function to deserialize `bytes` into its original representation.
"""
unpack(bytes::Vector{UInt8}) = IOBuffer(bytes) |> deserialize
