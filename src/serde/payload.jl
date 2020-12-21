struct Payload
    data::Vector{UInt8}
    minval::Float32
    maxval::Float32
end


struct PayloadSerde{T <: Real}
    # quantization
    qtype::Type{T}
    qmin::T
    qmax::T

    PayloadSerde{T}(qmin::T, qmax::T) where T <: Real = begin
        return new(T, qmin, qmax)
    end
end


"""
    serialize_payload(payload_serde, weights)

Serializes `weights` with the `payload_serde`.
"""
function serialize_payload(p::PayloadSerde, weights::Vector{Float32})::Vector{UInt8}
    # find quantization range
    minval = minimum(weights)
    maxval = maximum(weights)

    # quantize weights
    q = Quantizer{p.qtype}(p.qmin, p.qmax, minval, maxval)
    qweights = [quantize(q, w) for w in weights]

    payload = Payload(qweights, minval, maxval)

    return pack(payload)
end


"""
    deserialize_payload(payload_serde, data)

Deserializes `data` with the `payload_serde`.
"""
function deserialize_payload(p::PayloadSerde, data::Vector{UInt8})::Vector{Float32}
    payload = unpack(data)

    # dequantize weights
    q = Quantizer{p.qtype}(p.qmin, p.qmax, payload.minval, payload.maxval)
    weights = [dequantize(q, w) for w in payload.data]

    return weights
end
