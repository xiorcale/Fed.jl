"""
    PayloadSerde

Interface to implement for creating a new compression scheme for the payload.
"""
abstract type PayloadSerde end


"""
    serialize_payload(payload_serde::PayloadSerde, weights::Vector{Float32})

Serialize `weights` by applying the transformation defined by the 
`payload_serde`.

!!! info

    This method is an interface to implement when creating a new `PayloadSerde`.
"""
function serialize_payload(::PayloadSerde, ::Vector{Float32})::Vector{UInt8} 
    # Nothing - this is an interface to implement...
end


"""
    deserialize_payload(payload_serde::PayloadSerde, data::Vector{UInt8}, from::String)

Deserialize `data` by applying the inverse transformation of the serialization
process. `from` is the URL from which the data are coming, which may be an empty
string if unused by the `payload_serde`.

!!! info

    This method is an interface to implement when creating a new `PayloadSerde`.
"""
function deserialize_payload(::PayloadSerde, ::Vector{UInt8}, ::String)::Vector{Float32} 
    # Nothing - this is an interface to implement...
end
