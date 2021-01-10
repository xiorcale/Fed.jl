using ..Serde: QuantizedDedupPayloadSerde


"""
QuantizedDedupConfig(base, chunksize, is_client)

Apply the same quantization algorithm used by `QuantizedConfig`, but also
further reduces the size of the paylaod by adding client-side "diff-
deduplication", where unchanged chunks of data are not sent back to the server.
"""
struct QuantizedDedupConfig{T <: Unsigned} <: Configuration
    base::BaseConfig
    payload_serde::QuantizedDedupPayloadSerde

    QuantizedDedupConfig{T}(
        base::BaseConfig, 
        chunksize::Int, 
        is_client::Bool
    ) where T <: Unsigned = new(
        base,
        QuantizedDedupPayloadSerde{T}(chunksize, is_client)
    )
end