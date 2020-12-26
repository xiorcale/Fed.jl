using GD
using JLD
using SHA


struct GDPayload
    gdfile::GDFile
    minval::Float32
    maxval::Float32
end


struct GDPayloadSerde{T <: Real} <: PayloadSerde
    # quantization
    qtype::Type{T}
    qmin::T
    qmax::T

    permutations::Vector{Int64}

    store::Store

    GDPayloadSerde{T}(qmin::T, qmax::T, chunksize::Int, fingerprint::Function, msbsize::T, permutations_file::String) where T <: Real = begin
        quantizer = GD.Transform.Quantizer{T}(chunksize, msbsize)

        permutations = JLD.load(permutations_file, "permutations")

        compressor = Compressor(chunksize, quantizer, fingerprint)
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
    # quantize weights
    q = Quantizer{p.qtype}(weights)
    qweights = [quantize(q, w) for w in weights]

    # shift high entropy weights
    permute!(qweights, p.permutations)

    # gd compression
    gdfile = compress!(p.store, qweights)

    STATS.common.req_data = gdfile.hashes

    payload = GDPayload(gdfile, q.minval, q.maxval)

    return pack(payload)
end


"""
    deserialize_payload(GDPayloadSerde, data, from)

Deserializes `data` with the `GDPayloadSerde` where generalized deduplication
and dequantization are applied before deserialization.
"""
function deserialize_payload(p::GDPayloadSerde, data::Vector{UInt8}, from::String)::Vector{Float32}
    payload = unpack(data)

    push!(STATS.common.res_data, payload.gdfile.hashes)

    # gd decompression
    STATS.gd_net.num_unknown_bases += validate_remote!(p.store, payload.gdfile, from)
    # since deserializing a client payload means the client is done with his work, we
    # can also update the number of requested bases, to make sure the one requested by
    # this client are taken into account.
    STATS.gd_net.num_requested_bases = p.store.num_requested_bases
    qweights = extract(p.store, payload.gdfile)

    # shift back high entropy weights
    invpermute!(qweights, p.permutations)

    # dequantize weights
    q = Quantizer{p.qtype}(p.qmin, p.qmax, payload.minval, payload.maxval)
    weights = [dequantize(q, w) for w in qweights]

    return weights
end
