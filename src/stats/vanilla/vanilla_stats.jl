mutable struct VanillaStats{T <: Real} <: Statistics
    common::CommonStats
    network::VanillaNetStats

    VanillaStats{T}(config::Configuration, num_weights::Int) where T <: Real = new(
        CommonStats{T}(
            config.common.num_comm_rounds,
            config.common.fraction_clients,
            config.common.num_total_clients,
            num_weights
        ),
        VanillaNetStats()
    )
end

# function update_stats!(
#     stats::VanillaStats,
#     round_num::Int,
#     loss::Float32,
#     accuracy::Float32
# )
#     update_stats!(stats.common, loss, accuracy)
#     update_stats!(stats.network, round_num)

# end