"""
    BaseStats

Every stats common to any configuration.
"""
mutable struct BaseStats <: Statistics
    # federated learning stats
    num_comm_rounds::Int
    num_clients_per_round::Int
    num_total_clients::Int

    # machine learning stats
    num_weights::Int
    losses::Vector{Float32}
    accuracies::Vector{Float32}
 
    # changes inside data
    req_data::Any
    res_data::Vector{Any}

    BaseStats(
        num_comm_rounds::Int,
        fraction_clients::Float32,
        num_total_clients::Int,
        num_weights::Int
    ) = new(
        # fedetated learning
        num_comm_rounds,
        max(round(Int, fraction_clients * num_total_clients), 1),
        num_total_clients,
        # machine learning
        num_weights,
        Vector{Float32}(undef, 0),
        Vector{Float32}(undef, 0),
        # changes inside data
        Any,
        Vector{Any}(undef, 0)
    )
end

function update_stats!(
    stats::BaseStats,
    loss::Float32,
    accuracy::Float32,
) 
    push!(stats.losses, loss)
    push!(stats.accuracies, accuracy)

    stats.req_data = Any # Vector(undef, 0)
    stats.res_data = Vector{Any}(undef, 0)
end