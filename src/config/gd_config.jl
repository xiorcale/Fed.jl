struct GDConfig{T <: Unsigned} <: Configuration
    common::CommonConfig{T}

    payload_serde::GDPayloadSerde

    chunksize::Int
    fingerprint::Function
    msbsize::T

    GDConfig{T}(
        common_config::CommonConfig{T},
        chunksize::Int, 
        fingerprint::Function,
        msbsize::T,
        host::String,
        port::Int,
        is_client::Bool
    ) where T <: Real = new(
        common_config,
        GDPayloadSerde{T}(chunksize, fingerprint, msbsize, host, port, is_client),
        chunksize,
        fingerprint,
        msbsize
    )
end