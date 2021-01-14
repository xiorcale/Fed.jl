using ..Fed: STATS


"""
    QDiffStaticPayloadSerde(chunksize, is_client)

Applies both quantization and diff-deduplication to the weights before
serialization in order to compress the payload. Quantization is a lossy process,
thus a lost of information is to be expected after deserialization.
"""
mutable struct QDiffStaticPayloadSerde{T <: Unsigned} <: PayloadSerde
    chunksize::Int
    is_client::Bool
    quantizer::Quantizer{T}
    original_data::Vector{Vector{T}}

    QDiffStaticPayloadSerde{T}(chunksize, is_client) where T <: Unsigned = new(
        chunksize,
        is_client,
        Quantizer{T}(-1.0f0, 1.0f0),
        Vector{Vector{T}}(undef, 0)
    )
end


"""
    serialize_payload(::QDiffPayloadSerde, weights)

Serializes `weights` with the `QuantizedDedupPayloadSerde` where quantization 
and diff-deduplication of values are applied before serialization.
"""
function serialize_payload(
    p::QDiffStaticPayloadSerde{T},
    weights::Vector{Float32}
)::Vector{UInt8} where T <: Unsigned
    # quantize weights
    qweights = [quantize(p.quantizer, w) for w in weights]
    STATS.base.req_data = qweights

    chunks = to_chunks(qweights, p.chunksize)

    if p.is_client
        chunks = diff.(chunks, p.original_data)
    else
        p.original_data = chunks
    end
    
    payload = QDiffPayload{T}(chunks, p.quantizer.minval, p.quantizer.maxval)

    return pack(payload)
end


"""
    deserialize_payload(::QuantizedDedupPayloadSerde, data, from)

Deserializes `data` with the `QuantizedDedupPayloadSerde` where regeneration of
deduplicated values and dequantizatoin are applied after deserialization.
"""
function deserialize_payload(
    p::QDiffStaticPayloadSerde{T},
    data::Vector{UInt8},
    from::String
)::Vector{Float32} where T <: Unsigned
    payload = unpack(data)

    if p.is_client
        p.original_data = payload.data
    else
        num_identical_chunks = sum([1 for el in payload.data if el == [0x00]])
        STATS.network.num_identical_chunks += num_identical_chunks

        payload.data = patch(payload.data, p.original_data)
    end

    qweights = reduce(vcat, payload.data)
    push!(STATS.base.res_data, qweights)

    # dequantize weightsl)
    weights = [dequantize(p.quantizer, w) for w in qweights]

    return weights
end
