using ..Config: Configuration


mutable struct VanillaStats{T <: Real} <: Statistics
    T::Type{T}
    base::BaseStats
    network::VanillaNetStats

    round_changes::Vector{Float32}
    weights_difference::Vector{Vector{Float32}}

    VanillaStats{T}(config::Configuration, num_weights::Int) where T <: Real = new(
        T,
        BaseStats(
            config.base.num_comm_rounds,
            config.base.fraction_clients,
            config.base.num_total_clients,
            num_weights
        ),
        VanillaNetStats(),
        Vector{Float32}(undef, 0),
        Vector{Vector{Float32}}(undef, 0)
    )
end

function update_stats!(stats::VanillaStats)
    push!(stats.weights_difference, compute_elements_difference(stats.base.req_data, stats.base.res_data))
    push!(stats.round_changes, compute_round_changes(stats.base.req_data, stats.base.res_data))
end
