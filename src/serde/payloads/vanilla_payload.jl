using ..Fed: STATS


"""
    VanillaPayloadSerde

Basic serialization where no compression is applied. This `PayloadSerde` is
only a wrapper around the data serialization in order to match the interface to
implement.
"""
struct VanillaPayloadSerde <: PayloadSerde end


"""
    serialize_payload(::VanillaPayloadSerde, weights)

Serializes `weights` with the `VanillaPayloadSerde` where only basic 
serialization is applied.
"""
function serialize_payload(::VanillaPayloadSerde, weights::Vector{Float32})::Vector{UInt8}
    STATS.base.req_data = weights
    return pack(weights)
end


"""
    deserialize_payload(::VanillaPayloadSerde, data, from)

Deserializes `data` with the `VanillaPayloadSerde` where only basic 
deserialization is applied.
"""
function deserialize_payload(::VanillaPayloadSerde, data::Vector{UInt8}, from::String)::Vector{Float32}
    weights = unpack(data)
    push!(STATS.base.res_data, weights)
    return weights
end
