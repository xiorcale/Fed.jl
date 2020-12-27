mutable struct VanillaStats{T <: Real} <: Statistics
    common::CommonStats
    network::VanillaNetStats

    round_changes::Vector{Float32}
    weights_difference::Vector{Vector{Float32}}

    VanillaStats{T}(config::Configuration, num_weights::Int) where T <: Real = new(
        CommonStats{T}(
            config.common.num_comm_rounds,
            config.common.fraction_clients,
            config.common.num_total_clients,
            num_weights
        ),
        VanillaNetStats(),
        Vector{Float32}(undef, 0),
        Vector{Vector{Float32}}(undef, 0)
    )
end

function update_stats!(stats::VanillaStats)
    if stats.common.dtype == Float32
        values_range = 2.0f0
    else
        values_range = typemax(stats.common.dtype)
    end
    push!(stats.weights_difference, compute_elements_difference(stats.common.req_data, stats.common.res_data))
    push!(stats.round_changes, compute_round_changes(stats.common.req_data, stats.common.res_data))
end
