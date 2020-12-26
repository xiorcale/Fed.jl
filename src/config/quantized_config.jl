struct QuantizedConfig{T <: Real} <: Configuration
    common::CommonConfig{T}
    payload_serde::QuantizedPayloadSerde

    QuantizedConfig{T}(
        serverurl::String,
        num_comm_rounds::Int,
        fraction_clients::Float32,
        num_total_clients::Int,
        qmin::T,
        qmax::T
    ) where T <: Real = new(
        CommonConfig{T}(serverurl, num_comm_rounds, fraction_clients, num_total_clients),
        QuantizedPayloadSerde{T}(qmin, qmax)
    )
end
