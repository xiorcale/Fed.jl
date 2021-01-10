struct QuantizedConfig{T <: Unsigned} <: Configuration
    common::CommonConfig{T}
    payload_serde::QuantizedPayloadSerde

    QuantizedConfig{T}(
        common_config::CommonConfig{T},
        chunksize::Int
    ) where T <: Real = new(
        common_config,
        QuantizedPayloadSerde{T}(chunksize)
    )
end
