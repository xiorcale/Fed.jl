using ..Serde: QDiffPayloadSerde, QDiffStaticPayloadSerde


"""
    QDiffConfig{T <: Unsigned}(
        base::BaseConfig,
        chunksize::Int,
        is_client::Bool
    ) <: Configuration

Apply the same quantization algorithm used by `QuantizedConfig`, but also
further reduces the size of the paylaod by adding client-side "diff-
deduplication", where unchanged chunks of data are not sent back to the server.
This configuration instanciates a [QDiffPayloadSerde](@ref).
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

"""
    QDiffStaticConfif(base, chunksize, is_client)

Same as QDiffConfig with a static quantization range of [-1.0, 1.0].
"""
struct QDiffStaticConfig{T <: Unsigned} <: Configuration
    base::BaseConfig
    payload_serde::QDiffStaticPayloadSerde

    QDiffStaticConfig{T}(
        base::BaseConfig,
        chunksize::Int,
        is_client::Bool
    ) where T <: Unsigned = new(
        base,
        QDiffStaticPayloadSerde{T}(chunksize, is_client)
    )
end