mutable struct VanillaStats{T <: Real} <: Statistics
    dtype::Type{T}
    base_stats::BaseStats

    # network traffic
    uplink::Vector{Int}
    downlink::Vector{Int}

    # changes inside data
    req_data::Vector
    res_data::Vector{Vector}
    round_changes::Vector{Float32}
    changes_per_weights::Vector{Vector{Float32}}

    VanillaStats{T}(
        num_comm_round::Int,
        fraction_client::Float32,
        num_total_clients::Int,
        num_weights::Int
    ) where T <: Real = new(
        T,
        BaseStats(num_comm_round, fraction_client, num_total_clients, num_weights),
        # network traffic
        Vector{Int}(undef, 0),
        Vector{Int}(undef, 0),
        # changes inside data
        Vector(undef, 0),
        Vector{Vector}(undef, 0),
        Vector{Float32}(undef, 0),
        Vector{Vector{Float32}}(undef, 0)
    )
end

function update_stats!(
    stats::VanillaStats,
    round_num::Int,
    loss::Float32,
    accuracy::Float32,
    payload_size::Int
)
    update_stats!(stats.base_stats, loss, accuracy)
    
    num_comm = round_num * stats.base_stats.num_clients_per_round
    updown = num_comm * payload_size # symetrical communication

    push!(stats.uplink, updown)
    push!(stats.downlink, updown)

    push!(stats.round_changes, compute_round_changes(stats.req_data, stats.res_data))
    push!(stats.changes_per_weights, compute_changes_per_weights(stats.req_data, stats.res_data))

    stats.req_data = Vector{stats.dtype}(undef, 0)
    stats.res_data = Vector{Vector{stats.dtype}}(undef, 0)
end