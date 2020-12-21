using ..Fed: CHUNKSIZE, MSBSIZE, QDTYPE
using GD
using SHA


struct Payload
    gdfile::GDFile
    minval::Float32
    maxval::Float32
end


struct PayloadSerde{T <: Real}
    # quantization
    qtype::Type{T}
    qmin::T
    qmax::T

    store::Store

    PayloadSerde{T}(qmin::T, qmax::T) where T <: Real = begin
        quantizer = GD.Transform.Quantizer{QDTYPE}(CHUNKSIZE, MSBSIZE)
        compressor = Compressor(CHUNKSIZE, quantizer, sha1)
        store = Store(compressor, Dict(), 0, 0)
        return new(T, qmin, qmax, store)
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

    gdfile = compress!(p.store, qweights)

    payload = Payload(gdfile, minval, maxval)

    return pack(payload)
end


"""
    deserialize_payload(payload_serde, from, data)

Deserializes `data` with the `payload_serde`.
"""
function deserialize_payload(p::PayloadSerde, from::String, data::Vector{UInt8})::Vector{Float32}
    payload = unpack(data)

    validate_remote!(p.store, payload.gdfile, from)
    qweights = extract(p.store, gdfile)

    # dequantize weights
    q = Quantizer{p.qtype}(p.qmin, p.qmax, payload.minval, payload.maxval)
    weights = [dequantize(q, w) for w in qweights]

    return weights
end
