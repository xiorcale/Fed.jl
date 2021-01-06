using GD


mutable struct GDPayload
    gdfile::GDFile
    minval::Float32
    maxval::Float32
end


mutable struct GDPayloadSerde{T <: Unsigned} <: PayloadSerde
    # quantization
    qtype::Type{T}
    qmin::T
    qmax::T

    store::Store

    is_client::Bool
    # gdfile::GDFile
    data::Vector{T}

    GDPayloadSerde{T}(chunksize::Int, fingerprint::Function, msbsize::T, is_client::Bool) where T <: Real = begin
        quantizer = GD.Transform.Quantizer{T}(chunksize, msbsize)

        compressor = Compressor(chunksize, quantizer, fingerprint)
        store = Store(compressor, Dict(), 0, 0)

        return new(T, typemin(T), typemax(T), store, is_client, Vector{T}(undef, 0))
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

    if p.is_client
        # take only the weights difference to increase values stability
        qweights -= p.data
    else
        # server side
        p.data = qweights
    end

    gdfile = compress!(p.store, qweights)

    STATS.common.req_data = gdfile

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

    push!(STATS.common.res_data, payload.gdfile)

    # gd decompression
    STATS.network.num_unknown_bases += validate_remote!(p.store, payload.gdfile, from)
    # since deserializing a client payload means the client is done with his work, we
    # can also update the number of requested bases, to make sure the one requested by
    # this client are taken into account.
    STATS.network.num_requested_bases = p.store.num_requested_bases
    
    qweights = extract(p.store, payload.gdfile)

    if p.is_client
        p.data = qweights
    else
        # add the request payload to the difference
        qweights += p.data
    end

    # dequantize weights
    q = Quantizer{p.qtype}(p.qmin, p.qmax, payload.minval, payload.maxval)
    weights = [dequantize(q, w) for w in qweights]

    return weights
end


