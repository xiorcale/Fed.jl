"""
    BaseStats

Every stats common to any configuration.
"""
struct BaseStats <: Statistics
    # federated learning stats
    num_comm_round::Int
    num_clients_per_round::Int
    num_total_clients::Int

    # machine learning stats
    num_weights::Int
    losses::Vector{Float32}
    accuracies::Vector{Float32}

    BaseStats(
        num_comm_round::Int,
        fraction_client::Float32,
        num_total_clients::Int,
        num_weights::Int
    ) = new(
        num_comm_round,
        max(round(Int, fraction_client * num_total_clients), 1),
        num_total_clients,
        num_weights,
        Vector{Float32}(undef, 0),
        Vector{Float32}(undef, 0)
    )
end

function update_stats!(stats::BaseStats, loss::Float32, accuracy::Float32) 
    push!(stats.losses, loss)
    push!(stats.accuracies, accuracy)
end