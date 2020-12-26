struct GDConfig{T <: Real} <: Configuration
    common::CommonConfig{T}

    payload_serde::GDPayloadSerde

    chunksize::Int
    fingerprint::Function
    msbsize::Int

    GDConfig{T}(
        serverurl::String,
        num_comm_rounds::Int,
        fraction_clients::Float32,
        num_total_clients::Int,
        qmin::T,
        qmax::T,
        chunksize::Int, 
        fingerprint::Function,
        msbsize::Int,
        permutations_file::String
    ) where T <: Real = new(
        CommonConfig{T}(
            serverurl, 
            num_comm_rounds,
            fraction_clients,
            num_total_clients
        ),
        GDPayloadSerde{T}(qmin, qmax, chunksize, fingerprint, msbsize, permutations_file),
        chunksize,
        fingerprint,
        msbsize
    )
end