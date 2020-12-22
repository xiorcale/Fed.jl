using ..Fed: CHUNKSIZE, MSBSIZE, QDTYPE, FINGERPRINT, PERMUTATIONS_FILE
using GD
using JLD
using SHA


struct GDPayload
    gdfile::GDFile
    minval::Float32
    maxval::Float32
end


struct GDPayloadSerde{T <: Real}
    # quantization
    qtype::Type{T}
    qmin::T
    qmax::T

    permutations::Vector{Int64}

    store::Store

    GDPayloadSerde{T}(qmin::T, qmax::T) where T <: Real = begin
        quantizer = GD.Transform.Quantizer{QDTYPE}(CHUNKSIZE, MSBSIZE)

        permutations = JLD.load(PERMUTATIONS_FILE, "permutations")

        compressor = Compressor(CHUNKSIZE, quantizer, FINGERPRINT)
        store = Store(compressor, Dict(), 0, 0)

        return new(T, qmin, qmax, permutations, store)
    end
end


"""
    serialize_payload(::GDPayloadSerde, weights)

Serializes `weights` with the `GDPayloadSerde` where quantization and 
generalized deduplication are applied before serialization.
"""
function serialize_payload(p::GDPayloadSerde, weights::Vector{Float32})::Vector{UInt8}
    # find quantization range
    minval = minimum(weights)
    maxval = maximum(weights)

    # quantize weights
    q = Quantizer{p.qtype}(p.qmin, p.qmax, minval, maxval)
    qweights = [quantize(q, w) for w in weights]

    # shift high entropy weights
    permute!(qweights, p.permutations)

    # gd compression
    gdfile = compress!(p.store, qweights)

    payload = Payload(gdfile, minval, maxval)

    return pack(payload)
end


"""
    deserialize_payload(GDPayloadSerde, data, from)

Deserializes `data` with the `GDPayloadSerde` where generalized deduplication
and dequantization are applied before deserialization.
"""
function deserialize_payload(p::GDPayloadSerde, data::Vector{UInt8}, from::String)::Vector{Float32}
    payload = unpack(data)

    # gd decompression
    validate_remote!(p.store, payload.gdfile, from)
    qweights = extract(p.store, payload.gdfile)

    # shift back high entropy weights
    invpermute!(qweights, p.permutations)

    # dequantize weights
    q = Quantizer{p.qtype}(p.qmin, p.qmax, payload.minval, payload.maxval)
    weights = [dequantize(q, w) for w in qweights]

    return weights
end
