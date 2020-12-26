using SHA
using ..Fed: STATS


struct QPayload{T <: Real}
    data::Vector{T}
    minval::Float32
    maxval::Float32
end


struct QuantizedPayloadSerde{T <: Real} <: PayloadSerde
    qtype::Type{T}
    qmin::T
    qmax::T

    QuantizedPayloadSerde{T}(qmin::T, qmax::T) where T <: Real = new(T, qmin, qmax)
end


"""
    serialize_payload(::QuantizedPayloadSerde, weights)

Serializes `weights` with the `QuantizedPayloadSerde` where quantization is 
applied before serialization.
"""
function serialize_payload(p::QuantizedPayloadSerde, weights::Vector{Float32})::Vector{UInt8}
    # quantize weights
    q = Quantizer{p.qtype}(weights)
    qweights = [quantize(q, w) for w in weights]

    STATS.common.req_data = qweights
    
    payload = QPayload(qweights, q.minval, q.maxval)
    
    return pack(payload)
end


"""
    deserialize_payload(::QuantizedPayloadSerde, data, from)

Deserializes `data` with the `QuantizedPayloadSerde` where dequantization is
applied after deserialization.
"""
function deserialize_payload(p::QuantizedPayloadSerde, data::Vector{UInt8}, from::String)::Vector{Float32}
    payload = unpack(data)

    push!(STATS.common.res_data, payload.data)

    # dequantize weights
    q = Quantizer{p.qtype}(p.qmin, p.qmax, payload.minval, payload.maxval)
    weights = [dequantize(q, w) for w in payload.data]

    return weights
end
