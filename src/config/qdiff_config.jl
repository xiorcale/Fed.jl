using ..Serde: QDiffPayloadSerde


"""
    QDiffConfig(base, chunksize, is_client)

Apply the same quantization algorithm used by `QuantizedConfig`, but also
further reduces the size of the paylaod by adding client-side "diff-
deduplication", where unchanged chunks of data are not sent back to the server.
"""
struct QDiffConfig{T <: Unsigned} <: Configuration
    base::BaseConfig
    payload_serde::QDiffPayloadSerde

    QDiffConfig{T}(
        base::BaseConfig, 
        chunksize::Int, 
        is_client::Bool
    ) where T <: Unsigned = new(
        base,
        QDiffPayloadSerde{T}(chunksize, is_client)
    )
end