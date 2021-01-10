struct QuantizedDedupConfig{T <: Unsigned} <: Configuration
    common::CommonConfig{T}
    payload_serde::QuantizedDedupPayloadSerde

    QuantizedDedupConfig{T}(
        common_config::CommonConfig{T},
        chunksize::Int,
        is_client::Bool
    ) where T <: Real = new(
        common_config,
        QuantizedDedupPayloadSerde{T}(chunksize, is_client)
    )
end