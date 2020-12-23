struct VanillaPayloadSerde <: PayloadSerde end


"""
    serialize_payload(::VanillaPayloadSerde, weights)

Serializes `weights` with the `VanillaPayloadSerde` where only basic 
serialization is applied.
"""
function serialize_payload(::VanillaPayloadSerde, weights::Vector{Float32})::Vector{UInt8}
    return pack(weights)
end


"""
    deserialize_payload(::VanillaPayloadSerde, data, [from])

Deserializes `data` with the `VanillaPayloadSerde` where only basic 
deserialization is applied.
"""
function deserialize_payload(::VanillaPayloadSerde, data::Vector{UInt8}, ::String)::Vector{Float32}
    return unpack(data)
end
