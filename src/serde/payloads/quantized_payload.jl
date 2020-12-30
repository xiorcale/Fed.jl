using ..Fed: STATS


mutable struct QPayload{T <: Unsigned}
    data::Vector{Vector{T}}
    minval::Float32
    maxval::Float32
end


mutable struct QuantizedPayloadSerde{T <: Unsigned} <: PayloadSerde
    qtype::Type{T}
    qmin::T
    qmax::T

    chunksize::Int
    is_patcher::Bool
    data::Vector{Vector{T}}

    QuantizedPayloadSerde{T}(chunksize, is_patcher) where T <: Real = new(
        T,
        typemin(T),
        typemax(T),
        chunksize,
        is_patcher,
        Vector{Vector{T}}(undef, 0)
    )
end


function to_chunks(data::Vector{T}, chunksize::Int)::Vector{Vector{T}} where T <: Unsigned
    chunks = Vector{Vector{T}}(undef, ceil(Int, length(data) / chunksize))
    for i in 1:length(chunks)-1
        chunks[i] = data[(i-1) * chunksize + 1:(i * chunksize)]
    end
    chunks[end] = data[(length(chunks)-1)*chunksize+1:end]
    return chunks
end


diff(x, y) = x == y ? [0x00] : x
patch_quantized(x, y) = diff.(x, y)

function unpatch_quantized(x, y)
    result = deepcopy(x)
    for (i, chunk) in enumerate(y)
        if result[i] == [0x00]
            result[i] = chunk
        end
    end
    return result
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

    chunks = to_chunks(qweights, p.chunksize)

    if p.is_patcher
        chunks = patch_quantized(chunks, p.data)
    else
        p.data = chunks
    end

    
    payload = QPayload(chunks, q.minval, q.maxval)
    
    return pack(payload)
end


"""
    deserialize_payload(::QuantizedPayloadSerde, data, from)

Deserializes `data` with the `QuantizedPayloadSerde` where dequantization is
applied after deserialization.
"""
function deserialize_payload(p::QuantizedPayloadSerde, data::Vector{UInt8}, from::String)::Vector{Float32}
    payload = unpack(data)

    if p.is_patcher
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
