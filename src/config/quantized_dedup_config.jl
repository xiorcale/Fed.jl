struct QuantizedDedupConfig{T <: Unsigned} <: Configuration
    common::CommonConfig{T}
    payload_serde::QuantizedDedupConfig

    QuantizedDedupConfig{T}(
        serverurl::String,
        num_comm_rounds::Int,
        fraction_clients::Float32,
        num_total_clients::Int,
        chunksize::Int,
        is_client::Bool
    ) where T <: Real = new(
        CommonConfig{T}(serverurl, num_comm_rounds, fraction_clients, num_total_clients),
        QuantizedDedupPayloadSerde{T}(chunksize, is_client)
    )
end