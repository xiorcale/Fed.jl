using ..Fed: STATS


"""
    QDiffPayload

Payload generated by the quantization compression scheme. Data are structured
in a different way than `QPayload` in order to diff-deduplicate the client-side
payloads by chunks.
"""
mutable struct QDiffPayload{T <: Unsigned}
    data::Patch{T}
    minval::Float32
    maxval::Float32
end


"""
    QDiffPayloadSerde(chunksize, is_client)

Applies both quantization and diff-deduplication to the weights before
serialization in order to compress the payload. Quantization is a lossy process,
thus a lost of information is to be expected after deserialization.
"""
mutable struct QDiffPayloadSerde{T <: Unsigned} <: PayloadSerde
    chunksize::Int
    is_client::Bool
    original_data::Vector{T}

    QDiffPayloadSerde{T}(chunksize, is_client) where T <: Unsigned = new(
        chunksize,
        is_client,
        Vector{Vector{T}}(undef, 0)
    )
end


"""
    serialize_payload(::QDiffPayloadSerde, weights)

Serializes `weights` with the `QuantizedDedupPayloadSerde` where quantization 
and diff-deduplication of values are applied before serialization.
"""
function serialize_payload(
    p::QDiffPayloadSerde{T},
    weights::Vector{Float32}
)::Vector{UInt8} where T <: Unsigned
    # quantize weights
    q = Quantizer{T}(weights)
    qweights = [quantize(q, w) for w in weights]
    STATS.base.req_data = qweights

    if p.is_client
        patched_file = diff(p.original_data, qweights, sizeof(T))
    else
        p.original_data = qweights
        patched_file = Patch{T}(UnitRange[], qweights)
    end
    
    payload = QDiffPayload{T}(patched_file, q.minval, q.maxval)

    return pack(payload)
end


"""
    deserialize_payload(::QuantizedDedupPayloadSerde, data, from)

Deserializes `data` with the `QuantizedDedupPayloadSerde` where regeneration of
deduplicated values and dequantizatoin are applied after deserialization.
"""
function deserialize_payload(
    p::QDiffPayloadSerde{T},
    data::Vector{UInt8},
    from::String
)::Vector{Float32} where T <: Unsigned
    payload = unpack(data)

    if p.is_client
        qweights = payload.data.data
        p.original_data = qweights
    else
        delta_earned = sum(length.(payload.data.range)) * sizeof(T) - (8 * length(payload.data.range))
        STATS.network.delta_earned += delta_earned

        qweights = patch(p.original_data, payload.data)
        push!(STATS.base.res_data, qweights)
    end

    # dequantize weights
    q = Quantizer{T}(payload.minval, payload.maxval)
    weights = [dequantize(q, w) for w in qweights]

    return weights
end
