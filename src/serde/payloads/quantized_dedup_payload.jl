using ..Fed: STATS


"""
    QDedupPayload

Payload generated by the quantization compression scheme. Data are structured
in a different way than `QPayload` in order to diff-deduplicate the client-side
payloads by chunks.
"""
mutable struct QDedupPayload{T <: Unsigned}
    data::Vector{Vector{T}}
    minval::Float32
    maxval::Float32
end


"""
    QuantizedDedupPayloadSerde(chunksize, is_client)

Applies both quantization and diff-deduplication to the weights before
serialization in order to compress the payload. Quantization is a lossy process,
thus a lost of information is to be expected after deserialization.
"""
mutable struct QuantizedDedupPayloadSerde{T <: Unsigned} <: PayloadSerde
    chunksize::Int
    is_client::Bool
    original_data::Vector{Vector{T}}

    QuantizedDedupPayloadSerde{T}(chunksize, is_client) where T <: Unsigned = new(
        chunksize,
        is_client,
        Vector{Vector{T}}(undef, 0)
    )
end


"""
    serialize_payload(::QuantizedDedupPayloadSerde, weights)

Serializes `weights` with the `QuantizedDedupPayloadSerde` where quantization 
and diff-deduplication of values are applied before serialization.
"""
function serialize_payload(
    p::QuantizedDedupPayloadSerde{T},
    weights::Vector{Float32}
)::Vector{UInt8} where T <: Unsigned
    # quantize weights
    q = Quantizer{T}(weights)
    qweights = [quantize(q, w) for w in weights]
    STATS.base.req_data = qweights

    chunks = to_chunks(qweights, p.chunksize)

    if p.is_client
        chunks = diff_deduplication.(chunks, p.original_data)
    else
        p.original_data = chunks
    end
    
    payload = QDedupPayload{T}(chunks, q.minval, q.maxval)

    return pack(payload)
end


"""
    deserialize_payload(::QuantizedDedupPayloadSerde, data, from)

Deserializes `data` with the `QuantizedDedupPayloadSerde` where regeneration of
deduplicated values and dequantizatoin are applied after deserialization.
"""
function deserialize_payload(
    p::QuantizedDedupPayloadSerde{T},
    data::Vector{UInt8},
    from::String
)::Vector{Float32} where T <: Unsigned
    payload = unpack(data)

    if p.is_client
        p.original_data = payload.data
    else
        num_identical_chunks = sum([1 for el in payload.data if el == [0x00]])
        STATS.network.num_identical_chunks += num_identical_chunks

        payload.data = reverse_diff_deduplication(payload.data, p.original_data)
    end

    qweights = reduce(vcat, payload.data)
    push!(STATS.base.res_data, qweights)

    # dequantize weights
    q = Quantizer{T}(payload.minval, payload.maxval)
    weights = [dequantize(q, w) for w in qweights]

    return weights
end
