"""
    PayloadSerde

Interface to implement for creating a new compression scheme for the payload.
"""
abstract type PayloadSerde end


"""
    serialize_payload(payload_serde, weights)

Serializes `weights` by applying the transformations defined by the 
`payload_serde`.
"""
function serialize_payload(::PayloadSerde, ::Vector{Float32})::Vector{UInt8} 
    # Nothing - this is an interface to implement...
end


"""
    deserialize_payload(payload_serde, data, from)

Deserializes `data` by applying the inverse transformations of the serialization
process. `from` is the URL from which the data are coming, which may be an empty
string if unsued by the `payload_serde`.
"""
function deserialize_payload(::PayloadSerde, ::Vector{UInt8}, ::String)::Vector{Float32} 
    # Nothing - this is an interface to implement...
end
