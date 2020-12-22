using ..Fed: CHUNKSIZE, MSBSIZE, QDTYPE, FINGERPRINT, PERMUTATIONS_FILE
using SHA


struct QPayload
    data::Vector{QDTYPE}
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
    # find quantization range
    minval = minimum(weights)
    maxval = maximum(weights)

    # quantize weights
    q = Quantizer{p.qtype}(p.qmin, p.qmax, minval, maxval)
    qweights = [quantize(q, w) for w in weights]

    payload = QPayload(qweights, minval, maxval)

    return pack(payload)
end


"""
    deserialize_payload(::QuantizedPayloadSerde, from, data)

Deserializes `data` with the `QuantizedPayloadSerde` where dequantization is
applied after deserialization.
"""
function deserialize_payload(p::QuantizedPayloadSerde, data::Vector{UInt8})::Vector{Float32}
    payload = unpack(data)

    # dequantize weights
    q = Quantizer{p.qtype}(p.qmin, p.qmax, payload.minval, payload.maxval)
    weights = [dequantize(q, w) for w in payload.data]

    return weights
end
