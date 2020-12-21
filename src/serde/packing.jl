using Serialization: serialize, deserialize


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
