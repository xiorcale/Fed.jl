using ..Fed: STATS


mutable struct QPayload{T <: Unsigned}
    data::Vector{T}
    minval::Float32
    maxval::Float32
end


mutable struct QuantizedPayloadSerde{T <: Unsigned} <: PayloadSerde
    qtype::Type{T}
    qmin::T
    qmax::T

    chunksize::Int
    is_client::Bool
    data::Vector{Vector{T}}

    QuantizedPayloadSerde{T}(chunksize, is_client) where T <: Real = new(
        T,
        typemin(T),
        typemax(T),
        chunksize,
        is_client,
        Vector{Vector{T}}(undef, 0)
    )
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

    # chunks = to_chunks(qweights, p.chunksize)

    # if p.is_client
    #     chunks = patch_quantized(chunks, p.data)
    # else
    #     p.data = chunks
    # end

    
    # payload = QPayload(chunks, q.minval, q.maxval)
    
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

    # if p.is_client
    #     p.data = payload.data
    # else
    #     num_identical_chunks = sum([1 for el in payload.data if el == [0x00]])
    #     STATS.network.num_identical_chunks += num_identical_chunks

    #     payload.data = unpatch_quantized(payload.data, p.data)
    # end

    # qweights = reduce(vcat, payload.data)
    # push!(STATS.common.res_data, qweights)
    push!(STATS.common.res_data, payload.data)

    # dequantize weights
    q = Quantizer{p.qtype}(p.qmin, p.qmax, payload.minval, payload.maxval)
    # weights = [dequantize(q, w) for w in qweights]
    weights = [dequantize(q, w) for w in payload.data]

    return weights
end
