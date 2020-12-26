"""
    CommonStats

Every stats common to any configuration.
"""
mutable struct CommonStats{T <: Real} <: Statistics
    dtype::Type{T}

    # federated learning stats
    num_comm_rounds::Int
    num_clients_per_round::Int
    num_total_clients::Int

    # machine learning stats
    num_weights::Int
    losses::Vector{Float32}
    accuracies::Vector{Float32}
 
    # changes inside data
    req_data::Vector
    res_data::Vector{Vector}
    round_changes::Vector{Float32}
    changes_per_weights::Vector{Vector{Float32}}

    CommonStats{T}(
        num_comm_rounds::Int,
        fraction_clients::Float32,
        num_total_clients::Int,
        num_weights::Int
    ) where T <: Real = new(
        T,
        # fedetated learning
        num_comm_rounds,
        max(round(Int, fraction_clients * num_total_clients), 1),
        num_total_clients,
        # machine learning
        num_weights,
        Vector{Float32}(undef, 0),
        Vector{Float32}(undef, 0),
        # changes inside data
        Vector(undef, 0),
        Vector{Vector}(undef, 0),
        Vector{Float32}(undef, 0),
        Vector{Vector{Float32}}(undef, 0)
    )
end

function update_stats!(
    stats::CommonStats,
    loss::Float32,
    accuracy::Float32,
) 
    push!(stats.losses, loss)
    push!(stats.accuracies, accuracy)

    push!(stats.round_changes, compute_round_changes(stats.req_data, stats.res_data))
    push!(stats.changes_per_weights, compute_changes_per_weights(stats.req_data, stats.res_data))

    stats.req_data = Vector{stats.dtype}(undef, 0)
    stats.res_data = Vector{Vector{stats.dtype}}(undef, 0)
end