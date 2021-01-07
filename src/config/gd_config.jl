struct GDConfig{T <: Unsigned} <: Configuration
    common::CommonConfig{T}

    payload_serde::GDPayloadSerde

    chunksize::Int
    fingerprint::Function
    msbsize::T

    GDConfig{T}(
        serverurl::String,
        num_comm_rounds::Int,
        fraction_clients::Float32,
        num_total_clients::Int,
        chunksize::Int, 
        fingerprint::Function,
        msbsize::T,
        is_client::Bool
    ) where T <: Real = new(
        CommonConfig{T}(
            serverurl, 
            num_comm_rounds,
            fraction_clients,
            num_total_clients
        ),
        GDPayloadSerde{T}(chunksize, fingerprint, msbsize, is_client),
        chunksize,
        fingerprint,
        msbsize
    )
end