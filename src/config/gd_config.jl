using ..Serde: GDPayloadSerde, GDStaticPayloadSerde


"""
    GDConfig{T <: Unsigned}(
        base::BaseConfig,
        chunksize::Int,
        fingerprint::Function,
        msbsize::T,
        store_host::String,
        store_port::Int,
        is_client::Bool
    ) <: Configuration

Compress the payload by using a `GD Store`, producing a generally deduplicated
`GDFile` which are exchanged between the clients and the server. This 
configuration instanciates a [GDPayloadSerde](@ref) and is making use of the
[GD.jl](https://xiorcale.github.io/GD.jl/) library to handle the generalized
deduplication logic.
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


"""
    GDStaticConfig(base, chunksize, fingerprint, msbsize, host, port, is_client)

Compresses the payload by using a `GD Store`, producing a generally deduplicated
`GDFile` which are exchanged between the clients and the server. This 
configuration is making use of the GD.jl library to handle the GD logic
(https://github.com/xiorcale/GD.jl).
"""
struct GDStaticConfig{T <: Unsigned} <: Configuration
    base::BaseConfig

    payload_serde::GDStaticPayloadSerde

    chunksize::Int
    fingerprint::Function
    msbsize::T

    GDStaticConfig{T}(
        base::BaseConfig,
        chunksize::Int, 
        fingerprint::Function,
        msbsize::T,
        store_host::String,
        store_port::Int,
        is_client::Bool
    ) where T <: Unsigned = new(
        base,
        GDStaticPayloadSerde{T}(chunksize, fingerprint, msbsize, store_host, store_port, is_client),
        chunksize,
        fingerprint,
        msbsize
    )
end