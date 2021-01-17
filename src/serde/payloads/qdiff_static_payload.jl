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
    original_data::Vector{T}

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

    if p.is_client
        patched_file = diff(p.original_data, qweights, sizeof(T))
    else
        p.original_data = qweights
        patched_file = Patch{T}(UnitRange[], qweights)
    end
    
    payload = QDiffPayload{T}(patched_file, p.quantizer.minval, p.quantizer.maxval)

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
        qweights = payload.data.data
        p.original_data = qweights
    else
        delta_earned = sum(length.(payload.data.range)) * sizeof(T) - (8 * length(payload.data.range))
        STATS.network.delta_earned += delta_earned

        qweights = patch(p.original_data, payload.data)
        push!(STATS.base.res_data, qweights)
    end    

    # dequantize weights
    weights = [dequantize(p.quantizer, w) for w in qweights]

    return weights
end
