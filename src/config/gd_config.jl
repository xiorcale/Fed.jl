using ..Serde: GDPayloadSerde


"""
    GDConfig(base, chunksize, fingerprint, msbsize, host, port, is_client)

Compresses the payload by using a `GD Store`, producing a generally deduplicated
`GDFile` which are exchanged between the clients and the server. This 
configuration is making use of the GD.jl library to handle the GD logic
(https://github.com/xiorcale/GD.jl).
"""
struct GDConfig{T <: Unsigned} <: Configuration
    base::BaseConfig

    payload_serde::GDPayloadSerde

    chunksize::Int
    fingerprint::Function
    msbsize::T

    GDConfig{T}(
        base::BaseConfig,
        chunksize::Int, 
        fingerprint::Function,
        msbsize::T,
        store_host::String,
        store_port::Int,
        is_client::Bool
    ) where T <: Unsigned = new(
        base,
        GDPayloadSerde{T}(chunksize, fingerprint, msbsize, store_host, store_port, is_client),
        chunksize,
        fingerprint,
        msbsize
    )
end
