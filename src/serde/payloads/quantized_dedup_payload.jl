using ..Fed: STATS


mutable struct QDedupPayload{T <: Unsigned}
    data::Vector{Vector{T}}
    minval::Float32
    maxval::Float32
end


mutable struct QuantizedDedupPayloadSerde{T <: Unsigned} <: PayloadSerde
    qtype::Type{T}
    qmin::T
    qmax::T

    chunksize::Int
    is_client::Bool
    data::Vector{Vector{T}}

    QuantizedDedupPayloadSerde{T}(chunksize, is_client) where T <: Real = new(
        T,
        typemin(T),
        typemax(T),
        chunksize,
        is_client,
        Vector{Vector{T}}(undef, 0)
    )
end


"""
    serialize_payload(::QuantizedDedupPayloadSerde, weights)

Serializes `weights` with the `QuantizedDedupPayloadSerde` where quantization 
and deduplication of values are applied before serialization.
"""
function serialize_payload(p::QuantizedDedupPayloadSerde, weights::Vector{Float32})::Vector{UInt8}
    # quantize weights
    q = Quantizer{p.qtype}(weights)
    qweights = [quantize(q, w) for w in weights]
    STATS.common.req_data = qweights

    chunks = to_chunks(qweights, p.chunksize)

    if p.is_client
        chunks = patch_quantized(chunks, p.data)
    else
        p.data = chunks
    end
    
    payload = QDedupPayload{p.qtype}(chunks, q.minval, q.maxval)

    return pack(payload)
end


"""
    deserialize_payload(::QuantizedDedupPayloadSerde, data, from)

Deserializes `data` with the `QuantizedDedupPayloadSerde` where regeneration of
deduplicated values and dequantizatoin are applied after deserialization.
"""
function deserialize_payload(p::QuantizedDedupPayloadSerde, data::Vector{UInt8}, from::String)::Vector{Float32}
    payload = unpack(data)

    if p.is_client
        p.data = payload.data
    else
        num_identical_chunks = sum([1 for el in payload.data if el == [0x00]])
        STATS.network.num_identical_chunks += num_identical_chunks

        payload.data = unpatch_quantized(payload.data, p.data)
    end

    qweights = reduce(vcat, payload.data)
    push!(STATS.common.res_data, qweights)

    # dequantize weights
    q = Quantizer{p.qtype}(p.qmin, p.qmax, payload.minval, payload.maxval)
    weights = [dequantize(q, w) for w in qweights]

    return weights
end
